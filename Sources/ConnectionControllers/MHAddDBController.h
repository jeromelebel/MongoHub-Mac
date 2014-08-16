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

#define kNewDBWindowWillClose @"NewDBWindowWillClose"

@interface MHAddDBController : NSWindowController
{
    IBOutlet NSTextField                *_databaseNameTextField;
}
@property (nonatomic, readonly, strong) NSString *databaseName;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)modalForWindow:(NSWindow *)window;

@end
