//
//  MHImportExportFeeback.h
//  MongoHub
//
//  Created by Jérôme Lebel on 31/01/2014.
//  Copyright (c) 2014 ThePeppersStudio.COM. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MHExporterImporter.h"

@interface MHImportExportFeeback : NSObject
{
    IBOutlet NSWindow                   *_window;
    IBOutlet NSTextField                *_label;
    IBOutlet NSProgressIndicator        *_progressIndicator;
    id<MHImporterExporter>              _importerExporter;
}
@property (nonatomic, readwrite, retain) NSString *label;

- (id)initWithImporterExporter:(id<MHImporterExporter>)importerExporter;
- (void)displayForWindow:(NSWindow *)window;

@end
