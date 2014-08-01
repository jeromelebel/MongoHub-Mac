//
//  MHMysqlImportWindowController.h
//  MongoHub
//
//  Created by Syd on 10-6-16.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MCPConnection;
@class MODDatabase;

@interface MHMysqlImportWindowController : NSWindowController {
    MODDatabase                         *_database;
    MCPConnection                       *_mysqlConnection;
    IBOutlet NSArrayController *dbsArrayController;
    IBOutlet NSArrayController *tablesArrayController;
    IBOutlet NSTextField *hostTextField;
    IBOutlet NSTextField *portTextField;
    IBOutlet NSTextField *userTextField;
    IBOutlet NSSecureTextField *passwdTextField;
    IBOutlet NSTextField *chunkSizeTextField;
    IBOutlet NSTextField *collectionTextField;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSPopUpButton *tablesPopUpButton;
}

@property (nonatomic, retain) MODDatabase *database;
@property (nonatomic, retain) NSArrayController *dbsArrayController;
@property (nonatomic, retain) NSArrayController *tablesArrayController;
@property (nonatomic, retain) NSTextField *hostTextField;
@property (nonatomic, retain) NSTextField *portTextField;
@property (nonatomic, retain) NSTextField *userTextField;
@property (nonatomic, retain) NSSecureTextField *passwdTextField;
@property (nonatomic, retain) NSTextField *chunkSizeTextField;
@property (nonatomic, retain) NSTextField *collectionTextField;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (nonatomic, retain) NSPopUpButton *tablesPopUpButton;

- (IBAction)connect:(id)sender;
- (IBAction)import:(id)sender;
- (IBAction)showTables:(id)sender;
- (long long int)importCount:(NSString *)tableName;
- (void)doImportFromTable:(NSString *)tableName toCollection:(NSString *)collection withChundSize:(int)chunkSize;


@end
