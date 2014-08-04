//
//  MHImportExportFeedback.m
//  MongoHub
//
//  Created by Jérôme Lebel on 31/01/2014.
//

#import "MHImportExportFeedback.h"

@implementation MHImportExportFeedback

- (id)initWithImporterExporter:(id<MHImporterExporter>)importerExporter
{
    self = [self init];
    if (self) {
        [NSBundle loadNibNamed:@"MHImportExportFeedback" owner:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(importerExporterNotification:) name:MHImporterExporterProgressNotification object:importerExporter];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:nil object:nil];
    [super dealloc];
}

- (void)displayForWindow:(NSWindow *)window
{
    [NSApp beginSheet:_window modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)start
{
    _progressIndicator.indeterminate = YES;
    [_progressIndicator startAnimation:self];
}

- (void)close
{
    [NSApp endSheet:_window];
}

- (void)sheetDidEnd:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [_window orderOut:self];
}

- (void)setLabel:(NSString *)label
{
    _label.stringValue = label;
}

- (NSString *)label
{
    return _label.stringValue;
}

- (void)setMaxValue:(double)maxValue
{
    _progressIndicator.maxValue = maxValue;
}

- (double)maxValue
{
    return _progressIndicator.maxValue;
}

- (void)setProgressValue:(double)progressValue
{
    _progressIndicator.doubleValue = progressValue;
}

- (double)progressValue
{
    return _progressIndicator.doubleValue;
}

- (void)importerExporterNotification:(NSNotification *)notification
{
    if (_progressIndicator.isIndeterminate) {
        _progressIndicator.indeterminate = NO;
        _progressIndicator.maxValue = 1.0;
    }
    self.progressValue = [[notification.userInfo objectForKey:MHImporterExporterNotificationProgressKey] floatValue];
}

@end
