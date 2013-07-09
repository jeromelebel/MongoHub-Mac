//
//  MHConnectionWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Configure.h"
#import "NSString+Extras.h"
#import "NSProgressIndicator+Extras.h"
#import "MHConnectionWindowController.h"
#import "MHQueryWindowController.h"
#import "AddDBController.h"
#import "AddCollectionController.h"
#import "AuthWindowController.h"
#import "MHMysqlImportWindowController.h"
#import "MHMysqlExportWindowController.h"
#import "DatabasesArrayController.h"
#import "StatMonitorTableController.h"
#import "MHTunnel.h"
#import "MHServerItem.h"
#import "MHDatabaseItem.h"
#import "MHCollectionItem.h"
#import "SidebarBadgeCell.h"
#import "MHConnectionStore.h"
#import "MHDatabaseStore.h"
#import "MHFileExporter.h"
#import "MHFileImporter.h"
#import "MODHelper.h"
#import "MOD_public.h"
#import "MHStatusViewController.h"
#import "MHTabViewController.h"
#import "mongo.h"

#define SERVER_STATUS_TOOLBAR_ITEM_TAG              0
#define DATABASE_STATUS_TOOLBAR_ITEM_TAG            1
#define COLLECTION_STATUS_TOOLBAR_ITEM_TAG          2
#define QUERY_TOOLBAR_ITEM_TAG                      3
#define MYSQL_IMPORT_TOOLBAR_ITEM_TAG               4
#define MYSQL_EXPORT_TOOLBAR_ITEM_TAG               5
#define FILE_IMPORT_TOOLBAR_ITEM_TAG                6
#define FILE_EXPORT_TOOLBAR_ITEM_TAG                7

#define DEFAULT_MONGO_IP                            @"127.0.0.1"

@interface MHConnectionWindowController()
- (void)updateToolbarItems;

- (void)closeMongoDB;
- (void)fetchServerStatusDelta;

- (MHDatabaseItem *)selectedDatabaseItem;
- (MHCollectionItem *)selectedCollectionItem;

- (MODQuery *)getDatabaseList;
- (MODQuery *)getCollectionListForDatabaseItem:(MHDatabaseItem *)databaseItem;

- (void)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (void)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;
@end

@implementation MHConnectionWindowController

@synthesize connectionStore = _connectionStore;
@synthesize mongoServer = _mongoServer;
@synthesize loaderIndicator;
@synthesize monitorButton;
@synthesize reconnectButton;
@synthesize statMonitorTableController;
@synthesize databases = _databases;
@synthesize sshTunnel = _sshTunnel;
@synthesize addDBController;
@synthesize addCollectionController;
@synthesize resultsTitle;
@synthesize bundleVersion;
@synthesize authWindowController;
@synthesize mysqlImportWindowController = _mysqlImportWindowController;
@synthesize mysqlExportWindowController = _mysqlExportWindowController;


- (id)init
{
    if (self = [super initWithWindowNibName:@"MHConnectionWindow"]) {
        _databases = [[NSMutableArray alloc] init];
        _tabItemControllers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.window removeObserver:self forKeyPath:@"firstResponder"];
    [_tabViewController removeObserver:self forKeyPath:@"selectedTabIndex"];
    [_tabItemControllers release];
    [self closeMongoDB];
    [_connectionStore release];
    [_databases release];
    [_sshTunnel release];
    [addDBController release];
    [addCollectionController release];
    [resultsTitle release];
    [loaderIndicator release];
    [reconnectButton release];
    [monitorButton release];
    [statMonitorTableController release];
    [bundleVersion release];
    [authWindowController release];
    [_mysqlImportWindowController release];
    [_mysqlExportWindowController release];
    [_statusViewController release];
    [super dealloc];
}

- (void)closeMongoDB
{
    [_serverMonitorTimer invalidate];
    [_serverMonitorTimer release];
    _serverMonitorTimer = nil;
    [_mongoServer release];
    _mongoServer = nil;
    [_serverItem release];
    _serverItem = nil;
}

