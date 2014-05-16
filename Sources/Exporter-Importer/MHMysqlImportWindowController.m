//
//  MHMysqlImportWindowController.m
//  MongoHub
//
//  Created by Syd on 10-6-16.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHMysqlImportWindowController.h"
#import "Configure.h"
#import "DatabasesArrayController.h"
#import "MHDatabaseStore.h"
#import "NSString+Extras.h"
#import <mongo-objc-driver/MOD_public.h>
#import <MCPKit/MCPKit.h>

@implementation MHMysqlImportWindowController
@synthesize dbname;
@synthesize mongoServer;
@synthesize dbsArrayController;
@synthesize tablesArrayController;
@synthesize hostTextField;
@synthesize portTextField;
@synthesize userTextField;
@synthesize passwdTextField;
@synthesize chunkSizeTextField;
@synthesize collectionTextField;
@synthesize progressIndicator;
@synthesize tablesPopUpButton;

- (id)init {
    self = [super initWithWindowNibName:@"MysqlImport"];
    return self;
}

- (void)dealloc {
    [dbname release];
    [databasesArrayController release];
    [db release];
    [mongoServer release];
    [dbsArrayController release];
    [tablesArrayController release];
    [hostTextField release];
    [portTextField release];
    [userTextField release];
    [passwdTextField release];
    [chunkSizeTextField release];
    [collectionTextField release];
    [progressIndicator release];
    [tablesPopUpButton release];
    [super dealloc];
}

- (void)windowDidLoad {
    //NSLog(@"New Connection Window Loaded");
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
    dbname = nil;
    db = nil;
    [dbsArrayController setContent:nil];
    [tablesArrayController setContent:nil];
    [progressIndicator setDoubleValue:0.0];
}

- (IBAction)import:(id)sender {
    [progressIndicator setUsesThreadedAnimation:YES];
    [progressIndicator startAnimation: self];
    [progressIndicator setDoubleValue:0];
    NSString *collection = [collectionTextField stringValue];
    int chunkSize = [chunkSizeTextField intValue];
    if ([collection length] == 0) {
        NSRunAlertPanel(@"Error", @"Collection name can not be empty!", @"OK", nil, nil);
        return;
    }
    if (chunkSize == 0) {
        NSRunAlertPanel(@"Error", @"Chunk Size can not be 0!", @"OK", nil, nil);
        return;
    }
    [self doImportFromTable:[tablesPopUpButton titleOfSelectedItem] toCollection:collection withChundSize:chunkSize];
}

- (long long int)importCount:(NSString *)tableName
{
    NSString *query = [[NSString alloc] initWithFormat:@"select count(*) counter from %@", tableName];
    MCPResult *theResult = [db queryString:query];
    [query release];
    NSArray *row = [theResult fetchRowAsArray];
    NSLog(@"count: %@", [row objectAtIndex:0]);
    return [[row objectAtIndex:0] intValue];
}

- (void)updateProgressIndicatorWithNumber:(NSNumber *)number
{
    [progressIndicator setDoubleValue:[number doubleValue]];
}

- (void)importDone:(id)unused
{
    [progressIndicator setDoubleValue:1.0];
    [progressIndicator stopAnimation:nil];
}

