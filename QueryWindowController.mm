//
//  QueryWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "NSProgressIndicator+Extras.h"
#import "QueryWindowController.h"
#import "DatabasesArrayController.h"
#import "ResultsOutlineViewController.h"
#import "Connection.h"
#import "MongoDB.h"
#import "NSString+Extras.h"
#import "JsonWindowController.h"
#include <fstream>
#include <iostream>
#include <boost/filesystem/operations.hpp>

@implementation QueryWindowController

@synthesize managedObjectContext;
@synthesize databasesArrayController;
@synthesize findResultsViewController;
@synthesize mongoDB;
@synthesize conn;
@synthesize dbname;
@synthesize collectionname;

@synthesize criticalTextField;
@synthesize fieldsTextField;
@synthesize skipTextField;
@synthesize limitTextField;
@synthesize sortTextField;
@synthesize totalResultsTextField;
@synthesize findQueryTextField;
@synthesize findResultsOutlineView;
@synthesize findQueryLoaderIndicator;

@synthesize updateCriticalTextField;
@synthesize updateSetTextField;
@synthesize upsetCheckBox;
@synthesize updateResultsTextField;
@synthesize updateQueryTextField;
@synthesize updateQueryLoaderIndicator;

@synthesize removeCriticalTextField;
@synthesize removeResultsTextField;
@synthesize removeQueryTextField;
@synthesize removeQueryLoaderIndicator;

@synthesize insertDataTextView;
@synthesize insertResultsTextField;
@synthesize insertLoaderIndicator;

@synthesize indexTextField;
@synthesize indexesOutlineViewController;
@synthesize indexLoaderIndicator;

@synthesize mapFunctionTextView;
@synthesize reduceFunctionTextView;
@synthesize mrcriticalTextField;
@synthesize mroutputTextField;
@synthesize mrOutlineViewController;
@synthesize mrLoaderIndicator;

@synthesize expCriticalTextField;
@synthesize expFieldsTextField;
@synthesize expSkipTextField;
@synthesize expLimitTextField;
@synthesize expSortTextField;
@synthesize expResultsTextField;
@synthesize expPathTextField;
@synthesize expTypePopUpButton;
@synthesize expQueryTextField;
@synthesize expJsonArrayCheckBox;
@synthesize expProgressIndicator;

@synthesize impIgnoreBlanksCheckBox;
@synthesize impDropCheckBox;
@synthesize impHeaderlineCheckBox;
@synthesize impFieldsTextField;
@synthesize impResultsTextField;
@synthesize impPathTextField;
@synthesize impTypePopUpButton;
@synthesize impJsonArrayCheckBox;
@synthesize impStopOnErrorCheckBox;
@synthesize impProgressIndicator;


- (id)init {
    if (![super initWithWindowNibName:@"QueryWindow"]) return nil;
    return self;
}

- (void)dealloc {
    [managedObjectContext release];
    [databasesArrayController release];
    [findResultsViewController release];
    [conn release];
    [mongoDB release];
    [dbname release];
    [collectionname release];
    
    [criticalTextField release];
    [fieldsTextField release];
    [skipTextField release];
    [limitTextField release];
    [sortTextField release];
    [totalResultsTextField release];
    [findQueryTextField release];
    [findResultsOutlineView release];
    [findQueryLoaderIndicator release];
    
    [updateCriticalTextField release];
    [updateSetTextField release];
    [upsetCheckBox release];
    [updateResultsTextField release];
    [updateQueryTextField release];
    [updateQueryLoaderIndicator release];
    
    [removeCriticalTextField release];
    [removeResultsTextField release];
    [removeQueryTextField release];
    [removeQueryLoaderIndicator release];
    
    [insertDataTextView release];
    [insertResultsTextField release];
    [insertLoaderIndicator release];
    
    [indexTextField release];
    [indexesOutlineViewController release];
    [indexLoaderIndicator release];
    
    [mapFunctionTextView release];
    [reduceFunctionTextView release];
    [mrcriticalTextField release];
    [mroutputTextField release];
    [mrOutlineViewController release];
    [mrLoaderIndicator release];
    
    [expCriticalTextField release];
    [expFieldsTextField release];
    [expSkipTextField release];
    [expLimitTextField release];
    [expSortTextField release];
    [expResultsTextField release];
    [expPathTextField release];
    [expTypePopUpButton release];
    [expQueryTextField release];
    [expJsonArrayCheckBox release];
    [expProgressIndicator release];
    
    [impIgnoreBlanksCheckBox release];
    [impDropCheckBox release];
    [impHeaderlineCheckBox release];
    [impFieldsTextField release];
    [impResultsTextField release];
    [impPathTextField release];
    [impTypePopUpButton release];
    [impJsonArrayCheckBox release];
    [impStopOnErrorCheckBox release];
    [impProgressIndicator release];
    
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSString *title = [[NSString alloc] initWithFormat:@"Query in %@.%@", dbname, collectionname];
    [self.window setTitle:title];
    [title release];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self release];
}

