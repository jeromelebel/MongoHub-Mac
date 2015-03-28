//
//  MHConnectionWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHClientItem.h"
#import "MHTunnel.h"
#import "MHTabViewController.h"

@class BWSheetController;
@class MHMysqlImportWindowController;
@class MHMysqlExportWindowController;
@class MHConnectionStore;
@class MODClient;
@class MODDatabase;
@class MODCollection;
@class MODSortedDictionary;
@class MHTabTitleView;
@class MHStatusViewController;
@class MHImportExportFeedback;
@class MHConnectionWindowController;
@class MHActivityMonitorViewController;

@protocol MHImporterExporter;

@protocol MHConnectionWindowControllerDelegate <NSObject>
- (void)connectionWindowControllerWillClose:(MHConnectionWindowController *)controller;
- (BOOL)connectionWindowControllerSSHVerbose:(MHConnectionWindowController *)controller;
- (void)connectionWindowControllerLogMessage:(NSString *)message domain:(NSString *)domain level:(NSString *)level;
@end

@interface MHConnectionWindowController : NSWindowController
{
    id<MHConnectionWindowControllerDelegate>_delegate;
    NSMutableDictionary                     *_tabItemControllers;
    NSMenu                                  *_createCollectionOrDatabaseMenu;
    
    MHStatusViewController                  *_statusViewController;
    MHActivityMonitorViewController         *_activityMonitorViewController;
    MHTabViewController                     *_tabViewController;
    NSSplitView                             *_splitView;
    
    MHClientItem                            *_clientItem;
    MHConnectionStore                       *_connectionStore;
    MODClient                               *_client;
    NSTimer                                 *_serverMonitorTimer;
    NSOutlineView                           *_databaseCollectionOutlineView;
    NSProgressIndicator                     *_loaderIndicator;
    NSToolbar                               *_toolbar;
    MHTunnel                                *_sshTunnel;
    NSMutableDictionary                     *_sshBindedPortMapping;
    MHMysqlImportWindowController           *_mysqlImportWindowController;
    MHMysqlExportWindowController           *_mysqlExportWindowController;
    NSTextField                             *_bundleVersion;
    
    NSView                                  *_mainTabView;
    MHTabTitleView                          *_tabTitleView;
    
    MHImportExportFeedback                  *_importExportFeedback;
    id<MHImporterExporter>                  _importerExporter;
}

@property (nonatomic, readwrite, assign) id<MHConnectionWindowControllerDelegate> delegate;
@property (nonatomic, readwrite, strong) MHConnectionStore *connectionStore;
@property (nonatomic, readwrite, strong) MODClient *client;
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

@end

@interface MHConnectionWindowController(ImportExport)
- (IBAction)importFromMySQLAction:(id)sender;
- (IBAction)exportToMySQLAction:(id)sender;
- (IBAction)importFromFileAction:(id)sender;
- (IBAction)exportToFileAction:(id)sender;

@end

@interface MHConnectionWindowController(NSOutlineViewDataSource) <NSOutlineViewDataSource>
@end

@interface MHConnectionWindowController(MHTabViewControllerDelegate)<MHTabViewControllerDelegate>
@end

@interface MHConnectionWindowController(MHTunnelDelegate)<MHTunnelDelegate>
@end

