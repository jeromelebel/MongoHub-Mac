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

@implementation MHAddDBController

@synthesize dbname;
@synthesize conn;

- (id)init
{
    self = [super initWithWindowNibName:@"MHAddDBController"];
    return self;
}

- (void)dealloc
{
    [dbname release];
    [conn release];
    [super dealloc];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [conn managedObjectContext];
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window];
}

- (IBAction)add:(id)sender
{
    NSMutableDictionary *dbInfo;
    
    [self retain];
    if ([ [dbname stringValue] length] == 0) {
        NSRunAlertPanel(@"Error", @"Database name can not be empty", @"OK", nil, nil);
        return;
    }
    dbInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:dbname.stringValue, @"dbname", nil];
    // the delegate will release this instance in this notification, so we need to make sure we keep ourself arround to close the window
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDBWindowWillClose object:dbInfo];
    [NSApp endSheet:self.window];
    [self autorelease];
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