- (IBAction)findQuery:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doFindQuery) toTarget:self withObject:nil];
}

- (void)doFindQuery {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSTimeInterval speed = [NSDate timeIntervalSinceReferenceDate];
    [findQueryLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [criticalTextField stringValue];
    NSString *fields = [fieldsTextField stringValue];
    NSString *sort = [sortTextField stringValue];
    NSNumber *skip = [NSNumber numberWithInt:[skipTextField intValue]];
    NSNumber *limit;
    if ([limitTextField intValue] == 0) {
        limit = [NSNumber numberWithInt:30];
    }else {
        limit = [NSNumber numberWithInt:[limitTextField intValue]];
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB findInDB:dbname 
                                                                           collection:collectionname 
                                                                                 user:user 
                                                                             password:password 
                                                                             critical:critical 
                                                                               fields:fields 
                                                                                 skip:skip 
                                                                                limit:limit
                                                                                 sort:sort]];
    long long int total = [mongoDB countInDB:dbname 
                                  collection:collectionname 
                                        user:user 
                                    password:password 
                                    critical:critical];
    [totalResultsTextField setStringValue:[NSString stringWithFormat:@"Total Results: %d (%0.2fs)", total, [NSDate timeIntervalSinceReferenceDate]-speed]];
    findResultsViewController.results = results;
    [findResultsViewController.myOutlineView reloadData];
    [results release];
    [findQueryLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction)expandFindResults:(id)sender
{
    [findResultsOutlineView expandItem:nil expandChildren:YES];
}

- (IBAction)collapseFindResults:(id)sender
{
    [findResultsOutlineView collapseItem:nil collapseChildren:YES];
}

- (IBAction)updateQuery:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doUpdateQuery) toTarget:self withObject:nil];
}

- (void)doUpdateQuery {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [updateQueryLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [updateCriticalTextField stringValue];
    NSString *fields = [updateSetTextField stringValue];
    NSNumber *upset = [NSNumber numberWithInt:[upsetCheckBox state]];
    int total = [mongoDB countInDB:dbname 
                        collection:collectionname 
                              user:user 
                          password:password 
                          critical:critical];
    [mongoDB updateInDB:dbname 
             collection:collectionname 
                   user:user 
               password:password 
               critical:critical 
                 fields:fields 
                  upset:upset];
    [updateResultsTextField setStringValue:[NSString stringWithFormat:@"Affected Rows: %d", total]];
    [updateQueryLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction)removeQuery:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doRemoveQuery) toTarget:self withObject:nil];
}

- (IBAction)doRemoveQuery {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [removeQueryLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [removeCriticalTextField stringValue];
    int total = [mongoDB countInDB:dbname 
                        collection:collectionname 
                              user:user 
                          password:password 
                          critical:critical];
    [mongoDB removeInDB:dbname 
             collection:collectionname 
                   user:user 
               password:password 
               critical:critical];
    [removeResultsTextField setStringValue:[NSString stringWithFormat:@"Affected Rows: %d", total]];
    [removeQueryLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction) insertQuery:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doInsertQuery) toTarget:self withObject:nil];
}

