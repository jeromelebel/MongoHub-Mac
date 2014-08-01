//
//  MHAddDBController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "MHAddDBController.h"
#import "NSString+Extras.h"

@interface MHAddDBController ()
@property (nonatomic, readwrite, strong) NSTextField *databaseNameTextField;

@end

@implementation MHAddDBController

@synthesize databaseNameTextField = _databaseNameTextField;

- (id)init
{
    self = [super initWithWindowNibName:@"MHAddDBController"];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window];
}

- (IBAction)add:(id)sender
{
    [self retain];
    if (self.databaseName.length == 0) {
        NSRunAlertPanel(@"Error", @"Database name can not be empty", @"OK", nil, nil);
    } else {
        [self retain];
        // the delegate will release this instance in this notification, so we need to make sure we keep ourself arround to close the window
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewDBWindowWillClose object:self];
        [NSApp endSheet:self.window];
        [self autorelease];
    }
}

- (void)modalForWindow:(NSWindow *)window
{
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self.window orderOut:self];
}

- (NSString *)databaseName
{
    return self.databaseNameTextField.stringValue;
}

@end
