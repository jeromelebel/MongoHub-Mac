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

+ (instancetype)preferenceWindowController;

@end

@interface MHPreferenceWindowController (Preferences)

+ (MHDefaultSortOrder)defaultSortOrder;
+ (MODJsonKeySortOrder)jsonKeySortOrderInSearch;

@end