- (void)awakeFromNib
{
    NSView *tabView = _tabViewController.view;
    
    [[_splitView.subviews objectAtIndex:1] addSubview:tabView];
    tabView.frame = tabView.superview.bounds;
    _statusViewController = [[MHStatusViewController loadNewViewController] retain];
    [_tabViewController addTabItemViewController:_statusViewController];
    [_databaseCollectionOutlineView setDoubleAction:@selector(outlineViewDoubleClickAction:)];
    [self updateToolbarItems];
    
    if ([[_connectionStore userepl] intValue] == 1) {
        self.window.title = [NSString stringWithFormat:@"%@ [%@]", [_connectionStore alias], [_connectionStore repl_name]];
    } else {
        unsigned short hostPort = _connectionStore.hostport.intValue;
        NSString *host = [[_connectionStore host] stringByTrimmingWhitespace];
        
        if (host.length == 0) {
            host = DEFAULT_MONGO_IP;
        }
        if (hostPort == 0 || hostPort == MONGO_DEFAULT_PORT) {
            self.window.title = [NSString stringWithFormat:@"%@ [%@]", [_connectionStore alias], host];
        } else {
            self.window.title = [NSString stringWithFormat:@"%@ [%@:%d]", [_connectionStore alias], host, hostPort];
        }
    }
    [_tabViewController addObserver:self forKeyPath:@"selectedTabIndex" options:NSKeyValueObservingOptionNew context:nil];
    [self.window addObserver:self forKeyPath:@"firstResponder" options:NSKeyValueObservingOptionNew context:nil];
    _statusViewController.title = @"Connecting…";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == _tabViewController && [keyPath isEqualToString:@"selectedTabIndex"])
        || (object == self.window && [keyPath isEqualToString:@"firstResponder"] && self.window.firstResponder != _databaseCollectionOutlineView && self.window.firstResponder != self.window)) {
// update the outline view selection if the tab changed, or if the first responder changed
// don't do it if the first responder is the outline view or the windw, other we will lose the new user selection
        id selectedTab = _tabViewController.selectedTabItemViewController;
        
        if ([selectedTab isKindOfClass:[MHQueryWindowController class]]) {
            NSIndexSet *indexes = nil;
            MHDatabaseItem *databaseOutlineViewItem;
            MHCollectionItem *collectionOutlineViewItem;
            
            databaseOutlineViewItem = [_serverItem databaseItemWithName:[selectedTab mongoCollection].databaseName];
            collectionOutlineViewItem = [databaseOutlineViewItem collectionItemWithName:[selectedTab mongoCollection].collectionName];
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

- (void)didConnect
{
    [loaderIndicator stop];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDB:) name:kNewDBWindowWillClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCollection:) name:kNewCollectionWindowWillClose object:nil];
    [reconnectButton setEnabled:YES];
    [monitorButton setEnabled:YES];
    [self getDatabaseList];
    [self showServerStatus:nil];
}

- (void)didFailToConnectWithError:(NSError *)error
{
    [loaderIndicator stop];
    _statusViewController.title = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
}

