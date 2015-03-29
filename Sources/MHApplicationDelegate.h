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

@property (nonatomic, readonly, strong) NSWindow *window;

@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, assign) MHSoftwareUpdateChannel softwareUpdateChannel;
@property (nonatomic, readonly, assign) uint32_t defaultConnectTimeout;
@property (nonatomic, readwrite, assign) uint32_t connectTimeout;
@property (nonatomic, readonly, assign) uint32_t defaultSocketTimeout;
@property (nonatomic, readwrite, assign) uint32_t socketTimeout;

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