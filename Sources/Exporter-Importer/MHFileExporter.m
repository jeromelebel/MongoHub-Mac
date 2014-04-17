//
//  MHFileExporter.m
//  MongoHub
//
//  Created by Jérôme Lebel on 19/11/11.
//

#import "MHFileExporter.h"
#import "MOD_public.h"

@interface MHFileExporter ()
@property (nonatomic, readwrite, retain) NSError *error;

@end

@implementation MHFileExporter

@synthesize collection = _collection, exportPath = _exportPath, error = _error;

- (id)initWithCollection:(MODCollection *)collection exportPath:(NSString *)exportPath
{
    if (self = [self init]) {
        _collection = [collection retain];
        _exportPath = [exportPath retain];
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
        [_collection countWithCriteria:nil callback:^(int64_t count, MODQuery *mongoQuery) {
            MODCursor *cursor;
            int64_t step;
            
            step = count / 200;
            if (step == 0) {
                step = 1;
            }
            _ii = 0;
            
            cursor = [_collection cursorWithCriteria:nil fields:nil skip:0 limit:0 sort:nil];
            [cursor forEachDocumentWithCallbackDocumentCallback:^(uint64_t index, MODSortedMutableDictionary *document) {
                NSString *jsonDocument;
                const char *cString;
                
                jsonDocument = [MODServer convertObjectToJson:document pretty:NO strictJson:YES];
                cString = [jsonDocument UTF8String];
                write(fileDescriptor, cString, strlen(cString));
                write(fileDescriptor, "\n", 1);
                _ii++;
                if (_ii % step) {
                    [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterProgressNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)_ii / count], MHImporterExporterNotificationProgressKey, nil]];
                }
                return YES;
            } endCallback:^(uint64_t documentCounts, BOOL cursorStopped, MODQuery *mongoQuery) {
                close(fileDescriptor);
                [NSNotificationCenter.defaultCenter postNotificationName:MHImporterExporterStopNotification object:self userInfo:nil];
            }];
        }];
        
    }
}

@end