- (void)doInsertQuery {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [insertLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *insertData = [insertDataTextView string];
    [mongoDB insertInDB:dbname 
             collection:collectionname 
                   user:user 
               password:password 
             insertData:insertData];
    [insertResultsTextField setStringValue:@"Completed!"];
    [insertLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction) indexQuery:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doIndexQuery) toTarget:self withObject:nil];
}

- (void)doIndexQuery {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [indexLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB indexInDB:dbname 
                                                                            collection:collectionname 
                                                                                  user:user 
                                                                              password:password]];
    indexesOutlineViewController.results = results;
    [indexesOutlineViewController.myOutlineView reloadData];
    [results release];
    [indexLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction) ensureIndex:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doEnsureIndex) toTarget:self withObject:nil];
}

- (void) doEnsureIndex {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [indexLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *indexData = [indexTextField stringValue];
    [mongoDB ensureIndexInDB:dbname 
                  collection:collectionname 
                        user:user 
                    password:password 
                   indexData:indexData];
    [self indexQuery:nil];
    [indexLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}


- (IBAction) reIndex:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doReIndex) toTarget:self withObject:nil];
}

- (void) doReIndex {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [indexLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    [mongoDB reIndexInDB:dbname 
              collection:collectionname 
                    user:user 
                password:password];
    [self indexQuery:nil];
    [indexLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}


- (IBAction) dropIndex:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doDropIndex) toTarget:self withObject:nil];
}

- (void) doDropIndex {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [indexLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *indexName = [indexTextField stringValue];
    [mongoDB dropIndexInDB:dbname 
                collection:collectionname 
                      user:user 
                  password:password 
                 indexName:indexName];
    [self indexQuery:nil];
    [indexLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction) mapReduce:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doMapReduce) toTarget:self withObject:nil];
}

- (void)doMapReduce {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [mrLoaderIndicator start];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *mapFunction = [mapFunctionTextView string];
    NSString *reduceFunction = [reduceFunctionTextView string];
    NSString *critical = [mrcriticalTextField stringValue];
    NSString *output = [mroutputTextField stringValue];
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:[mongoDB mapReduceInDB:dbname 
                                                                                collection:collectionname 
                                                                                      user:user 
                                                                                  password:password 
                                                                                     mapJs:mapFunction 
                                                                                  reduceJs:reduceFunction 
                                                                                  critical:critical 
                                                                                    output:output]];
    mrOutlineViewController.results = results;
    [mrOutlineViewController.myOutlineView reloadData];
    [results release];
    [mrLoaderIndicator stop];
    [NSThread exit];
    [pool release];
}

- (IBAction) export:(id)sender
{
    if (![[expPathTextField stringValue] isPresent]) {
        NSRunAlertPanel(@"Error", @"Please choose export path", @"OK", nil, nil);
        return;
    }
    if (![[expFieldsTextField stringValue] isPresent] && [[expTypePopUpButton selectedItem] tag]==1)
    {
        NSRunAlertPanel(@"Error", @"You need to specify fields", @"OK", nil, nil);
        return;
    }
    [NSThread detachNewThreadSelector:@selector(doExport) toTarget:self withObject:nil];
}