- (void)connectToServer
{
    [loaderIndicator start];
    [reconnectButton setEnabled:NO];
    [monitorButton setEnabled:NO];
    if ((_sshTunnel == nil || !_sshTunnel.connected) && [_connectionStore.usessh intValue] == 1) {
        unsigned short hostPort;
        NSString *hostAddress;
        
        _sshTunnelPort = [MHTunnel findFreeTCPPort];
        if (!_sshTunnel) {
            _sshTunnel = [[MHTunnel alloc] init];
        }
        [_sshTunnel setDelegate:self];
        [_sshTunnel setUser:_connectionStore.sshuser];
        [_sshTunnel setHost:_connectionStore.sshhost];
        [_sshTunnel setPassword:_connectionStore.sshpassword];
        [_sshTunnel setKeyfile:[_connectionStore.sshkeyfile stringByExpandingTildeInPath]];
        [_sshTunnel setPort:[_connectionStore.sshport intValue]];
        [_sshTunnel setAliveCountMax:3];
        [_sshTunnel setAliveInterval:30];
        [_sshTunnel setTcpKeepAlive:YES];
        [_sshTunnel setCompression:YES];
        hostPort = (unsigned short)[_connectionStore.hostport intValue];
        if (hostPort == 0) {
            hostPort = MONGO_DEFAULT_PORT;
        }
        hostAddress = [_connectionStore.host stringByTrimmingWhitespace];
        if (hostAddress.length == 0) {
            hostAddress = @"127.0.0.1";
        }
        [_sshTunnel addForwardingPortWithBindAddress:nil bindPort:_sshTunnelPort hostAddress:hostAddress hostPort:hostPort reverseForwarding:NO];
        [_sshTunnel start];
        return;
    } else {
        [self closeMongoDB];
        _mongoServer = [[MODServer alloc] init];
        _serverItem = [[MHServerItem alloc] initWithMongoServer:_mongoServer delegate:self];
        _statusViewController.mongoServer = _mongoServer;
        _statusViewController.connectionStore = _connectionStore;
        if ([_connectionStore.adminuser length] > 0 && [_connectionStore.adminpass length] > 0) {
            _mongoServer.userName = _connectionStore.adminuser;
            _mongoServer.password = _connectionStore.adminpass;
            if ([_connectionStore.defaultdb length] > 0) {
                _mongoServer.authDatabase = _connectionStore.defaultdb;
            } else {
                _mongoServer.authDatabase = @"admin";
            }
        }
        if ([_connectionStore.userepl intValue] == 1) {
            NSArray *tmp = [_connectionStore.servers componentsSeparatedByString:@","];
            NSMutableArray *hosts = [[NSMutableArray alloc] initWithCapacity:[tmp count]];
            for (NSString *h in tmp) {
                NSString *host = [h stringByTrimmingWhitespace];
                if ([host length] == 0) {
                    continue;
                }
                [hosts addObject:host];
            }
            [_mongoServer connectWithReplicaName:_connectionStore.repl_name hosts:hosts callback:^(BOOL connected, MODQuery *mongoQuery) {
                if (connected) {
                    [self didConnect];
                } else {
                    [self didFailToConnectWithError:mongoQuery.error];
                }
            }];
            [hosts release];
        } else {
            NSString *hostaddress;
            
            if ([_connectionStore.usessh intValue] == 1) {
                hostaddress = [[NSString alloc] initWithFormat:@"127.0.0.1:%d", (int)_sshTunnelPort];
            } else {
                NSString *host = [_connectionStore.host stringByTrimmingWhitespace];
                NSNumber *hostport = _connectionStore.hostport;
                
                if (host.length == 0) {
                    host = DEFAULT_MONGO_IP;
                }
                if (hostport.intValue == 0) {
                    hostport = [NSNumber numberWithInt:MONGO_DEFAULT_PORT];
                }
                hostaddress = [[NSString alloc] initWithFormat:@"%@:%@", host, hostport];
            }
            NSLog(@"connecting to %@", hostaddress);
            [_mongoServer connectWithHostName:hostaddress callback:^(BOOL connected, MODQuery *mongoQuery) {
                if (connected) {
                    [self didConnect];
                } else {
                    [self didFailToConnectWithError:mongoQuery.error];
                }
            }];
            [hostaddress release];
        }
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@[%@])", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
    [self connectToServer];
    [_databaseCollectionOutlineView setDoubleAction:@selector(sidebarDoubleAction:)];
}

- (void)sidebarDoubleAction:(id)sender
{
    [self query:sender];
}

- (IBAction)reconnect:(id)sender
{
    [self connectToServer];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (_sshTunnel.isRunning) {
        [_sshTunnel stop];
    }
    [self release];
}

- (MODQuery *)getDatabaseList
{
    MODQuery *result;
    
    [loaderIndicator start];
    result = [_mongoServer fetchDatabaseListWithCallback:^(NSArray *list, MODQuery *mongoQuery) {
        [loaderIndicator stop];
        if (list != nil) {
            if ([_serverItem updateChildrenWithList:list]) {
                [_databaseCollectionOutlineView reloadData];
            }
        } else if (_connectionStore.defaultdb) {
            if ([_serverItem updateChildrenWithList:[NSArray arrayWithObject:_connectionStore.defaultdb]]) {
                [_databaseCollectionOutlineView reloadData];
            }
        } else if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        }
        
        [_databaseStoreArrayController clean:_connectionStore databases:_databases];
    }];
    return result;
}

