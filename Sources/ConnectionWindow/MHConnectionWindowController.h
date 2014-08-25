//
//  MHConnectionWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHServerItem.h"
#import "MHTunnel.h"
#import "MHTabViewController.h"

@class BWSheetController;
@class StatMonitorTableController;
@class MHAddDBController;
@class MHAddCollectionController;
@class MHMysqlImportWindowController;
@class MHMysqlExportWindowController;
@class MHResultsOutlineViewController;
@class MHConnectionStore;
@class MODClient;
@class MODDatabase;
@class MODCollection;
@class MODSortedMutableDictionary;
@class MHTabTitleView;
@class MHStatusViewController;
@class MHImportExportFeedback;
@class MHConnectionWindowController;

@protocol MHImporterExporter;

@protocol MHConnectionWindowControllerDelegate <NSObject>
- (void)connectionWindowControllerWillClose:(MHConnectionWindowController *)controller;
- (BOOL)connectionWindowControllerSSHVerbose:(MHConnectionWindowController *)controller;

@end

@interface MHConnectionWindowController : NSWindowController
{
    id<MHConnectionWindowControllerDelegate>_delegate;
    NSMutableDictionary                     *_tabItemControllers;
    IBOutlet NSMenu                         *createCollectionOrDatabaseMenu;
    
    MHStatusViewController                  *_statusViewController;
    MHTabViewController                     *_tabViewController;
    IBOutlet NSSplitView                    *_splitView;
    
    MHServerItem                            *_serverItem;
    MHConnectionStore                       *_connectionStore;
    MODClient                               *_client;
    NSTimer                                 *_serverMonitorTimer;
    IBOutlet NSOutlineView                  *_databaseCollectionOutlineView;
    IBOutlet NSTextField                    *resultsTitle;
    IBOutlet NSProgressIndicator            *_loaderIndicator;
    IBOutlet NSButton                       *monitorButton;
    IBOutlet NSPanel                        *monitorPanel;
    IBOutlet StatMonitorTableController     *statMonitorTableController;
    IBOutlet NSToolbar                      *_toolbar;
    NSMutableArray                          *_databases;
    MHTunnel                                *_sshTunnel;
    NSMutableDictionary                     *_sshBindedPortMapping;
    MHAddDBController                       *_addDBController;
    MHAddCollectionController               *_addCollectionController;
    MHMysqlImportWindowController           *_mysqlImportWindowController;
    MHMysqlExportWindowController           *_mysqlExportWindowController;
    IBOutlet NSTextField                    *bundleVersion;
    BOOL                                    monitorStopped;
    
    IBOutlet NSView                         *_mainTabView;
    IBOutlet MHTabTitleView                 *_tabTitleView;
    
    MODSortedMutableDictionary              *previousServerStatusForDelta;
    
    MHImportExportFeedback                  *_importExportFeedback;
    id<MHImporterExporter>                  _importerExporter;
}

@property (nonatomic, readwrite, assign) id<MHConnectionWindowControllerDelegate> delegate;
@property (nonatomic, readwrite, strong) MHConnectionStore *connectionStore;
@property (nonatomic, readwrite, strong) MODClient *client;
@property (nonatomic, readwrite, strong) NSMutableArray *databases;
@property (nonatomic, readwrite, strong) NSTextField *resultsTitle;
@property (nonatomic, readwrite, strong) NSProgressIndicator *loaderIndicator;
@property (nonatomic, readwrite, strong) NSButton *monitorButton;
@property (nonatomic, readwrite, strong) StatMonitorTableController *statMonitorTableController;
@property (nonatomic, readwrite, strong) NSTextField *bundleVersion;
@property (nonatomic, readwrite, strong) MHMysqlImportWindowController *mysqlImportWindowController;
@property (nonatomic, readwrite, strong) MHMysqlExportWindowController *mysqlExportWindowController;
@property (nonatomic, readonly, assign) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readonly, weak) IBOutlet MHTabViewController *tabViewController;

- (IBAction)showServerStatus:(id)sender;
- (IBAction)showCollStats:(id)sender;
- (IBAction)createDatabase:(id)sender;
- (IBAction)createCollection:(id)sender;
- (IBAction)dropDatabaseOrCollection:(id)sender;
- (IBAction)query:(id)sender;
- (void)connectToServer;
- (void)dropWarning:(NSString *)msg;

- (IBAction)startMonitor:(id)sender;
- (IBAction)stopMonitor:(id)sender;
@end

@interface MHConnectionWindowController(ImportExport)
- (IBAction)importFromMySQLAction:(id)sender;
- (IBAction)exportToMySQLAction:(id)sender;
- (IBAction)importFromFileAction:(id)sender;
- (IBAction)exportToFileAction:(id)sender;

@end

@interface MHConnectionWindowController(NSOutlineViewDataSource) <NSOutlineViewDataSource>
@end

@interface MHConnectionWindowController(MHServerItemDelegateCategory)<MHServerItemDelegate>
@end

@interface MHConnectionWindowController(MHTabViewControllerDelegate)<MHTabViewControllerDelegate>
@end

@interface MHConnectionWindowController(MHTunnelDelegate)<MHTunnelDelegate>
@end

