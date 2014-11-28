//
//  MHConnectionWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "NSString+MongoHub.h"
#import "MHConnectionWindowController.h"
#import "MHQueryViewController.h"
#import "MHEditNameWindowController.h"
#import "MHMysqlImportWindowController.h"
#import "MHMysqlExportWindowController.h"
#import "MHTunnel.h"
#import "MHClientItem.h"
#import "MHDatabaseItem.h"
#import "MHCollectionItem.h"
#import "SidebarBadgeCell.h"
#import "MHConnectionStore.h"
#import "MHFileExporter.h"
#import "MHFileImporter.h"
#import "MODHelper.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "MHStatusViewController.h"
#import "MHTabViewController.h"
#import "MHImportExportFeedback.h"
#import "MHDatabaseCollectionOutlineView.h"
#import "MHActivityMonitorViewController.h"

#define SERVER_STATUS_TOOLBAR_ITEM_TAG              0
#define DATABASE_STATUS_TOOLBAR_ITEM_TAG            1
#define COLLECTION_STATUS_TOOLBAR_ITEM_TAG          2
#define QUERY_TOOLBAR_ITEM_TAG                      3
#define MYSQL_IMPORT_TOOLBAR_ITEM_TAG               4
#define MYSQL_EXPORT_TOOLBAR_ITEM_TAG               5
#define FILE_IMPORT_TOOLBAR_ITEM_TAG                6
#define FILE_EXPORT_TOOLBAR_ITEM_TAG                7

@interface MHConnectionWindowController ()
@property (nonatomic, readwrite, strong) MHClientItem *clientItem;
@property (nonatomic, readwrite, strong) NSMutableDictionary *tabItemControllers;
@property (nonatomic, readwrite, strong) MHStatusViewController *statusViewController;
@property (nonatomic, readwrite, strong) MHActivityMonitorViewController *activityMonitorViewController;
@property (nonatomic, readwrite, weak) IBOutlet MHTabViewController *tabViewController;
@property (nonatomic, readwrite, strong) MHTunnel *sshTunnel;
@property (nonatomic, readwrite, strong) NSMutableDictionary *sshBindedPortMapping;

- (void)updateToolbarItems;

- (MHDatabaseItem *)selectedDatabaseItem;
- (MHCollectionItem *)selectedCollectionItem;

- (MODQuery *)getDatabaseList;
- (MODQuery *)getCollectionListForDatabaseItem:(MHDatabaseItem *)databaseItem;

- (void)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (void)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;
@end

@implementation MHConnectionWindowController

@synthesize delegate = _delegate;
@synthesize connectionStore = _connectionStore;
@synthesize client = _client;
@synthesize sshTunnel = _sshTunnel;
@synthesize sshBindedPortMapping = _sshBindedPortMapping;
@synthesize bundleVersion;
@synthesize mysqlImportWindowController = _mysqlImportWindowController;
@synthesize mysqlExportWindowController = _mysqlExportWindowController;
@synthesize loaderIndicator = _loaderIndicator;
@synthesize clientItem = _clientItem;
@synthesize tabItemControllers = _tabItemControllers;
@synthesize statusViewController = _statusViewController;
@synthesize activityMonitorViewController = _activityMonitorViewController;
@synthesize tabViewController = _tabViewController;

- (NSString *)windowNibName
{
    return @"MHConnectionWindow";
}

