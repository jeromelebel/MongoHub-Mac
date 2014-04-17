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

@interface MHFileImporter()
@property (nonatomic, readwrite, retain) NSError *error;
@property (nonatomic, assign, readwrite) NSUInteger importedDocumentCount;
@property (nonatomic, assign, readwrite) NSUInteger fileRead;

@property (nonatomic, strong, readwrite) NSMutableArray *pendingDocuments;
@property (nonatomic, assign, readwrite) FILE *fileDescriptor;
@end

@implementation MHFileImporter

@synthesize collection = _collection, importPath = _importPath, importedDocumentCount = _importedDocumentCount, fileRead = _fileRead, pendingDocuments = _pendingDocuments, fileDescriptor = _fileDescriptor, error = _error;

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

- (void)_appendDocumentToParse:(NSString *)stringDocument flush:(BOOL)flush
{
    if (stringDocument.length > 0) {
        [self.pendingDocuments addObject:stringDocument];
    }
    if (self.pendingDocuments.count >= 100 || (flush && self.pendingDocuments.count > 0)) {
        NSUInteger importedDocumentCount = self.importedDocumentCount;
        
        [_latestQuery waitUntilFinished];
        [_latestQuery release];
        _dataProcessed = _dataRead;
        _latestQuery = [[_collection insertWithDocuments:self.pendingDocuments callback:^(MODQuery *query) {
            if (query.error && !self.error) {
                NSMutableDictionary *userInfo;
                
                userInfo = query.error.userInfo.mutableCopy;
                [userInfo setObject:[NSNumber numberWithUnsignedInteger:[[userInfo objectForKey:@"documentIndex"] unsignedIntegerValue] + importedDocumentCount] forKey:@"documentIndex"];
                self.error = [NSError errorWithDomain:query.error.domain code:query.error.code userInfo:userInfo];
            }
            [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterProgressNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)_dataProcessed / _fileSize], MHImporterExporterNotificationProgressKey, nil]];
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
    _dataRead = 0;
    _fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_importPath error:nil] fileSize];
    self.fileDescriptor = fopen([_importPath fileSystemRepresentation], "r");
    if (self.fileDescriptor == NULL) {
        printf("error %d\n", errno);
        perror("fichier");
        self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
    } else {
        self.pendingDocuments = [NSMutableArray array];
        [self _doImport];
        self.pendingDocuments = nil;
        fclose(self.fileDescriptor);
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
    size_t length;
    char *line;
    
    while ((line = fgetln(self.fileDescriptor, &length)) && self.error == nil) {
        NSString *result;
        
        _dataRead += length;
        result = [[NSString alloc] initWithBytes:line length:length encoding:NSUTF8StringEncoding];
        [self _appendDocumentToParse:result flush:NO];
        [result release];
    }
    [self _appendDocumentToParse:nil flush:YES];
}

@end
