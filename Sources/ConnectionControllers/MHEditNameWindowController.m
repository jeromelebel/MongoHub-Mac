//
//  MHEditNameWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHEditNameWindowController.h"


@interface MHEditNameWindowController ()
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *editedValueTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *labelTextField;

@property (nonatomic, readwrite, strong) NSString *editedValue;
@property (nonatomic, readwrite, strong) NSString *label;

@end

@implementation MHEditNameWindowController

@synthesize editedValueTextField = _editedValueTextField;
@synthesize labelTextField = _labelTextField;
@synthesize editedValue = _editedValue;
@synthesize label = _label;
@synthesize callback = _callback;

- (instancetype)initWithLabel:(NSString *)label editedValue:(NSString *)editedValue
{
    self = [self init];
    if (self) {
        self.label = label;
        self.editedValue = editedValue;
    }
    return self;
}

- (void)dealloc
{
    self.label = nil;
    self.editedValue = nil;
    self.callback = nil;
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"MHEditNameWindow";
}

- (void)awakeFromNib
{
    self.labelTextField.stringValue = self.label;
    if (self.editedValue) {
        self.editedValueTextField.stringValue = self.editedValue;
    }
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window];
}

- (IBAction)add:(id)sender
{
    NSString *value;
    
    value = [self.editedValueTextField.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (value.length == 0) {
        NSRunAlertPanel(@"Error", @"Collection name can not be empty", @"OK", nil, nil);
    } else {
        [self retain];
        // the delegate will release this instance after the call,
        // so we need to make sure we keep ourself arround to close the window
        self.editedValue = value;
        if (self.callback) {
            self.callback(self);
        }
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

@end