- (void)dealloc
{
    [self.window removeObserver:self forKeyPath:@"firstResponder"];
    [self.tabViewController removeObserver:self forKeyPath:@"selectedTabIndex"];
    self.tabItemControllers = nil;
    self.clientItem = nil;
    [_serverMonitorTimer invalidate];
    [_serverMonitorTimer release];
    _serverMonitorTimer = nil;
    self.connectionStore = nil;
    self.sshTunnel = nil;
    self.sshBindedPortMapping = nil;
    self.loaderIndicator = nil;
    self.bundleVersion = nil;
    self.mysqlImportWindowController = nil;
    self.mysqlExportWindowController = nil;
    self.statusViewController = nil;
    self.client = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    NSView *tabView = self.tabViewController.view;
    
    self.tabItemControllers = [NSMutableDictionary dictionary];
    
    [[_splitView.subviews objectAtIndex:1] addSubview:tabView];
    tabView.frame = tabView.superview.bounds;
    [_databaseCollectionOutlineView setDoubleAction:@selector(outlineViewDoubleClickAction:)];
    [self updateToolbarItems];
    
    self.window.title = [NSString stringWithFormat:@"%@, Connecting…", self.connectionStore.alias];
    [self.tabViewController addObserver:self forKeyPath:@"selectedTabIndex" options:NSKeyValueObservingOptionNew context:nil];
    [self.window addObserver:self forKeyPath:@"firstResponder" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.tabViewController && [keyPath isEqualToString:@"selectedTabIndex"])
        || (object == self.window && [keyPath isEqualToString:@"firstResponder"] && self.window.firstResponder != _databaseCollectionOutlineView && self.window.firstResponder != self.window)) {
// update the outline view selection if the tab changed, or if the first responder changed
// don't do it if the first responder is the outline view or the windw, other we will lose the new user selection
        id selectedTab = self.tabViewController.selectedTabItemViewController;
        
        if ([selectedTab isKindOfClass:[MHQueryViewController class]]) {
            NSIndexSet *indexes = nil;
            MHDatabaseItem *databaseOutlineViewItem;
            MHCollectionItem *collectionOutlineViewItem;
            
            databaseOutlineViewItem = [self.clientItem databaseItemWithName:[(MHQueryViewController *)selectedTab collection].database.name];
            collectionOutlineViewItem = [databaseOutlineViewItem collectionItemWithName:[(MHQueryViewController *)selectedTab collection].name];
            if (collectionOutlineViewItem) {
                [_databaseCollectionOutlineView expandItem:databaseOutlineViewItem];
                indexes = [[NSIndexSet alloc] initWithIndex:[_databaseCollectionOutlineView rowForItem:collectionOutlineViewItem]];
            } else if (databaseOutlineViewItem) {
                indexes = [[NSIndexSet alloc] initWithIndex:[_databaseCollectionOutlineView rowForItem:databaseOutlineViewItem]];
            }
            if (indexes) {
                [_databaseCollectionOutlineView selectRowIndexes:indexes byExtendingSelection:NO];
                [indexes release];
            }
        } else if ([selectedTab isKindOfClass:[MHStatusViewController class]]) {
            
        }
    }
}

