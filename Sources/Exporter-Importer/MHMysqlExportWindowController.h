//
//  MHMysqlExportWindowController.h
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DatabasesArrayController;
@class MCPConnection;
@class MODCollection;
@class MODDatabase;
@class FieldMapTableController;

@interface MHMysqlExportWindowController : NSWindowController {
    DatabasesArrayController *databasesArrayController;
    NSString *dbname;
    MODDatabase *mongoDatabase;
    MCPConnection *db;
    IBOutlet NSArrayController *dbsArrayController;
    IBOutlet NSArrayController *tablesArrayController;
    IBOutlet NSTextField *hostTextField;
    IBOutlet NSTextField *portTextField;
    IBOutlet NSTextField *userTextField;
    IBOutlet NSSecureTextField *passwdTextField;
    IBOutlet NSTextField *collectionTextField;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSPopUpButton *tablesPopUpButton;
    IBOutlet FieldMapTableController *fieldMapTableController;
}

@property (nonatomic, retain) MODDatabase *mongoDatabase;
@property (nonatomic, retain) NSString *dbname;
@property (nonatomic, retain) NSArrayController *dbsArrayController;
@property (nonatomic, retain) NSArrayController *tablesArrayController;
@property (nonatomic, retain) NSTextField *hostTextField;
@property (nonatomic, retain) NSTextField *portTextField;
@property (nonatomic, retain) NSTextField *userTextField;
@property (nonatomic, retain) NSSecureTextField *passwdTextField;
@property (nonatomic, retain) NSTextField *collectionTextField;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (nonatomic, retain) NSPopUpButton *tablesPopUpButton;
@property (nonatomic, retain) FieldMapTableController *fieldMapTableController;

- (void)initInterface;
- (IBAction)connect:(id)sender;
- (IBAction)export:(id)sender;
- (IBAction)showTables:(id)sender;
- (IBAction)showFields:(id)sender;
- (int64_t)exportCount:(MODCollection *)collection;
- (void)doExportToTable:(NSString *)tableName data:(id) bsonObj fieldTypes:(NSDictionary *)fieldTypes fieldMapping:(NSArray *)fieldMapping;
@end
