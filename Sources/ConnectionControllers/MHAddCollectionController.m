//
//  MHAddCollectionController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHAddCollectionController.h"


@interface MHAddCollectionController ()
@property (nonatomic, readwrite, strong) IBOutlet NSTextField *collectionNameTextField;

@end

@implementation MHAddCollectionController

@synthesize collectionName = _collectionName;
@synthesize collectionNameTextField = _collectionNameTextField;

- (id)init
{
    self = [super initWithWindowNibName:@"MHAddCollection"];
    return self;
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window];
}

- (IBAction)add:(id)sender
{
    if (self.collectionName.length == 0) {
        NSRunAlertPanel(@"Error", @"Collection name can not be empty", @"OK", nil, nil);
    } else {
        [self retain];
        // the delegate will release this instance in this notification, so we need to make sure we keep ourself arround to close the window
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewCollectionWindowWillClose object:self];
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

- (NSString *)collectionName
{
    return self.collectionNameTextField.stringValue;
}

@end
