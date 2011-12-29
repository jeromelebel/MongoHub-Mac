//
//  ConnectionWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Configure.h"
#import "NSString+Extras.h"
#import "NSProgressIndicator+Extras.h"
#import "ConnectionWindowController.h"
#import "MHQueryWindowController.h"
#import "AddDBController.h"
#import "AddCollectionController.h"
#import "AuthWindowController.h"
#import "MHMysqlImportWindowController.h"
#import "MHMysqlExportWindowController.h"
#import "ResultsOutlineViewController.h"
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

#define SERVER_STATUS_TOOLBAR_ITEM_TAG              0
#define DATABASE_STATUS_TOOLBAR_ITEM_TAG            1
#define COLLECTION_STATUS_TOOLBAR_ITEM_TAG          2
#define QUERY_TOOLBAR_ITEM_TAG                      3
#define MYSQL_IMPORT_TOOLBAR_ITEM_TAG               4
#define MYSQL_EXPORT_TOOLBAR_ITEM_TAG               5
#define FILE_IMPORT_TOOLBAR_ITEM_TAG                6
#define FILE_EXPORT_TOOLBAR_ITEM_TAG                7

@interface ConnectionWindowController()
- (void)updateToolbarItems;

- (void)closeMongoDB;
- (void)fetchServerStatusDelta;

- (MHDatabaseItem *)selectedDatabaseItem;
- (MHCollectionItem *)selectedCollectionItem;

- (MODQuery *)getDatabaseList;
- (MODQuery *)getCollectionListForDatabaseItem:(MHDatabaseItem *)databaseItem;

- (MODQuery *)showServerStatus;
- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;
@end

@implementation ConnectionWindowController

@synthesize resultsOutlineViewController;
@synthesize connectionStore = _connectionStore;
@synthesize mongoServer = _mongoServer;
@synthesize loaderIndicator;
@synthesize monitorButton;
@synthesize reconnectButton;
@synthesize statMonitorTableController;
@synthesize databases = _databases;
@synthesize sshTunnel;
@synthesize addDBController;
@synthesize addCollectionController;
@synthesize resultsTitle;
@synthesize bundleVersion;
@synthesize authWindowController;
@synthesize mysqlImportWindowController = _mysqlImportWindowController;
@synthesize mysqlExportWindowController = _mysqlExportWindowController;


- (id)init
{
    if (self = [super initWithWindowNibName:@"ConnectionWindow"]) {
        _databases = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self closeMongoDB];
    [resultsOutlineViewController release];
    [_connectionStore release];
    [_databases release];
    [sshTunnel release];
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
    [_databaseCollectionOutlineView setDoubleAction:@selector(outlineViewDoubleClickAction:)];
    [self updateToolbarItems];
    
    if ([[_connectionStore userepl] intValue] == 1) {
        self.window.title = [NSString stringWithFormat:@"%@ [%@]", [_connectionStore alias], [_connectionStore repl_name] ];
    } else {
        self.window.title = [NSString stringWithFormat:@"%@ [%@:%@]", [_connectionStore alias], [_connectionStore host], [_connectionStore hostport] ];
    }
}

- (void)tunnelStatusChanged:(MHTunnel *)tunnel status:(NSString *)status
{
    NSLog(@"SSH TUNNEL STATUS: %@", status);
    if( [status isEqualToString: @"CONNECTED"] ){
        exitThread = YES;
        [self connect:YES];
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
    NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
}

- (void)connect:(BOOL)haveHostAddress
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [loaderIndicator start];
    [reconnectButton setEnabled:NO];
    [monitorButton setEnabled:NO];
    if (!haveHostAddress && [_connectionStore.usessh intValue] == 1) {
        NSString *portForward = [[NSString alloc] initWithFormat:@"L:%@:%@:%@:%@", _connectionStore.bindaddress, _connectionStore.bindport, _connectionStore.host, _connectionStore.hostport];
        NSMutableArray *portForwardings = [[NSMutableArray alloc] initWithObjects:portForward, nil];
        [portForward release];
        if (!sshTunnel) {
            sshTunnel =[[MHTunnel alloc] init];
        }
        [sshTunnel setDelegate:self];
        [sshTunnel setUser:_connectionStore.sshuser];
        [sshTunnel setHost:_connectionStore.sshhost];
        [sshTunnel setPassword:_connectionStore.sshpassword];
        [sshTunnel setKeyfile:_connectionStore.sshkeyfile];
        [sshTunnel setPort:[_connectionStore.sshport intValue]];
        [sshTunnel setPortForwardings:portForwardings];
        [sshTunnel setAliveCountMax:3];
        [sshTunnel setAliveInterval:30];
        [sshTunnel setTcpKeepAlive:YES];
        [sshTunnel setCompression:YES];
        [sshTunnel start];
        [portForwardings release];
        [pool drain];
        return;
    } else {
        [self closeMongoDB];
        _mongoServer = [[MODServer alloc] init];
        _serverItem = [[MHServerItem alloc] initWithMongoServer:_mongoServer delegate:self];
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
                hostaddress = [[NSString alloc] initWithFormat:@"127.0.0.1:%@", _connectionStore.bindport];
            } else {
                hostaddress = [[NSString alloc] initWithFormat:@"%@:%@", _connectionStore.host, _connectionStore.hostport];
            }
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
    [pool drain];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    exitThread = NO;
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@[%@])", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
    [self connect:NO];
    if ([_connectionStore.usessh intValue]==1) {
        [NSThread detachNewThreadSelector: @selector(checkTunnel) toTarget:self withObject:nil ];
    }
    [_databaseCollectionOutlineView setDoubleAction:@selector(sidebarDoubleAction:)];
}

