//
//  MHAddCollectionController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "MHAddCollectionController.h"


@implementation MHAddCollectionController

@synthesize dbname;
@synthesize collectionname;

- (id)init
{
    self = [super initWithWindowNibName:@"MHAddCollectionController"];
    return self;
}

- (void)dealloc
{
    [dbname release];
    [collectionname release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window];
}

- (IBAction)add:(id)sender
{
    NSMutableDictionary *dbInfo;
    
    [self retain];
    if ([ [collectionname stringValue] length] == 0) {
        NSRunAlertPanel(@"Error", @"Collection name can not be empty", @"OK", nil, nil);
        return;
    }
    dbInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:dbname, @"dbname", collectionname.stringValue, @"collectionname", nil];
    // the delegate will release this instance in this notification, so we need to make sure we keep ourself arround to close the window
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewCollectionWindowWillClose object:dbInfo];
    [NSApp endSheet:self.window];
    [self release];
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
