//
//  MHImportExportFeedback.h
//  MongoHub
//
//  Created by Jérôme Lebel on 31/01/2014.
//

#import <AppKit/AppKit.h>
#import "MHExporterImporter.h"

@interface MHImportExportFeedback : NSObject
{
    IBOutlet NSWindow                   *_window;
    IBOutlet NSTextField                *_label;
    IBOutlet NSProgressIndicator        *_progressIndicator;
    id<MHImporterExporter>              _importerExporter;
}
@property (nonatomic, readwrite, retain) NSString *label;

- (instancetype)initWithImporterExporter:(id<MHImporterExporter>)importerExporter;
- (void)displayForWindow:(NSWindow *)window;
- (void)start;
- (void)close;

@end