- (void)doExport
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    std::auto_ptr<std::ofstream> fileStream;
    std::ofstream * s = new std::ofstream( [[expPathTextField stringValue] UTF8String] , std::ios_base::out );
    fileStream.reset( s );
    std::ostream *outPtr = &std::cout;
    outPtr = s;
    if ( ! s->good() ) {
        NSRunAlertPanel(@"Error", [NSString stringWithFormat:@"Couldn't open [%@]", [expPathTextField stringValue]], @"OK", nil, nil);
    }
    std::ostream &out = *outPtr;
    bool _jsonArray = false;
    if ([expJsonArrayCheckBox state] == 1) {
        _jsonArray = true;
    }
    unsigned int exportType = [[expTypePopUpButton selectedItem] tag];
    [expResultsTextField setStringValue:@"Start exporting"];
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    NSString *critical = [expCriticalTextField stringValue];
    NSString *fields = [expFieldsTextField stringValue];
    NSString *sort = [expSortTextField stringValue];
    NSNumber *skip = [NSNumber numberWithInt:[expSkipTextField intValue]];
    NSNumber *limit = [NSNumber numberWithInt:[expLimitTextField intValue]];
    long long int total = [mongoDB countInDB:dbname 
                                  collection:collectionname 
                                        user:user 
                                    password:password 
                                    critical:critical];
    if (total == 0) {
        [expResultsTextField setStringValue:@"No data to export!"];
        return;
    }
    
    if ( exportType == 1 ) {
        out << [fields UTF8String] << std::endl;
    }else if (_jsonArray) {
        out << '[';
    }

    
    [expProgressIndicator setUsesThreadedAnimation:YES];
    [expProgressIndicator startAnimation: self];
    [expProgressIndicator setDoubleValue:0];
    std::auto_ptr<mongo::DBClientCursor> cursor = [mongoDB findCursorInDB:dbname 
                                                               collection:collectionname 
                                                                     user:user 
                                                                 password:password 
                                                                 critical:critical 
                                                                   fields:fields 
                                                                     skip:skip 
                                                                    limit:limit
                                                                     sort:sort];
    unsigned int i = 1;
    while( cursor->more() )
    {
        mongo::BSONObj obj = cursor->next();
        if ( exportType == 1 ) {
            NSArray *keys = [[NSArray alloc] initWithArray:[fields componentsSeparatedByString:@","]];
            unsigned int fieldIndex = 0;
            for (NSString *str in keys) {
                if (fieldIndex > 0) {
                    out << ",";
                }
                const mongo::BSONElement & e = obj.getFieldDotted([str UTF8String]);
                if ( ! e.eoo() ) {
                    out << e.jsonString( mongo::TenGen , false );
                }
                fieldIndex ++;
            }
            [keys release];
            out << std::endl;
        }else {
            if (_jsonArray && i != 1)
                out << ',';
            out << obj.jsonString();
            if (!_jsonArray)
            {
                out << std::endl;
            }
        }
        [expProgressIndicator setDoubleValue:(double)i/total*100];
        i ++;
    }
    if ( exportType == 1 && _jsonArray) 
        out << ']' << std::endl;
    [expProgressIndicator stopAnimation: self];
    [expResultsTextField setStringValue:[NSString stringWithFormat:@"Exported %d records.", total]];
    [NSThread exit];
    [pool release];
}

- (IBAction) import:(id)sender
{
    if (![[impPathTextField stringValue] isPresent]) {
        NSRunAlertPanel(@"Error", @"Please choose import file", @"OK", nil, nil);
        return;
    }
    if (![[expFieldsTextField stringValue] isPresent] && [[expTypePopUpButton selectedItem] tag]==1)
    {
        NSRunAlertPanel(@"Error", @"You need to specify fields", @"OK", nil, nil);
        return;
    }
    [NSThread detachNewThreadSelector:@selector(doImport) toTarget:self withObject:nil];
}

