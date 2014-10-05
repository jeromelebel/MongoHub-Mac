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
    NSTextField                         *_editedNameTextField;
    NSTextField                         *_nameTitleTextField;
}

@property (nonatomic, readwrite, assign) NSString *editedName;
@property (nonatomic, readwrite, assign) NSString *nameTitle;

- (void)modalForWindow:(NSWindow *)window;

@end