- (void)connectToServer
{
    [self.loaderIndicator startAnimation:nil];
    if (self.sshTunnel == nil && self.connectionStore.useSSH.boolValue) {
        self.sshBindedPortMapping = [NSMutableDictionary dictionary];
        self.sshTunnel = [[[MHTunnel alloc] init] autorelease];
        self.sshTunnel.verbose = [self.delegate connectionWindowControllerSSHVerbose:self];
        self.sshTunnel.delegate = self;
        self.sshTunnel.user = self.connectionStore.sshUser;
        self.sshTunnel.host = self.connectionStore.sshHost;
        self.sshTunnel.password = self.connectionStore.sshPassword;
        self.sshTunnel.keyfile = self.connectionStore.sshKeyFileName.stringByExpandingTildeInPath;
        self.sshTunnel.port = self.connectionStore.sshPort.intValue;
        self.sshTunnel.aliveCountMax = 3;
        self.sshTunnel.aliveInterval = 30;
        self.sshTunnel.tcpKeepAlive = YES;
        self.sshTunnel.compression = YES;
        for (NSString *hostnameAndPort in self.connectionStore.arrayServers) {
            NSInteger hostPort, sshBindedPort;
            NSString *hostAddress;
            NSString *hostAndPortString;
            
            sshBindedPort = [MHTunnel findFreeTCPPort];
            hostAddress = [MHConnectionStore hostnameFromServer:hostnameAndPort withPort:&hostPort];
            if (hostPort == 0) {
                hostPort = MODClient.defaultPort;
            }
            if (hostAddress.length == 0) {
                hostAddress = @"127.0.0.1";
            }
            [self.sshTunnel addForwardingPortWithBindAddress:nil bindPort:sshBindedPort hostAddress:hostAddress hostPort:hostPort reverseForwarding:NO];
            hostAndPortString = [NSString stringWithFormat:@"%@:%ld", hostAddress, (long)hostPort];
            [self.sshBindedPortMapping setObject:[NSNumber numberWithInteger:sshBindedPort] forKey:hostAndPortString];
            [self.delegate connectionWindowControllerLogMessage:[NSString stringWithFormat:@"mapping 127.0.0.1:%ld => %@", (long)sshBindedPort, hostAndPortString] domain:[NSString stringWithFormat:@"%@.url", self.connectionStore.alias] level:@"debug"];
        }
        [self.sshTunnel start];
        return;
    } else {
        NSString *urlString;
        
        urlString = [self.connectionStore stringURLWithSSHMapping:nil];
        [self.delegate connectionWindowControllerLogMessage:urlString domain:[NSString stringWithFormat:@"%@.url", self.connectionStore.alias] level:@"debug"];
        self.client = [MODClient clientWihtURLString:urlString];
        self.client.sshMapping = self.sshBindedPortMapping;
        if (self.connectionStore.useSSL) {
            self.client.sslOptions = [[[MODSSLOptions alloc] initWithPemFileName:nil pemPassword:nil caFileName:nil caDirectory:nil crlFileName:nil weakCertificate:self.connectionStore.weakCertificate.boolValue] autorelease];
        }
        self.client.readPreferences = [MODReadPreferences readPreferencesWithReadMode:self.connectionStore.defaultReadMode];
        [self.loaderIndicator stopAnimation:nil];
        
        self.clientItem = [[[MHClientItem alloc] initWithClient:self.client] autorelease];
        [self showServerStatus:nil];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    bundleVersion.stringValue = [NSString stringWithFormat:@"version: %@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
    [self connectToServer];
    [_databaseCollectionOutlineView setDoubleAction:@selector(sidebarDoubleAction:)];
}

- (void)sidebarDoubleAction:(id)sender
{
    [self query:sender];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (notification.object == self.window) {
        [self.sshTunnel stop];
        [self.client cancelAllOperations];
        self.client = nil;
        [self.delegate connectionWindowControllerWillClose:self];
    }
}

- (MODQuery *)getDatabaseList
{
    MODQuery *result;
    
    [self.loaderIndicator startAnimation:nil];
    result = [self.client databaseNamesWithCallback:^(NSArray *list, MODQuery *mongoQuery) {
        [self.loaderIndicator stopAnimation:nil];
        self.window.title = self.connectionStore.alias;
        if (list != nil) {
            if ([self.clientItem updateChildrenWithList:list]) {
                [_databaseCollectionOutlineView reloadData];
            }
        } else if (self.connectionStore.defaultDatabase.length > 0) {
            if ([self.clientItem updateChildrenWithList:[NSArray arrayWithObject:self.connectionStore.defaultDatabase]]) {
                [_databaseCollectionOutlineView reloadData];
            }
        } else if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
        }
    }];
    return result;
}

- (void)getCollectionListForDatabaseName:(NSString *)databaseName
{
    MHDatabaseItem *databaseItem;
    
    databaseItem = [self.clientItem databaseItemWithName:databaseName];
    if (databaseItem) {
        [self getCollectionListForDatabaseItem:databaseItem];
    }
}

- (MODQuery *)getCollectionListForDatabaseItem:(MHDatabaseItem *)databaseItem
{
    MODDatabase *mongoDatabase;
    MODQuery *result;
    
    mongoDatabase = databaseItem.database;
    [self.loaderIndicator startAnimation:nil];
    result = [mongoDatabase collectionNamesWithCallback:^(NSArray *collectionList, MODQuery *mongoQuery) {
        MHDatabaseItem *databaseItem;
        
        [self.loaderIndicator stopAnimation:nil];
        databaseItem = [self.clientItem databaseItemWithName:mongoDatabase.name];
        if (collectionList && databaseItem) {
            if ([databaseItem updateChildrenWithList:collectionList]) {
                [_databaseCollectionOutlineView reloadData];
            }
        } else if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
        }
    }];
    return result;
}