- (void)doImport
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [impProgressIndicator setUsesThreadedAnimation:YES];
    [impProgressIndicator startAnimation: self];
    [impProgressIndicator setDoubleValue:0];
    
    long long fileSize = 0;
    std::istream * in = &std::cin;
    std::ifstream file( [[impPathTextField stringValue] UTF8String] , std::ios_base::in);
    in = &file;
    fileSize = boost::filesystem::file_size( [[impPathTextField stringValue] UTF8String] );
    bool _ignoreBlanks = false;
    bool _headerLine = false;
    bool _jsonArray = false;
    bool _stopOnError = false;
    if ([impHeaderlineCheckBox state] == 1)
    {
        _headerLine = true;
    }
    if ([impJsonArrayCheckBox state] == 1) {
        _jsonArray = true;
    }
    if ([impStopOnErrorCheckBox state] == 1) {
        _stopOnError = true;
    }
    unsigned int _type = [[impTypePopUpButton selectedItem] tag];
    std::string _sep;
    if (_type == 1)
    {
        _sep = ",";
    }else if(_type == 2){
        _sep = "\t";
    }
    std::vector<std::string> _fields;
    if (!_headerLine && [[impFieldsTextField stringValue] isPresent])
    {
        
        NSArray *keys = [[NSArray alloc] initWithArray:[[impFieldsTextField stringValue] componentsSeparatedByString:@","]];
        for (NSString *str in keys) {
            _fields.push_back([str UTF8String]);
        }
        [keys release];
    }
    
    if (_type!=0 && !_headerLine && _fields.empty())
    {
        NSRunAlertPanel(@"Error", @"Please check headerline", @"OK", nil, nil);
        return;
    }
    
    
    NSString *user=nil;
    NSString *password=nil;
    Database *db = [databasesArrayController dbInfo:conn name:dbname];
    if (db) {
        user = db.user;
        password = db.password;
    }
    [db release];
    
    if ([impDropCheckBox state] == 1)
    {
        [mongoDB dropCollection:collectionname forDB:dbname user:user password:password];
    }
    
    if ([impIgnoreBlanksCheckBox state] == 1)
    {
        _ignoreBlanks = true;
    }
    
    int errors = 0;
    int num = 0;
    const int BUF_SIZE = 1024 * 1024 * 4;
    boost::scoped_array<char> line(new char[BUF_SIZE+2]);
    char * buf = line.get();
    while ( _jsonArray || in->rdstate() == 0 ) {
        if (_jsonArray) {
            if (buf == line.get()) { //first pass
                in->read(buf, BUF_SIZE);
                if (!(in->rdstate() & std::ios_base::eofbit))
                {
                    NSRunAlertPanel(@"Error", @"JSONArray file too large", @"OK", nil, nil);
                    return;
                }
                buf[ in->gcount() ] = '\0';
            }
        }else {
            buf = line.get();
            in->getline( buf , BUF_SIZE );
        }
        if (!((!(in->rdstate() & std::ios_base::badbit)) && (!(in->rdstate() & std::ios_base::failbit) || (in->rdstate() & std::ios_base::eofbit))))
        {
            NSRunAlertPanel(@"Error", @"unknown error reading file", @"OK", nil, nil);
            return;
        }
        
        int len = 0;
        if (strncmp("\xEF\xBB\xBF", buf, 3) == 0) { // UTF-8 BOM (notepad is stupid)
            buf += 3;
            len += 3;
        }
        
        if (_jsonArray) {
            while (buf[0] != '{' && buf[0] != '\0') {
                len++;
                buf++;
            }
            if (buf[0] == '\0')
                break;
        }else {
            while (std::isspace( buf[0] )) {
                len++;
                buf++;
            }
            if (buf[0] == '\0')
                continue;
            len += strlen( buf );
        }
        
        try {
            mongo::BSONObj o;
            if (_jsonArray) {
                int jslen;
                o = mongo::fromjson(buf, &jslen);
                len += jslen;
                buf += jslen;
            }else {
                o = [self parseCSVLine:buf type:_type sep:_sep.c_str() headerLine:_headerLine ignoreBlanks:_ignoreBlanks fields:_fields];NSLog(@"%@", [NSString stringWithUTF8String:o.jsonString( mongo::TenGen , false ).c_str()]);
            }
            if ( _headerLine ) {
                _headerLine = false;
            }else{
                [mongoDB insertInDB:dbname 
                             collection:collectionname 
                                   user:user 
                               password:password 
                             insertData:[NSString stringWithUTF8String:o.jsonString( mongo::TenGen , false ).c_str()]
                 ];
            }
            
            num++;
        }catch ( std::exception& e ) {
            std::cout << "exception:" << e.what() << std::endl;
            std::cout << buf << std::endl;
            errors++;
            
            if (_stopOnError || _jsonArray)
                break;
        }
    }
    
    [impProgressIndicator stopAnimation: self];
    [impResultsTextField setStringValue:[NSString stringWithFormat:@"Imported %d records, %d failed", num, errors]];
    [NSThread exit];
    [pool release];
}

