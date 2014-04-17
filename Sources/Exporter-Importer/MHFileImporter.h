//
//  MHFileImporter.h
//  MongoHub
//
//  Created by Jérôme Lebel on 23/11/11.
//  Copyright (c) 2011 ThePeppersStudio.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHExporterImporter.h"

@class MODCollection, MODQuery, MODRagelJsonParser;

@interface MHFileImporter : NSObject <MHImporterExporter>
{
    NSString                        *_importPath;
    MODCollection                   *_collection;
    MODQuery                        *_latestQuery;
    NSUInteger                      _importedDocumentCount;
    NSUInteger                      _fileRead;
    
    NSMutableArray                  *_pendingDocuments;
    void                            *_fileDescriptor;
    NSError                         *_error;
    unsigned long long              _fileSize;
    unsigned long long              _dataRead;
    unsigned long long              _dataProcessed;
}

- (id)initWithCollection:(MODCollection *)collection importPath:(NSString *)importPath;
- (void)import;

@property (nonatomic, retain, readonly) NSString *importPath;
@property (nonatomic, retain, readonly) MODCollection *collection;
@property (nonatomic, assign, readonly) NSUInteger importedDocumentCount;
@property (nonatomic, assign, readonly) NSUInteger fileRead;

@end
