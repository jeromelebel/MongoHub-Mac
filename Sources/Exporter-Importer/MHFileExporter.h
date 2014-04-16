//
//  MHFileExporter.h
//  MongoHub
//
//  Created by Jérôme Lebel on 19/11/11.
//  Copyright (c) 2011 ThePeppersStudio.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHExporterImporter.h"

@class MODCollection;

@interface MHFileExporter : NSObject <MHImporterExporter>
{
    NSString                    *_exportPath;
    MODCollection               *_collection;
    int64_t                     _ii;
    NSError                     *_error;
}

- (id)initWithCollection:(MODCollection *)collection exportPath:(NSString *)exportPath;
- (BOOL)export;

@property (nonatomic, retain, readonly) NSString *exportPath;
@property (nonatomic, retain, readonly) MODCollection *collection;

@end
