//
//  MHAddDBController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MHConnectionStore;
@class MHAddDBController;

@interface MHAddDBController : NSWindowController
{
    IBOutlet NSTextField *dbname;
    
    MHConnectionStore *conn;
    NSManagedObjectContext              *_managedObjectContext;
}

@property (nonatomic, retain) NSTextField *dbname;
@property (nonatomic, retain) MHConnectionStore *conn;
@property(nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)modalForWindow:(NSWindow *)window;

@end