- (void)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem
{
    if (self.statusViewController == nil) {
        self.statusViewController = [[[MHStatusViewController alloc] initWithClient:self.client connectionStore:self.connectionStore] autorelease];
        [self.tabViewController addTabItemViewController:self.statusViewController];
    }
    [self.statusViewController showDatabaseStatusWithDatabaseItem:databaseItem];
}

- (void)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem
{
    if (self.statusViewController == nil) {
        self.statusViewController = [[[MHStatusViewController alloc] initWithClient:self.client connectionStore:self.connectionStore] autorelease];
        [self.tabViewController addTabItemViewController:self.statusViewController];
    }
    [self.statusViewController showCollectionStatusWithCollectionItem:collectionItem];
}

- (IBAction)showServerStatus:(id)sender 
{
    if (self.statusViewController == nil) {
        self.statusViewController = [[[MHStatusViewController alloc] initWithClient:self.client connectionStore:self.connectionStore] autorelease];
        [self.tabViewController addTabItemViewController:self.statusViewController];
    }
    [self.statusViewController showServerStatus];
    [self.statusViewController select];
    [self getDatabaseList];
}

- (IBAction)showDatabaseStatus:(id)sender 
{
    [self showDatabaseStatusWithDatabaseItem:self.selectedDatabaseItem];
    [self.statusViewController select];
}

- (IBAction)showCollStats:(id)sender 
{
    [self showCollectionStatusWithCollectionItem:self.selectedCollectionItem];
    [self.statusViewController select];
}

- (IBAction)showActivityMonitorAction:(id)sender
{
    if (!self.activityMonitorViewController) {
        self.activityMonitorViewController = [[[MHActivityMonitorViewController alloc] initWithClient:self.client] autorelease];
        [self.tabViewController addTabItemViewController:self.activityMonitorViewController];
    }
    [self.activityMonitorViewController select];
}

- (void)outlineViewDoubleClickAction:(id)sender
{
}

- (void)menuWillOpen:(NSMenu *)menu
{
    if (menu == createCollectionOrDatabaseMenu) {
        [menu itemWithTag:2].enabled = self.selectedDatabaseItem != nil;
    }
}

- (IBAction)createDatabase:(id)sender
{
    MHEditNameWindowController *editNameWindowController;
    
    editNameWindowController = [[[MHEditNameWindowController alloc] initWithLabel:@"New Database Name:" editedValue:nil] autorelease];
    editNameWindowController.callback = ^(MHEditNameWindowController *controller) {
        [[self.client databaseForName:editNameWindowController.editedValue] statsWithReadPreferences:nil callback:nil];
        [self getDatabaseList];
    };
    [editNameWindowController modalForWindow:self.window];
}

- (IBAction)createCollection:(id)sender
{
    MODDatabase *database = self.selectedDatabaseItem.database;
    
    if (database) {
        MHEditNameWindowController *editNameWindowController;
        
        editNameWindowController = [[[MHEditNameWindowController alloc] initWithLabel:@"New Collection Name:" editedValue:nil] autorelease];
        editNameWindowController.callback = ^(MHEditNameWindowController *controller) {
            [database createCollectionWithName:editNameWindowController.editedValue callback:^(MODQuery *mongoQuery) {
                if (mongoQuery.error) {
                    NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
                }
                [self getCollectionListForDatabaseName:database.name];
            }];
        };
        [editNameWindowController modalForWindow:self.window];
    }
}