- (void)getCollectionListForDatabaseName:(NSString *)databaseName
{
    MHDatabaseItem *databaseItem;
    
    databaseItem = [_serverItem databaseItemWithName:databaseName];
    if (databaseItem) {
        [self getCollectionListForDatabaseItem:databaseItem];
    }
}

- (MODQuery *)getCollectionListForDatabaseItem:(MHDatabaseItem *)databaseItem
{
    MODDatabase *mongoDatabase;
    MODQuery *result;
    
    mongoDatabase = databaseItem.mongoDatabase;
    [loaderIndicator start];
    result = [mongoDatabase fetchCollectionListWithCallback:^(NSArray *collectionList, MODQuery *mongoQuery) {
        MHDatabaseItem *databaseItem;
        
        [loaderIndicator stop];
        databaseItem = [_serverItem databaseItemWithName:mongoDatabase.databaseName];
        if (collectionList && databaseItem) {
            if ([databaseItem updateChildrenWithList:collectionList]) {
                [_databaseCollectionOutlineView reloadData];
            }
        } else if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        }
    }];
    return result;
}

- (void)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem
{
    if (_statusViewController == nil) {
        _statusViewController = [[MHStatusViewController loadNewViewController] retain];
        _statusViewController.mongoServer = _mongoServer;
        _statusViewController.connectionStore = _connectionStore;
        [_tabViewController addTabItemViewController:_statusViewController];
    }
    [_statusViewController showDatabaseStatusWithDatabaseItem:databaseItem];
}

- (void)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem
{
    if (_statusViewController == nil) {
        _statusViewController = [[MHStatusViewController loadNewViewController] retain];
        _statusViewController.mongoServer = _mongoServer;
        _statusViewController.connectionStore = _connectionStore;
        [_tabViewController addTabItemViewController:_statusViewController];
    }
    [_statusViewController showCollectionStatusWithCollectionItem:collectionItem];
}

- (IBAction)showServerStatus:(id)sender 
{
    if (_statusViewController == nil) {
        _statusViewController = [[MHStatusViewController loadNewViewController] retain];
        _statusViewController.mongoServer = _mongoServer;
        _statusViewController.connectionStore = _connectionStore;
        [_tabViewController addTabItemViewController:_statusViewController];
    }
    [_statusViewController showServerStatus];
}

- (IBAction)showDatabaseStatus:(id)sender 
{
    [self showDatabaseStatusWithDatabaseItem:[self selectedDatabaseItem]];
}

- (IBAction)showCollStats:(id)sender 
{
    [self showCollectionStatusWithCollectionItem:[self selectedCollectionItem]];
}

- (void)outlineViewDoubleClickAction:(id)sender
{
    NSLog(@"test");
}

- (void)menuWillOpen:(NSMenu *)menu
{
    if (menu == createCollectionOrDatabaseMenu) {
        [[menu itemWithTag:2] setEnabled:[self selectedDatabaseItem] != nil];
    }
}

- (IBAction)createDatabase:(id)sender
{
    [self createDB];
}

- (IBAction)createCollection:(id)sender
{
    if ([self selectedDatabaseItem]) {
        [self createCollectionForDB:[[self selectedDatabaseItem].mongoDatabase databaseName]];
    }
}

- (void)createCollectionForDB:(NSString *)dbname
{
    if (!addCollectionController) {
        addCollectionController = [[AddCollectionController alloc] init];
    }
    addCollectionController.dbname = dbname;
    [addCollectionController showWindow:self];
}

- (void)createDB
{
    if (!addDBController)
    {
        addDBController = [[AddDBController alloc] init];
    }
    addDBController.conn = _connectionStore;
    [addDBController showWindow:self];
}

- (void)addDB:(id)sender
{
    if (![sender object]) {
        return;
    }
    [[_mongoServer databaseForName:[[sender object] objectForKey:@"dbname"]] fetchDatabaseStatsWithCallback:nil];
    [self getDatabaseList];
}

