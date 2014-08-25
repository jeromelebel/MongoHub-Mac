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

@class MHConnectionCollectionView;
@class ConnectionsArrayController;
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
    MHPreferenceController                  *_preferenceController;
    
    IBOutlet MHConnectionCollectionView     *_connectionCollectionView;
    IBOutlet ConnectionsArrayController     *connectionsArrayController;
    IBOutlet NSTextField                    *bundleVersion;
  
    IBOutlet NSPanel                        *supportPanel;
    SUUpdater                               *_updater;
}

@property (nonatomic, strong, readonly) NSWindow *window;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) MHConnectionCollectionView *connectionCollectionView;
@property (nonatomic, strong) ConnectionsArrayController *connectionsArrayController;
@property (nonatomic, strong) NSTextField *bundleVersion;
@property (nonatomic, assign, readwrite) MHSoftwareUpdateChannel softwareUpdateChannel;

@end

@interface MHApplicationDelegate (MHConnectionEditorWindowControllerDelegate) <MHConnectionEditorWindowControllerDelegate>
@end

@interface MHApplicationDelegate (MHConnectionViewItemDelegate) <MHConnectionCollectionViewDelegate>
@end