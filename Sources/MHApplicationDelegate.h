//
//  MHApplicationDelegate.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright MusicPeace.ORG 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHConnectionEditorWindowController.h"
#import "MHConnectionCollectionView.h"
#import "MHConnectionWindowController.h"

@class MHConnectionCollectionView;
@class MHConnectionStore;
@class MHConnectionEditorWindowController;
@class SUUpdater;
@class MHPreferenceWindowController;
@class MHLogWindowController;

typedef enum {
    MHSoftwareUpdateChannelDefault,
    MHSoftwareUpdateChannelBeta
} MHSoftwareUpdateChannel;

@interface MHApplicationDelegate : NSObject <NSApplicationDelegate, NSCollectionViewDelegate>

@property (nonatomic, strong, readonly) NSWindow *window;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign, readwrite) MHSoftwareUpdateChannel softwareUpdateChannel;
@property (nonatomic, assign, readonly) uint32_t defaultConnectTimeout;
@property (nonatomic, assign, readwrite) uint32_t connectTimeout;
@property (nonatomic, assign, readonly) uint32_t defaultSocketTimeout;
@property (nonatomic, assign, readwrite) uint32_t socketTimeout;

- (MHConnectionStore *)connectionStoreWithAlias:(NSString *)alias;

@end

@interface MHApplicationDelegate (MHConnectionEditorWindowControllerDelegate) <MHConnectionEditorWindowControllerDelegate>
@end

@interface MHApplicationDelegate (MHConnectionViewItemDelegate) <MHConnectionCollectionViewDelegate>
@end

@interface MHApplicationDelegate (MHConnectionWindowControllerDelegate) <MHConnectionWindowControllerDelegate>
@end

@interface MHApplicationDelegate (Preferences)
- (BOOL)hasCollectionMapReduceTab;
- (void)setCollectionMapReduceTab:(BOOL)value;
- (BOOL)hasCollectionAggregationTab;
- (void)setCollectionAggregationTab:(BOOL)value;

@end