- (void)addCollection:(id)sender
{
    if (![sender object]) {
        return;
    }
    NSString *collectionName = [[sender object] objectForKey:@"collectionname"];
    MODDatabase *mongoDatabase;
    
    mongoDatabase = [[self selectedDatabaseItem] mongoDatabase];
    [loaderIndicator start];
    [mongoDatabase createCollectionWithName:collectionName callback:^(MODQuery *mongoQuery) {
        [loaderIndicator stop];
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        }
        [self getCollectionListForDatabaseName:mongoDatabase.databaseName];
    }];
}

- (IBAction)dropDBorCollection:(id)sender
{
    if ([self selectedCollectionItem]) {
        [self dropWarning:[NSString stringWithFormat:@"COLLECTION:%@", [[[self selectedCollectionItem] mongoCollection] absoluteCollectionName]]];
    }else {
        [self dropWarning:[NSString stringWithFormat:@"DB:%@", [[self selectedDatabaseItem].mongoDatabase databaseName]]];
    }
}

- (void)dropCollection:(NSString *)collectionName ForDB:(NSString *)dbname
{
    MHDatabaseItem *databaseItem;
    
    databaseItem = [self selectedDatabaseItem];
    if (databaseItem) {
        [loaderIndicator start];
        [databaseItem.mongoDatabase dropCollectionWithName:collectionName callback:^(MODQuery *mongoQuery) {
            [loaderIndicator stop];
            if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
            } else {
                [self getCollectionListForDatabaseName:dbname];
            }
        }];
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent.charactersIgnoringModifiers isEqualToString:@"w"] && (theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask) == (NSUInteger)(NSCommandKeyMask | NSControlKeyMask)) {
        MHTabItemViewController *tabItemViewController;
        
        tabItemViewController = _tabViewController.selectedTabItemViewController;
        if ([tabItemViewController isKindOfClass:[MHQueryWindowController class]]) {
            [_tabItemControllers removeObjectForKey:[[(MHQueryWindowController *)tabItemViewController mongoCollection] absoluteCollectionName]];
        } else if (tabItemViewController == _statusViewController) {
            [_statusViewController release];
            _statusViewController = nil;
        }
        [_tabViewController removeTabItemViewController:tabItemViewController];
    } else {
        [super keyDown:theEvent];
    }
}

- (void)dropDB
{
    [loaderIndicator start];
    [_mongoServer dropDatabaseWithName:[[self selectedDatabaseItem].mongoDatabase databaseName] callback:^(MODQuery *mongoQuery) {
        [loaderIndicator stop];
        [self getDatabaseList];
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        }
    }];
}

- (IBAction)query:(id)sender
{
    if (![self selectedCollectionItem]) {
        if (![_databaseCollectionOutlineView isItemExpanded:[_databaseCollectionOutlineView itemAtRow:[_databaseCollectionOutlineView selectedRow]]]) {
            [_databaseCollectionOutlineView expandItem:[_databaseCollectionOutlineView itemAtRow:[_databaseCollectionOutlineView selectedRow]] expandChildren:NO];
        } else {
            [_databaseCollectionOutlineView collapseItem:[_databaseCollectionOutlineView itemAtRow:[_databaseCollectionOutlineView selectedRow]]];
        }
    } else {
        MHQueryWindowController *queryWindowController;
        
        queryWindowController = [_tabItemControllers objectForKey:[[[self selectedCollectionItem] mongoCollection] absoluteCollectionName]];
        if (queryWindowController == nil) {
            queryWindowController = [MHQueryWindowController loadQueryController];
            [_tabItemControllers setObject:queryWindowController forKey:[[[self selectedCollectionItem] mongoCollection] absoluteCollectionName]];
            queryWindowController.mongoCollection = [self selectedCollectionItem].mongoCollection;
            queryWindowController.connectionStore = _connectionStore;
            [_tabViewController addTabItemViewController:queryWindowController];
        }
        [queryWindowController select];
    }
}