- (IBAction)removeRecord:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doRemoveRecord) toTarget:self withObject:nil];
}

- (void)doRemoveRecord
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([findResultsViewController.myOutlineView selectedRow] != -1)
    {
        id currentItem = [findResultsViewController.myOutlineView itemAtRow:[findResultsViewController.myOutlineView selectedRow]];
        //NSLog(@"%@", [findResultsViewController rootForItem:currentItem]);
        [removeQueryLoaderIndicator start];
        NSString *user=nil;
        NSString *password=nil;
        Database *db = [databasesArrayController dbInfo:conn name:dbname];
        if (db) {
            user = db.user;
            password = db.password;
        }
        [db release];
        NSString *critical;
        if ([[currentItem objectForKey:@"type"] isEqualToString:@"ObjectId"]) {
            critical = [NSString stringWithFormat:@"{_id:ObjectId(\"%@\")}", [currentItem objectForKey:@"value"]];
        }else if ([[currentItem objectForKey:@"type"] isEqualToString:@"String"]) {
            critical = [NSString stringWithFormat:@"{_id:\"%@\"}", [currentItem objectForKey:@"value"]];
        }else {
            critical = [NSString stringWithFormat:@"{_id:%@}", [currentItem objectForKey:@"value"]];
        }NSLog(@"%@", critical);
        [mongoDB removeInDB:dbname 
                 collection:collectionname 
                       user:user 
                   password:password 
                   critical:critical];
        [removeQueryLoaderIndicator stop];
        [self findQuery:nil];
    }
    [NSThread exit];
    [pool release];
}

- (void)controlTextDidChange:(NSNotification *)nd
{
	NSTextField *ed = [nd object];
    
	if (ed == criticalTextField || ed == fieldsTextField || ed == sortTextField || ed == skipTextField || ed == limitTextField) {
        [self findQueryComposer:nil];
    } else if (ed == updateCriticalTextField || ed == updateSetTextField) {
        [self updateQueryComposer:nil];
    } else if (ed == removeCriticalTextField) {
        [self removeQueryComposer:nil];
    } else if (ed == expCriticalTextField || ed == expFieldsTextField || ed == expSortTextField || ed == expSkipTextField || ed == expLimitTextField) {
        [self exportQueryComposer:nil];
    }

}

- (IBAction) findQueryComposer:(id)sender
{
    NSString *critical;
    if ([[criticalTextField stringValue] isPresent]) {
        if ([[criticalTextField stringValue] hasPrefix:@"{"]) {
            critical = [[NSString alloc] initWithString:[criticalTextField stringValue]];
        }else {
            critical = [[NSString alloc] initWithFormat:@"{\"_id\":\"%@\"}",[criticalTextField stringValue]];
        }
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    
    NSString *jsFields;
    if ([[fieldsTextField stringValue] isPresent]) {
        NSArray *keys = [[NSArray alloc] initWithArray:[[fieldsTextField stringValue] componentsSeparatedByString:@","]];
        NSMutableArray *tmpstr = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        for (NSString *str in keys) {
            [tmpstr addObject:[NSString stringWithFormat:@"%@:1", str]];
        }
        jsFields = [[NSString alloc] initWithFormat:@", {%@}", [tmpstr componentsJoinedByString:@","] ];
        [keys release];
        [tmpstr release];
    }else {
        jsFields = [[NSString alloc] initWithString:@""];
    }
    
    NSString *sort;
    if ([[sortTextField stringValue] isPresent]) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)"];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", [skipTextField intValue]];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", [limitTextField intValue]];
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, critical, jsFields, sort, skip, limit];
    [critical release];
    [jsFields release];
    [sort release];
    [skip release];
    [limit release];
    [findQueryTextField setStringValue:query];
}

