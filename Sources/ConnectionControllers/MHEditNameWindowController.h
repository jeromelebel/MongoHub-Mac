//
//  MHEditNameWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MHEditNameWindowController;

@protocol MHEditNameWindowControllerDelegate <NSObject>
- (void)editNameWindowControllerDidSucceed:(MHEditNameWindowController *)controller;
@end

@interface MHEditNameWindowController : NSWindowController
{
    NSTextField                                 *_editedValueTextField;
    NSTextField                                 *_labelTextField;
    
    NSString                                    *_label;
    NSString                                    *_editedValue;
    void (^_callback)(MHEditNameWindowController *controller);
}

@property (nonatomic, readonly, copy) NSString *editedValue;
@property (nonatomic, readwrite, copy) void (^callback)(MHEditNameWindowController *controller);
@property (nonatomic, readwrite, copy) BOOL (^validateValueCallback)(MHEditNameWindowController *controller);

- (instancetype)initWithLabel:(NSString *)label editedValue:(NSString *)editedValue placeHolder:(NSString *)placeHolder;
- (void)modalForWindow:(NSWindow *)window;

@end
