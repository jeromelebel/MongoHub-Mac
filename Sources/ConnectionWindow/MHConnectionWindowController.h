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
@class DatabasesArrayController;
@class StatMonitorTableController;
@class MHAddDBController;
@class MHAddCollectionController;
@class AuthWindowController;
@class MHMysqlImportWindowController;
@class MHMysqlExportWindowController;
@class MHResultsOutlineViewController;
@class MHConnectionStore;
@class MODServer;
@class MODDatabase;
@class MODCollection;
@class MODSortedMutableDictionary;
@class MHTabTitleView;
@class MHStatusViewController;
@class MHImportExportFeedback;

@protocol MHImporterExporter;

@interface MHConnectionWindowController : NSWindowController
{
    NSMutableDictionary *_tabItemControllers;
    IBOutlet NSMenu *createCollectionOrDatabaseMenu;
    IBOutlet DatabasesArrayController *_databaseStoreArrayController;
    
    MHStatusViewController *_statusViewController;
    IBOutlet MHTabViewController *_tabViewController;
    IBOutlet NSSplitView *_splitView;
    
    MHServerItem *_serverItem;
    MHConnectionStore *_connectionStore;
    MODServer *_mongoServer;
    NSTimer *_serverMonitorTimer;
    IBOutlet NSOutlineView *_databaseCollectionOutlineView;
    IBOutlet NSTextField *resultsTitle;
    IBOutlet NSProgressIndicator *loaderIndicator;
    IBOutlet NSButton *reconnectButton;
    IBOutlet NSButton *monitorButton;
    IBOutlet NSPanel *monitorPanel;
    IBOutlet StatMonitorTableController *statMonitorTableController;
    IBOutlet NSToolbar *_toolbar;
    NSMutableArray *_databases;
    MHTunnel                                *_sshTunnel;
    unsigned short                          _sshTunnelPort;
    MHAddDBController                       *_addDBController;
    MHAddCollectionController               *_addCollectionController;
    AuthWindowController *authWindowController;
    MHMysqlImportWindowController *_mysqlImportWindowController;
    MHMysqlExportWindowController *_mysqlExportWindowController;
    IBOutlet NSTextField *bundleVersion;
    BOOL monitorStopped;
    
    IBOutlet NSView *_mainTabView;
    IBOutlet MHTabTitleView *_tabTitleView;
    
    MODSortedMutableDictionary *previousServerStatusForDelta;
    
    MHImportExportFeedback                  *_importExportFeedback;
    id<MHImporterExporter>                  _importerExporter;
}

@property (nonatomic, retain) MHConnectionStore *connectionStore;
@property (nonatomic, retain) MODServer *mongoServer;
@property (nonatomic, retain) NSMutableArray *databases;
@property (nonatomic, retain) MHTunnel *sshTunnel;
@property (nonatomic, retain) NSTextField *resultsTitle;
@property (nonatomic, retain) NSProgressIndicator *loaderIndicator;
@property (nonatomic, retain) NSButton *monitorButton;
@property (nonatomic, retain) NSButton *reconnectButton;
@property (nonatomic, retain) StatMonitorTableController *statMonitorTableController;
@property (nonatomic, retain) NSTextField *bundleVersion;
@property (nonatomic, retain) AuthWindowController *authWindowController;
@property (nonatomic, retain) MHMysqlImportWindowController *mysqlImportWindowController;
@property (nonatomic, retain) MHMysqlExportWindowController *mysqlExportWindowController;
@property (nonatomic, readonly, assign) NSManagedObjectContext *managedObjectContext;

- (IBAction)reconnect:(id)sender;
- (IBAction)showServerStatus:(id)sender;
- (IBAction)showCollStats:(id)sender;
- (IBAction)createDatabase:(id)sender;
- (IBAction)createCollection:(id)sender;
- (void)dropCollection:(NSString *)collectionname
                 ForDB:(NSString *)dbname;
- (void)createDB;
- (void)createCollectionForDB:(NSString *)dbname;
- (IBAction)dropDatabaseOrCollection:(id)sender;
- (IBAction)query:(id)sender;
- (IBAction)showAuth:(id)sender;
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