- (IBAction)updateQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    NSString *critical;
    if ([[updateCriticalTextField stringValue] isPresent]) {
        critical = [[NSString alloc] initWithString:[updateCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *sets;
    if ([[updateSetTextField stringValue] isPresent]) {
        //sets = [[NSString alloc] initWithFormat:@", {$set:%@}", [updateSetTextField stringValue]];
        sets = [[NSString alloc] initWithFormat:@", %@", [updateSetTextField stringValue]];
    }else {
        sets = [[NSString alloc] initWithString:@""];
    }
    NSString *upset;
    if ([upsetCheckBox state] == 1) {
        upset = [[NSString alloc] initWithString:@", true"];
    }else {
        upset = [[NSString alloc] initWithString:@", false"];
    }

    NSString *query = [NSString stringWithFormat:@"db.%@.update(%@%@%@)", col, critical, sets, upset];
    [critical release];
    [sets release];
    [upset release];
    [updateQueryTextField setStringValue:query];
}

- (IBAction)removeQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    NSString *critical;
    if ([[removeCriticalTextField stringValue] isPresent]) {
        critical = [[NSString alloc] initWithString:[removeCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *query = [NSString stringWithFormat:@"db.%@.remove(%@)", col, critical];
    [critical release];
    [removeQueryTextField setStringValue:query];
}

- (IBAction) exportQueryComposer:(id)sender
{
    NSString *critical;
    if ([[expCriticalTextField stringValue] isPresent]) {
        critical = [[NSString alloc] initWithString:[expCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    
    NSString *jsFields;
    if ([[expFieldsTextField stringValue] isPresent]) {
        NSArray *keys = [[NSArray alloc] initWithArray:[[expFieldsTextField stringValue] componentsSeparatedByString:@","]];
        NSMutableArray *tmpstr = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        for (NSString *str in keys) {
            [tmpstr addObject:[NSString stringWithFormat:@"%@:1", str]];
        }
        jsFields = [[NSString alloc] initWithFormat:@", {%@}", [tmpstr componentsJoinedByString:@","] ];
        [keys release];
        [tmpstr release];
    }else {
        jsFields = [[NSString alloc] initWithString:@""];
    }
    
    NSString *sort;
    if ([[expSortTextField stringValue] isPresent]) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)"];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", [expSkipTextField intValue]];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", [expLimitTextField intValue]];
    NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, critical, jsFields, sort, skip, limit];
    [critical release];
    [jsFields release];
    [sort release];
    [skip release];
    [limit release];
    [expQueryTextField setStringValue:query];
}

- (void)showEditWindow:(id)sender
{
    switch([findResultsViewController.myOutlineView selectedRow])
	{
		case -1:
			break;
		default:{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findQuery:) name:kJsonWindowSaved object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsonWindowWillClose:) name:kJsonWindowWillClose object:nil];
            id currentItem = [findResultsViewController.myOutlineView itemAtRow:[findResultsViewController.myOutlineView selectedRow]];
            //NSLog(@"%@", [findResultsViewController rootForItem:currentItem]);
            JsonWindowController *jsonWindowController = [[JsonWindowController alloc] init];
            jsonWindowController.managedObjectContext = self.managedObjectContext;
            jsonWindowController.conn = conn;
            jsonWindowController.dbname = dbname;
            jsonWindowController.collectionname = collectionname;
            jsonWindowController.mongoDB = mongoDB;
            jsonWindowController.jsonDict = [findResultsViewController rootForItem:currentItem];
            [jsonWindowController showWindow:sender];
			break;
        }
	}
}

- (void)jsonWindowWillClose:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)chooseExportPath:(id)sender
{
    NSSavePanel *tvarNSSavePanelObj	= [NSSavePanel savePanel];
    int tvarInt	= [tvarNSSavePanelObj runModal];
    if(tvarInt == NSOKButton){
     	NSLog(@"doSaveAs we have an OK button");
        //NSString * tvarDirectory = [tvarNSSavePanelObj directory];
        //NSLog(@"doSaveAs directory = %@",tvarDirectory);
        NSString * tvarFilename = [tvarNSSavePanelObj filename];
        NSLog(@"doSaveAs filename = %@",tvarFilename);
        [expPathTextField setStringValue:tvarFilename];
    } else if(tvarInt == NSCancelButton) {
     	NSLog(@"doSaveAs we have a Cancel button");
     	return;
    } else {
     	NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3d",tvarInt);
     	return;
    } // end if
}

