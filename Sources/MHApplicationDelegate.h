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
@class MHPreferenceController;

typedef enum {
    MHSoftwareUpdateChannelDefault,
    MHSoftwareUpdateChannelBeta
} MHSoftwareUpdateChannel;

@interface MHApplicationDelegate : NSObject <NSApplicationDelegate, NSCollectionViewDelegate>
{
    NSWindow                                *_window;
    
    NSPersistentStoreCoordinator            *persistentStoreCoordinator;
    NSManagedObjectModel                    *managedObjectModel;
    NSManagedObjectContext                  *managedObjectContext;
    MHConnectionEditorWindowController      *_connectionEditorWindowController;
    NSMutableArray                          *_urlConnectionEditorWindowControllers;
    NSMutableArray                          *_connectionWindowControllers;
    MHPreferenceController                  *_preferenceController;
    
    MHConnectionCollectionView              *_connectionCollectionView;
    ConnectionsArrayController              *_connectionsArrayController;
    NSTextField                             *_bundleVersion;
    NSPanel                                 *_supportPanel;
    
    SUUpdater                               *_updater;
}

@property (nonatomic, strong, readonly) NSWindow *window;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign, readwrite) MHSoftwareUpdateChannel softwareUpdateChannel;

@end

@interface MHApplicationDelegate (MHConnectionEditorWindowControllerDelegate) <MHConnectionEditorWindowControllerDelegate>
@end

@interface MHApplicationDelegate (MHConnectionViewItemDelegate) <MHConnectionCollectionViewDelegate>
@end

@interface MHApplicationDelegate (MHConnectionWindowControllerDelegate) <MHConnectionWindowControllerDelegate>
@end
