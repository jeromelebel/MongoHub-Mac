//
//  MHAddDBController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "MHAddDBController.h"
#import "DatabasesArrayController.h"
#import "MHDatabaseStore.h"
#import "NSString+Extras.h"

@implementation MHAddDBController

@synthesize dbname;
@synthesize user;
@synthesize password;
@synthesize dbInfo;
@synthesize conn;
@synthesize databasesArrayController = _databasesArrayController;

- (id)init
{
    self = [super initWithWindowNibName:@"MHAddDBController"];
    return self;
}

- (void)dealloc
{
    [dbname release];
    [user release];
    [password release];
    [dbInfo release];
    [_databasesArrayController release];
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
    [self retain];
    if ([ [dbname stringValue] length] == 0) {
        NSRunAlertPanel(@"Error", @"Database name can not be empty", @"OK", nil, nil);
        return;
    }
    NSArray *keys = [[NSArray alloc] initWithObjects:@"dbname", @"user", @"password", nil];
    NSString *dbstr = [[NSString alloc] initWithString:[dbname stringValue]];
    NSString *userStr = [[NSString alloc] initWithString:[user stringValue]];
    NSString *passStr = [[NSString alloc] initWithString:[password stringValue]];
    NSArray *objs = [[NSArray alloc] initWithObjects:dbstr, userStr, passStr, nil];
    [dbstr release];
    [userStr release];
    [passStr release];
    if (!dbInfo) {
        dbInfo = [[NSMutableDictionary alloc] initWithCapacity:3]; 
    }
    dbInfo = [NSMutableDictionary dictionaryWithObjects:objs forKeys:keys];
    [objs release];
    [keys release];
    if (([[dbInfo objectForKey:@"user"] length] > 0) || ([[dbInfo objectForKey:@"password"] length] > 0)) {
        MHDatabaseStore *dbobj = [_databasesArrayController dbInfo:conn name:[dbname stringValue]];
        if (dbobj==nil) {
            //[dbobj release];
            dbobj = [_databasesArrayController newObjectWithConn:conn name:[dbname stringValue] user:[dbInfo objectForKey:@"user"] password:[dbInfo objectForKey:@"password"]];
            [_databasesArrayController addObject:dbobj];
            [dbobj release];
        }
        [self saveAction];
    }
    // the delegate will release this instance in this notification, so we need to make sure we keep ourself arround to close the window
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDBWindowWillClose object:dbInfo];
    [NSApp endSheet:self.window];
    [self autorelease];
}

- (void) saveAction
{
    
    NSError *error = nil;
    
    if (![self.managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![self.managedObjectContext save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (void)modalForWindow:(NSWindow *)window
{
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self.window orderOut:self];
    dbInfo = nil;
}

@end
