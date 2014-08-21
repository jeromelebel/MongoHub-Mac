//
//  MHJsonWindowController.h
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKSyntaxColoredTextViewController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>

@class MODClient;
@class MODCollection;

#ifndef UKSCTD_DEFAULT_TEXTENCODING
#define UKSCTD_DEFAULT_TEXTENCODING     NSUTF8StringEncoding
#endif

#define kJsonWindowWillClose @"kJsonWindowWillClose"
#define kJsonWindowSaved @"kJsonWindowSaved"

@interface MHJsonWindowController : NSWindowController <UKSyntaxColoredTextViewDelegate, MODQueryCallbackTarget>
{
    MODCollection                       *_collection;
    NSDictionary                        *jsonDict;
    IBOutlet NSTextView                 *myTextView;
    NSProgressIndicator                 *_progressIndicator;
    IBOutlet NSTextField                *status;
    UKSyntaxColoredTextViewController   *_syntaxColoringController;
}

@property (nonatomic, retain) NSDictionary *jsonDict;
@property (nonatomic, retain) NSTextView *myTextView;
@property (nonatomic, readwrite, retain) MODCollection *collection;
@property (nonatomic, readonly, strong) IBOutlet NSProgressIndicator *progressIndicator;

@end
