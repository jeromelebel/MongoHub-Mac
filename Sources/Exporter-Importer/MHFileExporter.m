//
//  MHFileExporter.m
//  MongoHub
//
//  Created by Jérôme Lebel on 19/11/2011.
//

#import "MHFileExporter.h"

@interface MHFileExporter ()
@property (nonatomic, readwrite, strong) NSError *error;
@property (nonatomic, readwrite, assign) NSUInteger documentProcessedCount;

@end

@implementation MHFileExporter

@synthesize collection = _collection;
@synthesize exportPath = _exportPath;
@synthesize error = _error;
@synthesize jsonKeySortOrder = _jsonKeySortOrder;
@synthesize documentProcessedCount = _documentProcessedCount;

- (instancetype)initWithCollection:(MODCollection *)collection exportPath:(NSString *)exportPath
{
    if (self = [self init]) {
        _collection = [collection retain];
        _exportPath = [exportPath retain];
        self.jsonKeySortOrder = MODJsonKeySortOrderDocument;
    }
    return self;
}

- (void)dealloc
{
    [_collection release];
    [_exportPath release];
    self.error = nil;
    [super dealloc];
}

- (void)export
{
    int fileDescriptor;
    
    [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterStartNotification object:self userInfo:nil];
    fileDescriptor = open([_exportPath fileSystemRepresentation], O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if (fileDescriptor < 0) {
        printf("error %d\n", errno);
        perror("fichier");
        self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
        [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterStopNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.error, @"error", nil]];
    } else {
        [_collection countWithCriteria:nil readPreferences:nil callback:^(int64_t count, MODQuery *mongoQuery) {
            MODCursor *cursor;
            int64_t step;
            
            step = count / 200;
            if (step == 0) {
                step = 1;
            }
            self.documentProcessedCount = 0;
            
            cursor = [_collection cursorWithCriteria:nil fields:nil skip:0 limit:0 sort:nil];
            [cursor forEachDocumentWithCallbackDocumentCallback:^(uint64_t index, MODSortedDictionary *document) {
                NSString *jsonDocument;
                const char *cString;
                
                jsonDocument = [MODClient convertObjectToJson:document pretty:NO strictJson:YES jsonKeySortOrder:self.jsonKeySortOrder];
                cString = [jsonDocument UTF8String];
                write(fileDescriptor, cString, strlen(cString));
                write(fileDescriptor, "\n", 1);
                self.documentProcessedCount++;
                if (self.documentProcessedCount % step) {
                    [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterProgressNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)self.documentProcessedCount / count], MHImporterExporterNotificationProgressKey, nil]];
                }
                return YES;
            } endCallback:^(uint64_t documentCounts, BOOL cursorStopped, MODQuery *mongoQuery) {
                close(fileDescriptor);
                [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterStopNotification object:self userInfo:nil];
            }];
        }];
        
    }
}

- (NSString *)identifier
{
    return @"fileexport";
}

- (NSString *)name
{
    return @"File Export";
}

@end
