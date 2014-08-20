//
//  MHMysqlExportWindowController.m
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHMysqlExportWindowController.h"
#import "NSString+MongoHub.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import <MCPKit/MCPKit.h>
#import "FieldMapTableController.h"
#import "FieldMapDataObject.h"

@implementation MHMysqlExportWindowController

@synthesize dbname;
@synthesize mongoDatabase;
@synthesize dbsArrayController;
@synthesize tablesArrayController;
@synthesize hostTextField;
@synthesize portTextField;
@synthesize userTextField;
@synthesize passwdTextField;
@synthesize collectionTextField;
@synthesize progressIndicator;
@synthesize tablesPopUpButton;
@synthesize fieldMapTableController;

- (id)init {
    self = [super initWithWindowNibName:@"MysqlExport"];
    return self;
}

- (void)dealloc {
    [dbname release];
    [db release];
    [mongoDatabase release];
    [dbsArrayController release];
    [tablesArrayController release];
    [hostTextField release];
    [portTextField release];
    [userTextField release];
    [passwdTextField release];
    [collectionTextField release];
    [progressIndicator release];
    [tablesPopUpButton release];
    [fieldMapTableController release];
    [super dealloc];
}

- (void)windowDidLoad {
    //NSLog(@"New Connection Window Loaded");
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
    dbname = nil;
    db = nil;
    [self initInterface];
}

- (IBAction)export:(id)sender {
    MODClient *copyServer;
    MODCollection *mongoCollection;
    
    copyServer = [mongoDatabase.client copy];
    [progressIndicator setUsesThreadedAnimation:YES];
    [progressIndicator startAnimation: self];
    [progressIndicator setDoubleValue:0];
    NSString *collection = [collectionTextField stringValue];
    if ([collection length] == 0) {
        NSRunAlertPanel(@"Error", @"Collection name can not be empty!", @"OK", nil, nil);
        return;
    }
    mongoCollection = [[copyServer databaseForName:mongoDatabase.name] collectionForName:collection];
    NSString *tablename = [tablesPopUpButton titleOfSelectedItem];
    
    int64_t total = [self exportCount:mongoCollection];
    if (total == 0) {
        return;
    }
    NSString *query = [[NSString alloc] initWithFormat:@"select * from %@ limit 1", tablename];
    MCPResult *theResult = [db queryString:query];
    NSDictionary *fieldTypes = [theResult fetchTypesAsDictionary];
    NSArray *fieldMapping = [fieldMapTableController.nsMutaryDataObj copy];
    
    MODCursor *cursor;
    cursor = [mongoCollection cursorWithCriteria:nil fields:nil skip:0 limit:0 sort:nil];
    [cursor forEachDocumentWithCallbackDocumentCallback:^(uint64_t index, MODSortedMutableDictionary *document) {
        [self doExportToTable:tablename data:document fieldTypes:fieldTypes fieldMapping:fieldMapping];
        [progressIndicator setDoubleValue:(double)index/total];
        NSLog(@"%lld %lld", index, total);
        return YES;
    } endCallback:^(uint64_t documentCounts, BOOL cursorStopped, MODQuery *mongoQuery) {
        [progressIndicator stopAnimation: self];
    }];
    [query release];
    [fieldMapping release];
}

- (int64_t)exportCount:(MODCollection *)collection
{
    MODQuery *query;
    
    query = [collection countWithCriteria:nil readPreferences:nil callback:nil];
    [query waitUntilFinished];
    return [[query.parameters objectForKey:@"count"] longLongValue];
}

- (void)doExportToTable:(NSString *)tableName data:(id)mongoDocument fieldTypes:(NSDictionary *)fieldTypes fieldMapping:(NSArray *)fieldMapping
{
    int fieldsCount = [fieldMapping count];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:fieldsCount];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:fieldsCount];
    for(FieldMapDataObject *field in fieldMapping)
    {
        id value;
        id mongoValue = [mongoDocument objectForKey:field.mongoKey];
        if (mongoValue == nil) {
            continue;
        } else if ([mongoValue isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([mongoValue isKindOfClass:[MODSortedMutableDictionary class]]) {
            continue;
        } else if ([mongoValue isKindOfClass:[NSNumber class]] && strcmp([mongoValue objCType], @encode(BOOL)) == 0)  {
            if ([mongoValue boolValue]) {
                value = [[NSString alloc] initWithString:@"1" ];
            }else {
                value = [[NSString alloc] initWithString:@"0"];
            }
        } else if ([mongoValue isKindOfClass:[NSNumber class]]) {
            NSString *ft = [fieldTypes objectForKey:field.sqlKey];
            if ([ft isEqualToString:@"date"] || [ft isEqualToString:@"datetime"]) {
                value = [[NSDate alloc] initWithTimeIntervalSince1970:[mongoValue doubleValue]];
            }else {
                value = [mongoValue retain];
            }
        } else if ([mongoValue isKindOfClass:[MODTimestamp class]]) {
            value = [[mongoValue dateValue] retain];
        } else if ([mongoValue isKindOfClass:[MODBinary class]]) {
            value = [[mongoValue data] retain];
        } else if ([mongoValue isKindOfClass:[MODObjectId class]]) {
            value = [[mongoValue stringValue] retain];
        } else if ([mongoValue isKindOfClass:[NSString class]] || [mongoValue isKindOfClass:[NSData class]] || [mongoValue isKindOfClass:[NSDate class]]) {
            value = [mongoValue retain];
        } else {
            value = [[mongoValue description] retain];
        }
        NSString *sqlKey = field.sqlKey;
        NSString *quotedValue = [db quoteObject:value];
        [value release];
        [fields addObject:sqlKey];
        [values addObject:quotedValue];
    }
    if ([fields count] > 0) {
        NSString *query = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (%@) values (%@)", tableName, [fields componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
        //NSLog(@"query: %@", query);
        [db queryString:query];
        [query release];
    }
    [fields release];
    [values release];
}

- (IBAction)connect:(id)sender {
    NSString *mysqlHostname;
    NSString *userName;
    NSUInteger port;
    
    if (db) {
        [self initInterface];
        [db release];
    }
    mysqlHostname = hostTextField.stringValue.mh_stringByTrimmingWhitespace;
    if ([mysqlHostname length] == 0) {
        mysqlHostname = [[hostTextField cell] placeholderString];
    }
    userName = userTextField.stringValue.mh_stringByTrimmingWhitespace;
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
    //[self showTables:nil];
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
    [self showFields:nil];
}

- (IBAction)showFields:(id)sender
{
    NSString *tablename = [[NSString alloc] initWithString:[tablesPopUpButton titleOfSelectedItem]];
    MCPResult *theResult = [db queryString:[NSString stringWithFormat:@"select * from %@ limit 1", tablename]];
    [tablename release];
    NSArray *theFields = [theResult fetchFieldNames];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:[theFields count] ];
    for (int i=0; i<[theFields count]; i++) {
        NSString *fieldName = [theFields objectAtIndex:i];
        FieldMapDataObject *fd = [[FieldMapDataObject alloc] initWithSqlKey:fieldName andMongoKey:fieldName];
        [fields addObject:fd];
        [fd release];
    }
    [fieldMapTableController setNsMutaryDataObj:fields];
    [fieldMapTableController.idTableView reloadData];
    [fields release];
}

- (void)initInterface
{
    [dbsArrayController setContent:nil];
    [tablesArrayController setContent:nil];
    [progressIndicator setDoubleValue:0.0];
    [fieldMapTableController.nsMutaryDataObj removeAllObjects];
    [fieldMapTableController.idTableView reloadData];
}

@end
