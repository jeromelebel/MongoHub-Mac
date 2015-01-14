//
//  MHPreferenceWindowController
//  MongoHub
//
//  Created by Jérôme Lebel on 23/10/2013.
//

#import <Cocoa/Cocoa.h>
#import <MongoObjCDriver/MongoObjCDriver.h>

#define MHPreferenceWindowControllerClosing                 @"MHPreferenceWindowControllerClosing"
#define MHDefaultSortOrderPreferenceChangedNotification     @"MHDefaultSortOrderPreferenceChanged"

typedef enum {
    MHDefaultSortOrderAscending,
    MHDefaultSortOrderDescending,
} MHDefaultSortOrder;

@interface MHPreferenceWindowController : NSWindowController
{
    NSButton                            *_betaSoftwareButton;
    NSColorWell                         *_textBackgroundColorWell;
    NSTableView                         *_jsonColorTableView;
    NSTextField                         *_jsonTextLabelView;
    NSColorWell                         *_jsonTextColorWell;
    
    NSMutableArray                      *_jsonComponents;
    
    NSPopUpButton                       *_defaultSortOrder;
    NSPopUpButton                       *_jsonKeySortOrderInSearch;
    
    NSTextField                         *_connectTimeoutTextField;
    NSTextField                         *_socketTimeoutTextField;
    NSPopUpButton                       *_collectionTabPopUpButton;
}

+ (instancetype)preferenceWindowController;

@end

@interface MHPreferenceWindowController (Preferences)

+ (MHDefaultSortOrder)defaultSortOrder;
+ (MODJsonKeySortOrder)jsonKeySortOrderInSearch;

@end