- (IBAction)renameCollection:(id)sender
{
    MODCollection *collection = self.selectedCollectionItem.collection;
    NSString *oldCollectionName = collection.absoluteName;
    
    if (collection) {
        MHEditNameWindowController *editNameWindowController;
        
        editNameWindowController = [[[MHEditNameWindowController alloc] initWithLabel:[NSString stringWithFormat:@"Rename %@:", collection.absoluteName] editedValue:collection.name] autorelease];
        editNameWindowController.callback = ^(MHEditNameWindowController *controller) {
            [collection renameWithNewDatabase:nil newCollectionName:editNameWindowController.editedValue dropTargetBeforeRenaming:NO callback:^(MODQuery *mongoQuery) {
                if (collection.absoluteName != oldCollectionName) {
                    MHTabItemViewController *tabItemController;
                    
                    tabItemController = self.tabItemControllers[oldCollectionName];
                    [tabItemController retain];
                    [self.tabItemControllers removeObjectForKey:oldCollectionName];
                    self.tabItemControllers[collection.absoluteName] = tabItemController;
                    tabItemController.title = collection.absoluteName;
                    [tabItemController release];
                }
                if (mongoQuery.error) {
                    NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
                }
                [self getCollectionListForDatabaseName:collection.database.name];
            }];
        };
        [editNameWindowController modalForWindow:self.window];
    }
}

- (IBAction)dropDatabaseOrCollection:(id)sender
{
    if (self.selectedCollectionItem) {
        [self dropWarning:self.selectedCollectionItem.collection.absoluteName];
    } else {
        [self dropWarning:self.selectedDatabaseItem.database.name];
    }
}

- (void)dropCollection:(MODCollection *)collection
{
    if (collection) {
        NSString *databaseName = collection.database.name;
        
        [self.loaderIndicator startAnimation:nil];
        [collection dropWithCallback:^(MODQuery *mongoQuery) {
            [self.loaderIndicator stopAnimation:nil];
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
            } else {
                MHTabItemViewController *tabItemViewController = self.tabItemControllers[collection.absoluteName];
                
                if (tabItemViewController) {
                    [self.tabViewController removeTabItemViewController:tabItemViewController];
                }
                [self getCollectionListForDatabaseName:databaseName];
            }
        }];
    }
}

- (void)dropDatabase
{
    MODDatabase *database = self.selectedDatabaseItem.database;
    
    NSParameterAssert(database);
    [self.loaderIndicator startAnimation:nil];
    [database dropWithCallback:^(MODQuery *mongoQuery) {
        [self.loaderIndicator stopAnimation:nil];
        [self getDatabaseList];
        if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
        }
    }];
}

- (IBAction)query:(id)sender
{
    if (!self.selectedCollectionItem) {
        if (![_databaseCollectionOutlineView isItemExpanded:[_databaseCollectionOutlineView itemAtRow:[_databaseCollectionOutlineView selectedRow]]]) {
            [_databaseCollectionOutlineView expandItem:[_databaseCollectionOutlineView itemAtRow:[_databaseCollectionOutlineView selectedRow]] expandChildren:NO];
        } else {
            [_databaseCollectionOutlineView collapseItem:[_databaseCollectionOutlineView itemAtRow:[_databaseCollectionOutlineView selectedRow]]];
        }
    } else {
        MHQueryViewController *queryWindowController;
        
        queryWindowController = self.tabItemControllers[self.selectedCollectionItem.collection.absoluteName];
        if (queryWindowController == nil) {
            queryWindowController = [[[MHQueryViewController alloc] initWithCollection:self.selectedCollectionItem.collection connectionStore:self.connectionStore] autorelease];
            self.tabItemControllers[self.selectedCollectionItem.collection.absoluteName] = queryWindowController;
            [self.tabViewController addTabItemViewController:queryWindowController];
        }
        [queryWindowController select];
    }
}

- (void)dropWarningDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertSecondButtonReturn)
    {
        if (self.selectedCollectionItem) {
            [self dropCollection:self.selectedCollectionItem.collection];
        }else {
            [self dropDatabase];
        }
    }
}

