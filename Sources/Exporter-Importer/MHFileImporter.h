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
    NSString *_importPath;
    MODCollection *_collection;
    MODQuery *_latestQuery;
    NSUInteger                      _importedDocumentCount;
    NSUInteger                      _fileRead;
    
    NSMutableString                 *_buffer;
    NSMutableArray                  *_pendingDocuments;
    MODRagelJsonParser              *_parser;
    int                             _fileDescriptor;
    NSError                         *_firstDocumentError;
}

- (id)initWithCollection:(MODCollection *)collection importPath:(NSString *)importPath;
- (BOOL)importWithError:(NSError **)error;

@property (nonatomic, retain, readonly) NSString *importPath;
@property (nonatomic, retain, readonly) MODCollection *collection;
@property (nonatomic, assign, readonly) NSUInteger importedDocumentCount;
@property (nonatomic, assign, readonly) NSUInteger fileRead;
@property (nonatomic, strong, readonly) NSError *firstDocumentError;

@end
