//
//  MHFileImporter.m
//  MongoHub
//
//  Created by Jérôme Lebel on 23/11/2011.
//

#import "MHFileImporter.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "MHExporterImporter.h"

@interface MHFileImporter()
@property (nonatomic, readwrite, strong) NSError *error;
@property (nonatomic, readwrite, assign) NSUInteger documentProcessedCount;
@property (nonatomic, readwrite, assign) NSUInteger fileRead;

@property (nonatomic, readwrite, strong) NSMutableArray *pendingDocuments;
@property (nonatomic, readwrite, assign) FILE *fileDescriptor;
@end

@implementation MHFileImporter

@synthesize collection = _collection;
@synthesize importPath = _importPath;
@synthesize documentProcessedCount = _documentProcessedCount;
@synthesize fileRead = _fileRead;
@synthesize pendingDocuments = _pendingDocuments;
@synthesize fileDescriptor = _fileDescriptor;
@synthesize error = _error;

- (instancetype)initWithCollection:(MODCollection *)collection importPath:(NSString *)importPath
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
        NSUInteger documentProcessedCount = self.documentProcessedCount;
        
        [_latestQuery waitUntilFinished];
        [_latestQuery release];
        _dataProcessed = _dataRead;
        _latestQuery = [[_collection insertWithDocuments:self.pendingDocuments writeConcern:nil callback:^(MODQuery *query) {
            if (query.error && !self.error) {
                NSMutableDictionary *userInfo;
                
                userInfo = [query.error.userInfo.mutableCopy autorelease];
                [userInfo setObject:[NSNumber numberWithUnsignedInteger:[[userInfo objectForKey:@"documentIndex"] unsignedIntegerValue] + documentProcessedCount] forKey:@"documentIndex"];
                self.error = [NSError errorWithDomain:query.error.domain code:query.error.code userInfo:userInfo];
            }
            [self performSelectorOnMainThread:@selector(sendNotification:) withObject:@{ @"name" :MHImporterExporterProgressNotification, @"userinfo": @{ MHImporterExporterNotificationProgressKey: @(_dataProcessed / _fileSize) } } waitUntilDone:NO];
        }] retain];
        self.documentProcessedCount += self.pendingDocuments.count;
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
    [self performSelectorOnMainThread:@selector(sendNotification:) withObject:@{ @"name" :MHImporterExporterStartNotification } waitUntilDone:NO];
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
    }
    if (self.error) {
        [self performSelectorOnMainThread:@selector(sendNotification:) withObject:@{ @"name" :MHImporterExporterStopNotification, @"userinfo": @{ @"error": self.error } } waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(sendNotification:) withObject:@{ @"name" :MHImporterExporterStopNotification } waitUntilDone:NO];
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

- (NSString *)identifier
{
    return @"fileimport";
}

- (NSString *)name
{
    return @"File Import";
}

@end
