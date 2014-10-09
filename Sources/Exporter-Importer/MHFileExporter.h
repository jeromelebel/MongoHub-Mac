//
//  MHFileExporter.h
//  MongoHub
//
//  Created by Jérôme Lebel on 19/11/2011.
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

- (instancetype)initWithCollection:(MODCollection *)collection exportPath:(NSString *)exportPath;
- (void)export;

@property (nonatomic, retain, readonly) NSString *exportPath;
@property (nonatomic, retain, readonly) MODCollection *collection;

@end