- (IBAction)showAuth:(id)sender
{
    if (![self selectedDatabaseItem]) 
    {
        NSRunAlertPanel(@"Error", @"Please choose a database!", @"OK", nil, nil);
        return;
    }
    if (!authWindowController)
    {
        authWindowController = [[AuthWindowController alloc] init];
    }
    MHDatabaseStore *db = [_databaseStoreArrayController dbInfo:_connectionStore name:[[self selectedDatabaseItem].mongoDatabase databaseName]];
    if (db) {
        [authWindowController.userTextField setStringValue:db.user];
        [authWindowController.passwordTextField setStringValue:db.password];
    }else {
        [authWindowController.userTextField setStringValue:@""];
        [authWindowController.passwordTextField setStringValue:@""];
    }
    authWindowController.conn = _connectionStore;
    authWindowController.dbname = [[self selectedDatabaseItem].mongoDatabase databaseName];
    [authWindowController showWindow:self];
}

- (IBAction)importFromMySQL:(id)sender
{
    if ([self selectedDatabaseItem] == nil) {
        NSRunAlertPanel(@"Error", @"Please specify a database!", @"OK", nil, nil);
        return;
    }
    if (!_mysqlImportWindowController)
    {
        _mysqlImportWindowController = [[MHMysqlImportWindowController alloc] init];
    }
    _mysqlImportWindowController.mongoServer = _mongoServer;
    _mysqlImportWindowController.dbname = [[self selectedDatabaseItem].mongoDatabase databaseName];
    if ([self selectedCollectionItem]) {
        [_mysqlExportWindowController.collectionTextField setStringValue:[[self selectedCollectionItem].mongoCollection collectionName]];
    }
    [_mysqlImportWindowController showWindow:self];
}

- (IBAction)exportToMySQL:(id)sender
{
    if ([self selectedCollectionItem] == nil) {
        NSRunAlertPanel(@"Error", @"Please specify a collection!", @"OK", nil, nil);
        return;
    }
    if (!_mysqlExportWindowController)
    {
        _mysqlExportWindowController = [[MHMysqlExportWindowController alloc] init];
    }
    _mysqlExportWindowController.mongoDatabase = [[self selectedDatabaseItem] mongoDatabase];
    _mysqlExportWindowController.dbname = [[self selectedDatabaseItem].mongoDatabase databaseName];
    if ([self selectedCollectionItem]) {
        [_mysqlExportWindowController.collectionTextField setStringValue:[[self selectedCollectionItem].mongoCollection collectionName]];
    }
    [_mysqlExportWindowController showWindow:self];
}

- (IBAction)importFromFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    if ([openPanel runModal] == NSOKButton) {
        MHFileImporter *importer;
        NSError *error;
        
        importer = [[MHFileImporter alloc] initWithCollection:[self selectedCollectionItem].mongoCollection importPath:[[openPanel URL] path]];
        [importer importWithError:&error];
        [importer release];
    }
}

- (IBAction)exportToFile:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    if ([savePanel runModal] == NSOKButton) {
        MHFileExporter *exporter;
        NSError *error;
        
        exporter = [[MHFileExporter alloc] initWithCollection:[self selectedCollectionItem].mongoCollection exportPath:[[savePanel URL] path]];
        [exporter exportWithError:&error];
        [exporter release];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertSecondButtonReturn)
    {
        if ([self selectedCollectionItem]) {
            [self dropCollection:[[self selectedCollectionItem].mongoCollection collectionName] ForDB:[[self selectedDatabaseItem].mongoDatabase databaseName]];
        }else {
            [self dropDB];
        }
    }
}

- (void)dropWarning:(NSString *)msg
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"Drop this %@?", msg]];
    [alert setInformativeText:[NSString stringWithFormat:@"Dropped %@ cannot be restored.", msg]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (IBAction)startMonitor:(id)sender {
    if (!_serverMonitorTimer) {
        _serverMonitorTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fetchServerStatusDelta) userInfo:nil repeats:YES] retain];
        [self fetchServerStatusDelta];
    }
    [NSApp beginSheet:monitorPanel modalForWindow:self.window modalDelegate:self didEndSelector:@selector(monitorPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
    NSLog(@"startMonitor");
}

- (IBAction)stopMonitor:(id)sender
{
    [NSApp endSheet:monitorPanel];
}

- (void)monitorPanelDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [monitorPanel close];
    [_serverMonitorTimer invalidate];
    [_serverMonitorTimer release];
    _serverMonitorTimer = nil;
}

