//
//  MHEditNameWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kNewCollectionWindowWillClose @"NewCollectionWindowWillClose"

@interface MHEditNameWindowController : NSWindowController
{
    NSTextField                         *_collectionNameTextField;
    NSString                            *_collectionName;
}

@property (nonatomic, readonly, strong) NSString *collectionName;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)modalForWindow:(NSWindow *)window;

@end