- (void)dropWarning:(NSString *)msg
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"Drop \"%@\"?", msg]];
    [alert setInformativeText:[NSString stringWithFormat:@"Dropping \"%@\" cannot be restored.", msg]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self
                     didEndSelector:@selector(dropWarningDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (MHDatabaseItem *)selectedDatabaseItem
{
    MHDatabaseItem *result = nil;
    NSInteger index;
    
    index = [_databaseCollectionOutlineView selectedRow];
    if (index != -1) {
        id item;
        
        item = [_databaseCollectionOutlineView itemAtRow:index];
        if ([item isKindOfClass:[MHDatabaseItem class]]) {
            result = item;
        } else if ([item isKindOfClass:[MHCollectionItem class]]) {
            result = [item databaseItem];
        }
    }
    return result;
}

- (MHCollectionItem *)selectedCollectionItem
{
    MHCollectionItem *result = nil;
    NSInteger index;
    
    index = [_databaseCollectionOutlineView selectedRow];
    if (index != -1) {
        id item;
        
        item = [_databaseCollectionOutlineView itemAtRow:index];
        if ([item isKindOfClass:[MHCollectionItem class]]) {
            result = item;
        }
    }
    return result;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.connectionStore.managedObjectContext;
}

- (void)updateToolbarItems
{
    for (NSToolbarItem *item in [_toolbar items]) {
        switch ([item tag]) {
            case DATABASE_STATUS_TOOLBAR_ITEM_TAG:
                item.enabled = self.selectedDatabaseItem != nil;
                break;
                
            case COLLECTION_STATUS_TOOLBAR_ITEM_TAG:
            case QUERY_TOOLBAR_ITEM_TAG:
            case MYSQL_IMPORT_TOOLBAR_ITEM_TAG:
            case MYSQL_EXPORT_TOOLBAR_ITEM_TAG:
            case FILE_IMPORT_TOOLBAR_ITEM_TAG:
            case FILE_EXPORT_TOOLBAR_ITEM_TAG:
                item.enabled = self.selectedCollectionItem != nil;
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)windowShouldClose:(id)sender
{
    // only close tabs when using cmd-w, if the current is event is not a key down
    // (probably mouse down), just close the window
    if (NSApplication.sharedApplication.currentEvent.type != NSKeyDown) {
        return YES;
    } else if (self.tabViewController.tabCount <= 1) {
        return YES;
    } else {
        [self.tabViewController removeTabItemViewController:self.tabViewController.selectedTabItemViewController];
        return NO;
    }
}

@end

@implementation MHConnectionWindowController (ImportExport)

- (void)importerExporterStopNotification:(NSNotification *)notification
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:nil object:_importerExporter];
    [_importerExporter autorelease];
    _importerExporter = nil;
    [_importExportFeedback close];
    [_importExportFeedback autorelease];
    _importExportFeedback = nil;
}

- (void)exportSelectedCollectionToFilePath:(NSString *)filePath
{
    MHFileExporter *exporter;
    
    exporter = [[MHFileExporter alloc] initWithCollection:self.selectedCollectionItem.collection exportPath:filePath];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(importerExporterStopNotification:) name:MHImporterExporterStopNotification object:exporter];
    _importExportFeedback = [[MHImportExportFeedback alloc] initWithImporterExporter:exporter];
    _importExportFeedback.label = [NSString stringWithFormat:@"Exporting %@ to %@…", self.selectedCollectionItem.collection.absoluteName, [filePath lastPathComponent]];
    [_importExportFeedback start];
    [_importExportFeedback displayForWindow:self.window];
    [exporter export];
    _importerExporter = exporter;
}

- (void)importIntoSelectedCollectionFromFilePath:(NSString *)filePath
{
    MHFileImporter *importer;
    
    NSAssert(_importExportFeedback == nil, @"we should have no more feedback controller");
    importer = [[MHFileImporter alloc] initWithCollection:self.selectedCollectionItem.collection importPath:filePath];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(importerExporterStopNotification:) name:MHImporterExporterStopNotification object:importer];
    _importExportFeedback = [[MHImportExportFeedback alloc] initWithImporterExporter:importer];
    _importExportFeedback.label = [NSString stringWithFormat:@"Importing %@ into %@…", [filePath lastPathComponent], self.selectedCollectionItem.collection.absoluteName];
    [_importExportFeedback start];
    [_importExportFeedback displayForWindow:self.window];
    [importer import];
    _importerExporter = importer;
}