static int percentage(NSNumber *previousValue, NSNumber *previousOutOfValue, NSNumber *value, NSNumber *outOfValue)
{
    double valueDiff = [value doubleValue] - [previousValue doubleValue];
    double outOfValueDiff = [outOfValue doubleValue] - [previousOutOfValue doubleValue];
    return (outOfValueDiff == 0) ? 0.0 : (valueDiff * 100.0 / outOfValueDiff);
}

- (void)fetchServerStatusDelta
{
    [resultsTitle setStringValue:[NSString stringWithFormat:@"Server %@:%@ stats", _connectionStore.host, _connectionStore.hostport]];
    [_mongoServer fetchServerStatusWithCallback:^(MODSortedMutableDictionary *serverStatus, MODQuery *mongoQuery) {
        [loaderIndicator stop];
        if (_mongoServer == [mongoQuery.parameters objectForKey:@"mongoserver"]) {
            NSMutableDictionary *diff = [[NSMutableDictionary alloc] init];
            
            if (previousServerStatusForDelta) {
                NSNumber *number;
                NSDate *date;
                
                for (NSString *key in [[serverStatus objectForKey:@"opcounters"] allKeys]) {
                    number = [[NSNumber alloc] initWithInteger:[[[serverStatus objectForKey:@"opcounters"] objectForKey:key] integerValue] - [[[previousServerStatusForDelta objectForKey:@"opcounters"] objectForKey:key] integerValue]];
                    [diff setObject:number forKey:key];
                    [number release];
                }
                if ([[serverStatus objectForKey:@"mem"] objectForKey:@"mapped"]) {
                    [diff setObject:[[serverStatus objectForKey:@"mem"] objectForKey:@"mapped"] forKey:@"mapped"];
                }
                [diff setObject:[[serverStatus objectForKey:@"mem"] objectForKey:@"virtual"] forKey:@"vsize"];
                [diff setObject:[[serverStatus objectForKey:@"mem"] objectForKey:@"resident"] forKey:@"res"];
                number = [[NSNumber alloc] initWithInteger:[[[serverStatus objectForKey:@"extra_info"] objectForKey:@"page_faults"] integerValue] - [[[previousServerStatusForDelta objectForKey:@"extra_info"] objectForKey:@"page_faults"] integerValue]];
                [diff setObject:number forKey:@"faults"];
                [number release];
                number = [[NSNumber alloc] initWithInteger:percentage([[previousServerStatusForDelta objectForKey:@"globalLock"] objectForKey:@"lockTime"],
                                                                      [[previousServerStatusForDelta objectForKey:@"globalLock"] objectForKey:@"totalTime"],
                                                                      [[serverStatus objectForKey:@"globalLock"] objectForKey:@"lockTime"],
                                                                      [[serverStatus objectForKey:@"globalLock"] objectForKey:@"totalTime"])];
                [diff setObject:number forKey:@"locked"];
                [number release];
                number = [[NSNumber alloc] initWithInteger:percentage([[[previousServerStatusForDelta objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"misses"],
                                                                      [[[previousServerStatusForDelta objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"accesses"],
                                                                      [[[serverStatus objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"misses"],
                                                                      [[[serverStatus objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"accesses"])];
                [diff setObject:number forKey:@"misses"];
                [number release];
                date = [[NSDate alloc] init];
                [diff setObject:[[serverStatus objectForKey:@"connections"] objectForKey:@"current"] forKey:@"conn"];
                [diff setObject:date forKey:@"time"];
                [date release];
                [statMonitorTableController addObject:diff];
            }
            if (previousServerStatusForDelta) {
                [previousServerStatusForDelta release];
            }
            previousServerStatusForDelta = [serverStatus retain];
            [diff release];
        }
    }];
}

- (MHDatabaseItem *)selectedDatabaseItem
{
    MHDatabaseItem *result = nil;
    NSInteger index;
    
    index = [_databaseCollectionOutlineView selectedRow];
    if (index != NSNotFound) {
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
    if (index != NSNotFound) {
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
    return [_connectionStore managedObjectContext];
}

- (void)updateToolbarItems
{
    for (NSToolbarItem *item in [_toolbar items]) {
        switch ([item tag]) {
            case DATABASE_STATUS_TOOLBAR_ITEM_TAG:
                [item setEnabled:[self selectedDatabaseItem] != nil];
                break;
                
            case COLLECTION_STATUS_TOOLBAR_ITEM_TAG:
            case QUERY_TOOLBAR_ITEM_TAG:
            case MYSQL_IMPORT_TOOLBAR_ITEM_TAG:
            case MYSQL_EXPORT_TOOLBAR_ITEM_TAG:
            case FILE_IMPORT_TOOLBAR_ITEM_TAG:
            case FILE_EXPORT_TOOLBAR_ITEM_TAG:
                [item setEnabled:[self selectedCollectionItem] != nil];
                break;
                
            default:
                break;
        }
    }
}

@end

@implementation MHConnectionWindowController(NSOutlineViewDataSource)

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item) {
        return [_serverItem.databaseItems count];
    } else if ([item isKindOfClass:[MHDatabaseItem class]]) {
        return [[item collectionItems] count];
    } else {
        return 0;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        return [_serverItem.databaseItems objectAtIndex:index];
    } else if ([item isKindOfClass:[MHDatabaseItem class]]) {
        return [[item collectionItems] objectAtIndex:index];
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
    if ([self selectedCollectionItem]) {
        MHCollectionItem *collectionItem = [self selectedCollectionItem];
        
        [self getCollectionListForDatabaseItem:collectionItem.databaseItem];
        [self showCollectionStatusWithCollectionItem:collectionItem];
        if ([_tabItemControllers objectForKey:[collectionItem.mongoCollection absoluteCollectionName]]) {
            [[_tabItemControllers objectForKey:[collectionItem.mongoCollection absoluteCollectionName]] select];
        } else {
            [_statusViewController select];
        }
    } else if ([self selectedDatabaseItem]) {
        MHDatabaseItem *databaseItem = [self selectedDatabaseItem];
        
        [self getCollectionListForDatabaseItem:databaseItem];
        [self showDatabaseStatusWithDatabaseItem:databaseItem];
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
        [cell setHasBadge:[[item collectionItems] count] > 0];
        [cell setBadgeCount:[[item collectionItems] count]];
    }
}

- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    [self getCollectionListForDatabaseItem:[[notification userInfo] objectForKey:@"NSObject"]];
}

@end


@implementation MHConnectionWindowController (MHServerItemDelegateCategory)

- (id)mongoDatabaseWithDatabaseItem:(MHDatabaseItem *)item
{
    return [_mongoServer databaseForName:item.name];
}

- (id)mongoCollectionWithCollectionItem:(MHCollectionItem *)item
{
    return [[self mongoDatabaseWithDatabaseItem:item.databaseItem] collectionForName:item.name];
}

@end

@implementation MHConnectionWindowController(MHTabViewControllerDelegate)

- (void)tabViewController:(MHTabViewController *)tabViewController didRemoveTabItem:(MHTabItemViewController *)tabItemViewController
{
    if (tabItemViewController == _statusViewController) {
        [_statusViewController release];
        _statusViewController = nil;
    } else {
        [_tabItemControllers removeObjectForKey:[(MHQueryWindowController *)tabItemViewController mongoCollection].absoluteCollectionName];
    }
}

@end

@implementation MHConnectionWindowController(MHTunnelDelegate)

- (void)tunnelDidConnect:(MHTunnel *)tunnel
{
    NSLog(@"SSH TUNNEL STATUS: CONNECTED");
    [self connectToServer];
}

- (void)tunnelDidFailToConnect:(MHTunnel *)tunnel withError:(NSError *)error;
{
    NSLog(@"SSH TUNNEL ERROR: %@", error);
    if (!tunnel.connected) {
        // after being connected, we don't really care about errors
        [self didFailToConnectWithError:error];
    }
}

@end
