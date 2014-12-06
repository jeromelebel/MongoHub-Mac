//
//  MHJsonWindowController.h
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "UKSyntaxColoredTextViewController.h"
#import "MHPreferenceWindowController.h"

@class MODClient;
@class MODCollection;

#ifndef UKSCTD_DEFAULT_TEXTENCODING
#define UKSCTD_DEFAULT_TEXTENCODING     NSUTF8StringEncoding
#endif

#define kJsonWindowWillClose @"kJsonWindowWillClose"
#define kJsonWindowSaved @"kJsonWindowSaved"

@interface MHJsonWindowController : NSWindowController <UKSyntaxColoredTextViewDelegate, MODQueryCallbackTarget>
{
    id                                  _windowControllerId;
    MODCollection                       *_collection;
    MODSortedDictionary                 *_jsonDocument;
    NSData                              *_bsonData;
    
    NSTextView                          *_jsonTextView;
    NSProgressIndicator                 *_progressIndicator;
    NSTextField                         *_status;
    UKSyntaxColoredTextViewController   *_syntaxColoringController;
}

// just a data to store (used by the user of this class
@property (nonatomic, readwrite, strong) id windowControllerId;
@property (nonatomic, readwrite, strong) MODSortedDictionary *jsonDocument;
@property (nonatomic, readwrite, strong) NSData *bsonData;
@property (nonatomic, readwrite, strong) MODCollection *collection;

@end