- (IBAction)importFromMySQLAction:(id)sender
{
    if (self.selectedDatabaseItem == nil) {
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, NULL, NULL, nil, @"Please specify a database!");
        return;
    }
    if (!_mysqlImportWindowController) {
        _mysqlImportWindowController = [[MHMysqlImportWindowController alloc] init];
    }
    _mysqlImportWindowController.database = self.selectedDatabaseItem.database;
    if (self.selectedCollectionItem) {
        [_mysqlExportWindowController.collectionTextField setStringValue:[self.selectedCollectionItem.collection name]];
    }
    [_mysqlImportWindowController showWindow:self];
}

- (IBAction)exportToMySQLAction:(id)sender
{
    if (self.selectedCollectionItem == nil) {
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, NULL, NULL, nil, @"Please specify a collection!");
        return;
    }
    if (!_mysqlExportWindowController) {
        _mysqlExportWindowController = [[MHMysqlExportWindowController alloc] init];
    }
    _mysqlExportWindowController.mongoDatabase = self.selectedDatabaseItem.database;
    _mysqlExportWindowController.dbname = self.selectedDatabaseItem.database.name;
    if (self.selectedCollectionItem) {
        [_mysqlExportWindowController.collectionTextField setStringValue:[self.selectedCollectionItem.collection name]];
    }
    [_mysqlExportWindowController showWindow:self];
}

- (IBAction)importFromFileAction:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            // wait until the panel is closed to open the import feedback window
            [self performSelectorOnMainThread:@selector(importIntoSelectedCollectionFromFilePath:) withObject:[[openPanel URL] path] waitUntilDone:NO];
        }
    }];
}

- (IBAction)exportToFileAction:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    savePanel.nameFieldStringValue = [NSString stringWithFormat:@"%@-%@", self.selectedDatabaseItem.database.name, self.selectedCollectionItem.collection.name];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            // wait until the panel is closed to open the import feedback window
            [self performSelectorOnMainThread:@selector(exportSelectedCollectionToFilePath:) withObject:savePanel.URL.path waitUntilDone:NO];
        }
    }];
}

@end

@implementation MHConnectionWindowController(NSOutlineViewDataSource)

