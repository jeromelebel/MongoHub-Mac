//
//  MHImportExportFeeback.m
//  MongoHub
//
//  Created by Jérôme Lebel on 31/01/2014.
//  Copyright (c) 2014 ThePeppersStudio.COM. All rights reserved.
//

#import "MHImportExportFeeback.h"

@implementation MHImportExportFeeback

- (id)initWithImporterExporter:(id<MHImporterExporter>)importerExporter
{
    self = [self init];
    if (self) {
        [NSBundle loadNibNamed:@"MHImportExportFeedback" owner:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(importerExporterNotification:) name:nil object:importerExporter];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)displayForWindow:(NSWindow *)window
{
    [NSApp beginSheet:_window modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
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
    if ([notification.name isEqualTo:MHImporterExporterStartNotification]) {
        _progressIndicator.indeterminate = YES;
        [_progressIndicator startAnimation:self];
    } else if ([notification.name isEqualTo:MHImporterExporterStopNotification]) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:nil object:nil];
        [self close];
    } else {
        if (_progressIndicator.isIndeterminate) {
            _progressIndicator.indeterminate = NO;
            _progressIndicator.maxValue = 1.0;
        }
        self.progressValue = [[notification.userInfo objectForKey:MHImporterExporterNotificationProgressKey] floatValue];
    }
}

@end
