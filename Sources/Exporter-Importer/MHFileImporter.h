//
//  MHFileImporter.h
//  MongoHub
//
//  Created by Jérôme Lebel on 23/11/2011.
//

#import <Foundation/Foundation.h>
#import "MHExporterImporter.h"

@class MODCollection, MODQuery, MODRagelJsonParser;

@interface MHFileImporter : NSObject <MHImporterExporter>
{
    NSString                        *_importPath;
    MODCollection                   *_collection;
    MODQuery                        *_latestQuery;
    NSUInteger                      _fileRead;
    
    NSMutableArray                  *_pendingDocuments;
    void                            *_fileDescriptor;
    NSError                         *_error;
    unsigned long long              _fileSize;
    unsigned long long              _dataRead;
    unsigned long long              _dataProcessed;
    NSUInteger                      _documentProcessedCount;
}

- (instancetype)initWithCollection:(MODCollection *)collection importPath:(NSString *)importPath;
- (void)import;

@property (nonatomic, readonly, strong) NSString *importPath;
@property (nonatomic, readonly, strong) MODCollection *collection;
@property (nonatomic, readonly, assign) NSUInteger fileRead;

@end