- (NSMenu *)databaseCollectionOutlineView:(MHDatabaseCollectionOutlineView *)outlineView contextualMenuWithEvent:(NSEvent *)event
{
    NSMenu *result;
    id item;
    NSInteger index;
    
    result = [[[NSMenu alloc] init] autorelease];
    index = _databaseCollectionOutlineView.selectedRow;
    item = [_databaseCollectionOutlineView itemAtRow:index];
    if (_databaseCollectionOutlineView.selectedRowIndexes.count == 0) {
        [result addItemWithTitle:@"New Database…" action:@selector(createDatabase:) keyEquivalent:@""].target = self;
    } else if ([item isKindOfClass:[MHDatabaseItem class]]) {
        [result addItemWithTitle:[NSString stringWithFormat:@"%@ Stats", [item name]] action:@selector(showDatabaseStatus:) keyEquivalent:@""].target = self;
        [result addItemWithTitle:[NSString stringWithFormat:@"Drop %@…", [item name]] action:@selector(dropDatabaseOrCollection:) keyEquivalent:@""].target = self;
        [result addItem:[NSMenuItem separatorItem]];
        [result addItemWithTitle:@"New Database…" action:@selector(createDatabase:) keyEquivalent:@""].target = self;
        [result addItemWithTitle:@"New Collection…" action:@selector(createCollection:) keyEquivalent:@""].target = self;
    } else if ([item isKindOfClass:[MHCollectionItem class]]) {
        [result addItemWithTitle:[NSString stringWithFormat:@"Open %@", [item name]] action:@selector(query:) keyEquivalent:@""].target = self;
        [result addItemWithTitle:[NSString stringWithFormat:@"%@ Stats", [item name]] action:@selector(showCollStats:) keyEquivalent:@""].target = self;
        [result addItemWithTitle:[NSString stringWithFormat:@"Rename %@…", [item name]] action:@selector(renameCollection:) keyEquivalent:@""].target = self;
        [result addItemWithTitle:[NSString stringWithFormat:@"Drop %@…", [item name]] action:@selector(dropDatabaseOrCollection:) keyEquivalent:@""].target = self;
        [result addItem:[NSMenuItem separatorItem]];
        [result addItemWithTitle:@"New Database…" action:@selector(createDatabase:) keyEquivalent:@""].target = self;
        [result addItemWithTitle:@"New Collection…" action:@selector(createCollection:) keyEquivalent:@""].target = self;
    }
    return result;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item) {
        return self.clientItem.databaseItems.count;
    } else if ([item isKindOfClass:[MHDatabaseItem class]]) {
        return [item sortedCollectionNames].count;
    } else {
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        return [self.clientItem.databaseItems objectAtIndex:index];
    } else if ([item isKindOfClass:[MHDatabaseItem class]]) {
        NSString *collectionName = [item sortedCollectionNames][index];
        
        return [item collectionItems][collectionName];
    } else {
        return nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return !item || [item isKindOfClass:[MHDatabaseItem class]];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return [item name];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    MHCollectionItem *collectionItem = self.selectedCollectionItem;
    MHDatabaseItem *databaseItem = self.selectedDatabaseItem;
    
    if (collectionItem && !collectionItem.collection.dropped) {
        [self getCollectionListForDatabaseItem:collectionItem.databaseItem];
        [self showCollectionStatusWithCollectionItem:collectionItem];
        if (self.tabItemControllers[collectionItem.collection.absoluteName]) {
            [self.tabItemControllers[collectionItem.collection.absoluteName] select];
        } else {
            [self.statusViewController select];
        }
    } else if (databaseItem && !databaseItem.database.dropped) {
        [self getCollectionListForDatabaseItem:databaseItem];
        [self showDatabaseStatusWithDatabaseItem:databaseItem];
    } else {
        [self.statusViewController showServerStatus];
    }
    [self updateToolbarItems];
    [self getDatabaseList];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    [cell setHasBadge:NO];
    [cell setIcon:nil];
    if ([item isKindOfClass:[MHCollectionItem class]]) {
        [cell setIcon:[NSImage imageNamed:@"collectionicon"]];
    } else if ([item isKindOfClass:[MHDatabaseItem class]]) {
        [cell setIcon:[NSImage imageNamed:@"dbicon"]];
        [cell setHasBadge:[item collectionItems].count > 0];
        [cell setBadgeCount:[item collectionItems].count];
    }
}

- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    [self getCollectionListForDatabaseItem:[[notification userInfo] objectForKey:@"NSObject"]];
}

@end

@implementation MHConnectionWindowController(MHTabViewControllerDelegate)

- (void)tabViewController:(MHTabViewController *)tabViewController didRemoveTabItem:(MHTabItemViewController *)tabItemViewController
{
    if (tabItemViewController == self.statusViewController) {
        self.statusViewController = nil;
    } else if (tabItemViewController == self.activityMonitorViewController) {
        self.activityMonitorViewController = nil;
    } else {
        [self.tabItemControllers removeObjectForKey:[(MHQueryViewController *)tabItemViewController collection].absoluteName];
    }
}

@end

@implementation MHConnectionWindowController(MHTunnelDelegate)

- (void)tunnelDidConnect:(MHTunnel *)tunnel
{
    [self.delegate connectionWindowControllerLogMessage:@"connected" domain:[NSString stringWithFormat:@"%@.ssh", self.connectionStore.alias] level:@"info"];
    [self connectToServer];
}

- (void)tunnelDidFailToConnect:(MHTunnel *)tunnel withError:(NSError *)error;
{
    [self.delegate connectionWindowControllerLogMessage:error.description domain:[NSString stringWithFormat:@"%@.ssh", self.connectionStore.alias] level:@"error"];
    if (!tunnel.connected) {
        // after being connected, we don't really care about errors
        [self.loaderIndicator stopAnimation:nil];
        self.statusViewController.title = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", error.localizedDescription);
    }
}

- (void)tunnelLogMessage:(NSString *)message
{
    [self.delegate connectionWindowControllerLogMessage:message domain:[NSString stringWithFormat:@"%@.ssh", self.connectionStore.alias] level:@"debug"];
}

@end