- (IBAction)chooseImportPath:(id)sender
{
    NSOpenPanel *tvarNSOpenPanelObj	= [NSOpenPanel openPanel];
    NSInteger tvarNSInteger	= [tvarNSOpenPanelObj runModalForTypes:nil];
    if(tvarNSInteger == NSOKButton){
     	NSLog(@"doOpen we have an OK button");
        //NSString * tvarDirectory = [tvarNSOpenPanelObj directory];
        //NSLog(@"doOpen directory = %@",tvarDirectory);
        NSString * tvarFilename = [tvarNSOpenPanelObj filename];
        NSLog(@"doOpen filename = %@",tvarFilename);
        [impPathTextField setStringValue:tvarFilename];
    } else if(tvarNSInteger == NSCancelButton) {
     	NSLog(@"doOpen we have a Cancel button");
     	return;
    } else {
     	NSLog(@"doOpen tvarInt not equal 1 or zero = %3d",tvarNSInteger);
     	return;
    } // end if
}

- (mongo::BSONObj)parseCSVLine:(char *) line type:(int)_type sep:(const char *)_sep headerLine:(bool)_headerLine ignoreBlanks:(bool)_ignoreBlanks fields:(std::vector<std::string>&)_fields
{
    if ( _type == 0 ) {
        char * end = ( line + strlen( line ) ) - 1;
        while ( std::isspace(*end) ) {
            *end = 0;
            end--;
        }
        return mongo::fromjson( line );
    }
    mongo::BSONObjBuilder b;
    
    unsigned int pos=0;
    while ( line[0] ) {
        std::string name;
        if ( pos < _fields.size() ) {
            name = _fields[pos];
        }else {
            std::stringstream ss;
            ss << "field" << pos;
            name = ss.str();
        }
        pos++;
        
        bool done = false;
        std::string data;
        char * end;
        if ( _type == 1 && line[0] == '"' ) {
            line++; //skip first '"'
            
            while (true) {
                end = strchr( line , '"' );NSLog(@"%s", line);
                if (!end) {
                    data += line;
                    done = true;
                    break;
                } else if (end[1] == '"') {
                    // two '"'s get appended as one
                    data.append(line, end-line+1); //include '"'
                    line = end+2; //skip both '"'s
                } else if (end[-1] == '\\') {
                    // "\\\"" gets appended as '"'
                    data.append(line, end-line-1); //exclude '\\'
                    data.append("\"");
                    line = end+1; //skip the '"'
                } else {
                    data.append(line, end-line);
                    line = end+2; //skip '"' and ','
                    break;
                }
            }
        } else {
            end = strstr( line , _sep );NSLog(@"end: %s", end);
            if ( ! end ) {
                done = true;
                data = std::string( line );
            } else {
                data = std::string( line , end - line );
                line = end+1;
            }
        }
        
        if ( _headerLine ) {
            while ( std::isspace( data[0] ) )
                data = data.substr( 1 );
            _fields.push_back( data );
        }else{
            if ( !b.appendAsNumber( name , data ) && !(_ignoreBlanks && data.size() == 0) ){
                b.append( name , data );
            }
        }
        
        if ( done )
            break;
    }
    return b.obj();
}

@end