- (void)sidebarDoubleAction:(id)sender
{
    [self query:sender];
}

- (IBAction)reconnect:(id)sender
{
    [self connect:NO];
    if ([_connectionStore.usessh intValue]==1) {
        [NSThread detachNewThreadSelector: @selector(checkTunnel) toTarget:self withObject:nil ];
    }
}

- (void)checkTunnel
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    while (!exitThread) {
        [NSThread sleepForTimeInterval:3];
        @synchronized(self) {
            if ([sshTunnel running] == NO){
                [sshTunnel start];
            } else if( [sshTunnel running] == YES && [sshTunnel checkProcess] == NO ){
                [sshTunnel stop];
                [NSThread sleepForTimeInterval:2];
                [sshTunnel start];
            }
            [sshTunnel readStatus];
        }
    }
    [pool drain];
    [NSThread exit];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([sshTunnel running]) {
        [sshTunnel stop];
    }
    //exitThread = YES;
    resultsOutlineViewController = nil;
    [super release];
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

- (MODQuery *)showServerStatus
{
    MODQuery *result;
    
    [loaderIndicator start];
    [resultsTitle setStringValue:[NSString stringWithFormat:@"Server %@:%@ stats", _connectionStore.host, _connectionStore.hostport]];
    result = [_mongoServer fetchServerStatusWithCallback:^(MODSortedMutableDictionary *serverStatus, MODQuery *mongoQuery) {
        [loaderIndicator stop];
        if (_mongoServer == [mongoQuery.parameters objectForKey:@"mongoserver"]) {
            [resultsOutlineViewController.results removeAllObjects];
            if (serverStatus) {
                [resultsOutlineViewController.results addObjectsFromArray:[MODHelper convertForOutlineWithObject:serverStatus]];
            } else if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
            }
            [resultsOutlineViewController.myOutlineView reloadData];
        }
    }];
    return result;
}

- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem
{
    MODQuery *result;
    
    if (databaseItem) {
        [loaderIndicator start];
        [resultsTitle setStringValue:[NSString stringWithFormat:@"Database %@ stats", databaseItem.name]];
        
        result = [databaseItem.mongoDatabase fetchDatabaseStatsWithCallback:^(MODSortedMutableDictionary *databaseStats, MODQuery *mongoQuery) {
            [loaderIndicator stop];
            [resultsOutlineViewController.results removeAllObjects];
            if (databaseStats) {
                [resultsOutlineViewController.results addObjectsFromArray:[MODHelper convertForOutlineWithObject:databaseStats]];
            } else if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
            }
            [resultsOutlineViewController.myOutlineView reloadData];
        }];
    }
    return result;
}

- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem
{
    MODQuery *result = nil;
    
    if (collectionItem) {
        [loaderIndicator start];
        [resultsTitle setStringValue:[NSString stringWithFormat:@"Collection %@.%@ stats", collectionItem.databaseItem.name, collectionItem.name]];
        result = [collectionItem.mongoCollection fetchCollectionStatsWithCallback:^(MODSortedMutableDictionary *stats, MODQuery *mongoQuery) {
            [loaderIndicator stop];
            [resultsOutlineViewController.results removeAllObjects];
            if (stats) {
                [resultsOutlineViewController.results addObjectsFromArray:[MODHelper convertForOutlineWithObject:stats]];
            } else if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
            }
            [resultsOutlineViewController.myOutlineView reloadData];
        }];
    }
    return result;
}

- (IBAction)showServerStatus:(id)sender 
{
    [self showServerStatus];
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
        [self dropWarning:[NSString stringWithFormat:@"COLLECTION:%@", [[[self selectedCollectionItem] mongoCollection] collectionName]]];
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
        MHQueryWindowController *queryWindowController = [[MHQueryWindowController alloc] init];
        queryWindowController.mongoCollection = [self selectedCollectionItem].mongoCollection;
        queryWindowController.connectionStore = _connectionStore;
        [queryWindowController showWindow:sender];
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
    if (returnCode == NSAlertFirstButtonReturn)
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
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
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

@implementation ConnectionWindowController(NSOutlineViewDataSource)

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

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    return [item name];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if ([self selectedCollectionItem]) {
        MHCollectionItem *collectionItem = [self selectedCollectionItem];
        
        [self getCollectionListForDatabaseItem:collectionItem.databaseItem];
        [self showCollectionStatusWithCollectionItem:collectionItem];
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


@implementation ConnectionWindowController (MHServerItemDelegateCategory)

- (id)mongoDatabaseWithDatabaseItem:(MHDatabaseItem *)item
{
    return [_mongoServer databaseForName:item.name];
}

- (id)mongoCollectionWithCollectionItem:(MHCollectionItem *)item
{
    return [[self mongoDatabaseWithDatabaseItem:item.databaseItem] collectionForName:item.name];
}

@end