- (void)doImportFromTable:(NSString *)tableName toCollection:(NSString *)collectionName withChundSize:(int)chunkSize
{
    MODServer *copyServer;
    MODCollection *copyCollection;
    
    copyServer = [mongoServer copy];
    
    copyCollection = [[copyServer databaseForName:dbname] collectionForName:collectionName];
    if (!copyServer) {
        NSRunAlertPanel(@"Error", @"Can not create a second connection to the mongo server.", @"OK", nil, nil);
        return;
    }
    dispatch_queue_t myQueue = dispatch_queue_create("com.mongohub.mysql", 0);
    
    dispatch_async(myQueue, ^ {
        long long total = [self importCount:tableName];
        long long ii = 0;
        
        while (ii < total) {
            NSString *query = [[NSString alloc] initWithFormat:@"select * from %@ limit %lld, %d", tableName, ii, chunkSize];
            MCPResult *theResult = [db queryString:query];
            NSDictionary *row;
            NSMutableArray *documents;
             
            [query release];
            if ([theResult numOfRows] == 0) {
                 return;
            }
            while ((row = [theResult fetchRowAsDictionary])) {
                void (^callback)(MODQuery *mongoQuery);
                MODSortedMutableDictionary *document;
                
                ii++;
                document = [[MODSortedMutableDictionary alloc] initWithDictionary:row];
                documents = [[NSMutableArray alloc] initWithObjects:document, nil];
                [document release];
                if (ii == total) {
                    callback = ^(MODQuery *mongoQuery) {
                        [self importDone:nil];
                    };
                } else if (ii % 10 == 0) {
                    callback = ^(MODQuery *mongoQuery) {
                        [progressIndicator setDoubleValue:(double)ii/(double)total];
                    };
                } else {
                    callback = nil;
                }
                [copyCollection insertWithDocuments:documents callback:callback];
                [documents release];
            }
        }
    });
}

- (IBAction)connect:(id)sender {
    NSString *mysqlHostname;
    NSString *userName;
    NSUInteger port;
    
    if (db) {
        [dbsArrayController setContent:nil];
        [tablesArrayController setContent:nil];
        [progressIndicator setDoubleValue:0.0];
        [db release];
    }
    mysqlHostname = [[hostTextField stringValue] stringByTrimmingWhitespace];
    if ([mysqlHostname length] == 0) {
        mysqlHostname = [[hostTextField cell] placeholderString];
    }
    userName = [[userTextField stringValue] stringByTrimmingWhitespace];
    if ([userName length] == 0) {
        userName = [[userTextField cell] placeholderString];
    }
    port = [portTextField intValue];
    if (port == 0) {
        port = [[[portTextField cell] placeholderString] intValue];
    }
    db = [[MCPConnection alloc] initToHost:mysqlHostname withLogin:userName usingPort:port];
    [db setPassword:[passwdTextField stringValue]];
    [db connect];
    NSLog(@"Connect: %d", [db isConnected]);
    if (![db isConnected])
    {
        NSRunAlertPanel(@"Error", @"Could not connect to the mysql server!", @"OK", nil, nil);
    }
    [db queryString:@"SET NAMES utf8"];
    [db queryString:@"SET CHARACTER SET utf8"];
    [db queryString:@"SET COLLATION_CONNECTION='utf8_general_ci'"];
    [db setEncoding:@"utf8"];
    MCPResult *dbs = [db listDBs];
    NSArray *row;
    NSMutableArray *databases = [[NSMutableArray alloc] initWithCapacity:[dbs numOfRows]];
    while ((row = [dbs fetchRowAsArray])) {
        NSDictionary *database = [[NSDictionary alloc] initWithObjectsAndKeys:[row objectAtIndex:0], @"name", nil];
        [databases addObject:database];
        [database release];
    }
    [dbsArrayController setContent:databases];
    [databases release];
}

- (IBAction)showTables:(id)sender
{
    NSString *dbn;
    if (sender == nil && [[dbsArrayController arrangedObjects] count] > 0) {
        dbn = [[[dbsArrayController arrangedObjects] objectAtIndex:0] objectForKey:@"name"];
    }else {
        NSPopUpButton *pb = sender;
        dbn = [NSString stringWithString:[pb titleOfSelectedItem]];
    }
    if ([dbn length] == 0) {
        return;
    }
    [db selectDB:dbn];
    MCPResult *tbs = [db listTables];
    NSArray *row;
    NSMutableArray *tables = [[NSMutableArray alloc] initWithCapacity:[tbs numOfRows]];
    while ((row = [tbs fetchRowAsArray])) {
        NSDictionary *table = [[NSDictionary alloc] initWithObjectsAndKeys:[row objectAtIndex:0], @"name", nil];
        [tables addObject:table];
        [table release];
    }
    [tablesArrayController setContent:tables];
    [tables release];
}

@end
