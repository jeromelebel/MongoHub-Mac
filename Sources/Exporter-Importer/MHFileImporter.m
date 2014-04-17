//
//  MHFileImporter.m
//  MongoHub
//
//  Created by Jérôme Lebel on 23/11/11.
//  Copyright (c) 2011 ThePeppersStudio.COM. All rights reserved.
//

#import "MHFileImporter.h"
#import "MOD_public.h"
#import "MHExporterImporter.h"

#define BUFFER_SIZE (100*1024*1024)

@interface MHFileImporter()
@property (nonatomic, readwrite, retain) NSError *error;
@property (nonatomic, assign, readwrite) NSUInteger importedDocumentCount;
@property (nonatomic, assign, readwrite) NSUInteger fileRead;

@property (nonatomic, strong, readwrite) NSMutableString *buffer;
@property (nonatomic, strong, readwrite) NSMutableArray *pendingDocuments;
@property (nonatomic, strong, readwrite) MODRagelJsonParser *parser;
@property (nonatomic, assign, readwrite) int fileDescriptor;
@end

@implementation MHFileImporter

@synthesize collection = _collection, importPath = _importPath, importedDocumentCount = _importedDocumentCount, fileRead = _fileRead, buffer = _buffer, pendingDocuments = _pendingDocuments, parser = _parser, fileDescriptor = _fileDescriptor, error = _error;

- (id)initWithCollection:(MODCollection *)collection importPath:(NSString *)importPath
{
    if (self = [self init]) {
        _collection = [collection retain];
        _importPath = [importPath retain];
    }
    return self;
}

- (void)dealloc
{
    [_collection release];
    [_importPath release];
    [_latestQuery release];
    self.error = nil;
    [super dealloc];
}

- (void)_removeBeginingWhiteSpaces
{
    NSRange whitespaceRange = { 0, 0 };
    
    while (self.buffer.length > 0 && [NSCharacterSet.whitespaceAndNewlineCharacterSet characterIsMember:[self.buffer characterAtIndex:whitespaceRange.length + 1]]) {
        whitespaceRange.length++;
    }
    if (whitespaceRange.length > 0) {
        [self.buffer deleteCharactersInRange:whitespaceRange];
    }
}

- (void)_appendDocumentToParse:(NSString *)stringDocument flush:(BOOL)flush
{
    if (stringDocument.length > 0) {
        [self.pendingDocuments addObject:stringDocument];
    }
    if (self.pendingDocuments.count >= 100 || (flush && self.pendingDocuments.count > 0)) {
        NSUInteger importedDocumentCount = self.importedDocumentCount;
        
        [_latestQuery release];
        _latestQuery = [[_collection insertWithDocuments:self.pendingDocuments callback:^(MODQuery *query) {
            if (query.error && !self.error) {
                NSMutableDictionary *userInfo;
                
                userInfo = query.error.userInfo.mutableCopy;
                [userInfo setObject:[NSNumber numberWithUnsignedInteger:[[userInfo objectForKey:@"documentIndex"] unsignedIntegerValue] + importedDocumentCount] forKey:@"documentIndex"];
                self.error = [NSError errorWithDomain:query.error.domain code:query.error.code userInfo:userInfo];
            }
        }] retain];
        self.importedDocumentCount += self.pendingDocuments.count;
        // to avoid changing the content of the array while trying to import all the documents
        // it is better to create a new one (instead of remove all its content)
        self.pendingDocuments = [NSMutableArray array];
    }
}

- (void)import
{
    [NSThread detachNewThreadSelector:@selector(_threadImport) toTarget:self withObject:nil];
}

- (void)sendNotification:(NSDictionary *)info
{
    [NSNotificationCenter.defaultCenter postNotificationName:[info objectForKey:@"name"] object:self userInfo:[info objectForKey:@"userinfo"]];
}

- (void)_threadImport
{
    [self performSelectorOnMainThread:@selector(sendNotification:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:MHImporterExporterStartNotification, @"name", nil] waitUntilDone:NO];
    self.fileDescriptor = open([_importPath fileSystemRepresentation], O_RDONLY, 0);
    if (self.fileDescriptor < 0) {
        printf("error %d\n", errno);
        perror("fichier");
        self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
    } else {
        self.parser = [[MODRagelJsonParser alloc] init];
        self.buffer = [[NSMutableString alloc] init];
        self.pendingDocuments = [NSMutableArray array];
        [self _doImport];
        [self.parser release];
        self.parser = nil;
        [self.buffer release];
        self.buffer = nil;
        self.pendingDocuments = nil;
        close(self.fileDescriptor);
        [_latestQuery waitUntilFinished];
        NSLog(@"%@", self.error);
    }
    if (self.error) {
        [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterStopNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.error, @"error", nil]];
        [self performSelectorOnMainThread:@selector(sendNotification:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:MHImporterExporterStopNotification, @"name", [NSDictionary dictionaryWithObjectsAndKeys:self.error, @"error", nil], @"userinfo", nil] waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(sendNotification:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:MHImporterExporterStopNotification, @"name", nil] waitUntilDone:NO];
    }
}

- (void)_doImport
{
    char *buffer;
    
    buffer = malloc(BUFFER_SIZE);
    while (YES) {
        size_t availableCount = read(self.fileDescriptor, buffer, BUFFER_SIZE);
        self.fileRead += availableCount;
        if (!availableCount) {
            break;
        } else {
            NSUInteger previousDataSize = self.buffer.length;
            NSRange eolRange;
            NSString *tmp;
            
            tmp = [[NSString alloc] initWithBytes:buffer length:availableCount encoding:NSUTF8StringEncoding];
            [self.buffer appendString:tmp];
            [tmp release];
            if (previousDataSize == 0) {
                [self _removeBeginingWhiteSpaces];
            }
            do {
                eolRange = [self.buffer rangeOfCharacterFromSet:NSCharacterSet.newlineCharacterSet options:0 range:NSMakeRange(previousDataSize, self.buffer.length - previousDataSize)];
                if (eolRange.location != NSNotFound) {
                    [self _appendDocumentToParse:[self.buffer substringToIndex:eolRange.location] flush:NO];
                    [self.buffer deleteCharactersInRange:NSMakeRange(0, eolRange.length + eolRange.location)];
                    [self _removeBeginingWhiteSpaces];
                }
            } while (eolRange.location != NSNotFound);
        }
    }
    [self _appendDocumentToParse:self.buffer flush:YES];
    free(buffer);
}

@end
