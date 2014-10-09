//
//  MHQueryWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHQueryWindowController.h"
#import "MHResultsOutlineViewController.h"
#import "NSString+MongoHub.h"
#import "MHJsonWindowController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "MODHelper.h"
#import "MHConnectionStore.h"
#import "NSViewHelpers.h"
#import "NSTextView+MongoHub.h"
#import "UKSyntaxColoredTextViewController.h"
#import "MHTabViewController.h"

#define IS_OBJECT_ID(value) ([value length] == 24 && [[value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefABCDEF"]] length] == 0)

@interface MHQueryWindowController ()
@property (nonatomic, readwrite, assign) NSSegmentedControl *segmentedControl;
@property (nonatomic, readwrite, assign) NSTabView *tabView;

@property (nonatomic, readwrite, retain) MODCollection *collection;
@property (nonatomic, readwrite, retain) MHConnectionStore *connectionStore;

@property (nonatomic, readwrite, retain) MHResultsOutlineViewController *findResultsViewController;
@property (nonatomic, readwrite, assign) NSOutlineView *findResultsOutlineView;
@property (nonatomic, readwrite, assign) NSButton *findRemoveButton;
@property (nonatomic, readwrite, assign) NSComboBox *findCriteriaComboBox;
@property (nonatomic, readwrite, assign) NSTokenField *findFieldsTextField;
@property (nonatomic, readwrite, assign) NSTextField *findSkipTextField;
@property (nonatomic, readwrite, assign) NSTextField *findLimitTextField;
@property (nonatomic, readwrite, assign) NSTextField *findSortTextField;
@property (nonatomic, readwrite, assign) NSTextField *findTotalResultsTextField;
@property (nonatomic, readwrite, assign) NSTextField *findQueryTextField;
@property (nonatomic, readwrite, assign) NSProgressIndicator *findQueryLoaderIndicator;

@property (nonatomic, readwrite, assign) NSButton *insertButton;
@property (nonatomic, readwrite, assign) NSTextView *insertDataTextView;
@property (nonatomic, readwrite, assign) NSTextField *insertResultsTextField;
@property (nonatomic, readwrite, assign) NSProgressIndicator *insertLoaderIndicator;
@property (nonatomic, readwrite, strong) UKSyntaxColoredTextViewController *syntaxColoringController;

@property (nonatomic, readwrite, assign) NSButton *updateButton;
@property (nonatomic, readwrite, assign) NSTextField *updateCriteriaTextField;
@property (nonatomic, readwrite, assign) NSTextField *updateUpdateTextField;
@property (nonatomic, readwrite, assign) NSButton *updateUpsetCheckBox;
@property (nonatomic, readwrite, assign) NSButton *updateMultiCheckBox;
@property (nonatomic, readwrite, assign) NSTextField *updateResultsTextField;
@property (nonatomic, readwrite, assign) NSTextField *updateQueryTextField;
@property (nonatomic, readwrite, assign) NSProgressIndicator *updateQueryLoaderIndicator;

@property (nonatomic, readwrite, assign) NSButton *removeButton;
@property (nonatomic, readwrite, assign) NSTextField *removeCriteriaTextField;
@property (nonatomic, readwrite, assign) NSTextField *removeResultsTextField;
@property (nonatomic, readwrite, assign) NSTextField *removeQueryTextField;
@property (nonatomic, readwrite, assign) NSProgressIndicator *removeQueryLoaderIndicator;

@property (nonatomic, readwrite, assign) NSTextField *indexTextField;
@property (nonatomic, readwrite, retain) MHResultsOutlineViewController *indexesOutlineViewController;
@property (nonatomic, readwrite, assign) NSProgressIndicator *indexLoaderIndicator;
@property (nonatomic, readwrite, assign) NSOutlineView *indexOutlineView;
@property (nonatomic, readwrite, assign) NSButton *indexDropButton;
@property (nonatomic, readwrite, assign) NSButton *indexCreateButton;

@property (nonatomic, readwrite, retain) MHResultsOutlineViewController *mrOutlineViewController;
@property (nonatomic, readwrite, assign) NSOutlineView *mrOutlineView;
@property (nonatomic, readwrite, assign) NSProgressIndicator *mrLoaderIndicator;
@property (nonatomic, readwrite, assign) NSTextField *mrOutputTextField;
@property (nonatomic, readwrite, assign) NSTextField *mrCriteriaTextField;
@property (nonatomic, readwrite, assign) NSTextView *mrMapFunctionTextView;
@property (nonatomic, readwrite, assign) NSTextView *mrReduceFunctionTextView;

- (void)selectBestTextField;

@end

@implementation MHQueryWindowController
@synthesize collection = _collection, connectionStore = _connectionStore;
@synthesize tabView = _tabView, segmentedControl = _segmentedControl;

@synthesize findResultsViewController = _findResultsViewController, findResultsOutlineView = _findResultsOutlineView, findRemoveButton = _findRemoveButton, findCriteriaComboBox = _findCriteriaComboBox, findFieldsTextField = _findFieldsTextField, findSkipTextField = _findSkipTextField, findLimitTextField = _findLimitTextField, findSortTextField = _findSortTextField, findTotalResultsTextField = _findTotalResultsTextField, findQueryTextField = _findQueryTextField, findQueryLoaderIndicator = _findQueryLoaderIndicator;

@synthesize insertDataTextView = _insertDataTextView, insertResultsTextField = _insertResultsTextField, insertLoaderIndicator = _insertLoaderIndicator, insertButton = _insertButton;
@synthesize syntaxColoringController = _syntaxColoringController;

@synthesize updateButton = _updateButton, updateCriteriaTextField = _updateCriteriaTextField, updateUpdateTextField = _updateUpdateTextField, updateUpsetCheckBox = _updateUpsetCheckBox, updateMultiCheckBox = _updateMultiCheckBox, updateResultsTextField = _updateResultsTextField, updateQueryTextField = _updateQueryTextField, updateQueryLoaderIndicator = _updateQueryLoaderIndicator;

@synthesize removeButton = _removeButton, removeCriteriaTextField = _removeCriteriaTextField, removeResultsTextField = _removeResultsTextField, removeQueryTextField = _removeQueryTextField, removeQueryLoaderIndicator = _removeQueryLoaderIndicator;

@synthesize indexTextField = _indexTextField, indexesOutlineViewController = _indexesOutlineViewController, indexLoaderIndicator = _indexLoaderIndicator, indexOutlineView = _indexOutlineView, indexDropButton = _indexDropButton, indexCreateButton = _indexCreateButton;

@synthesize mrOutlineViewController = _mrOutlineViewController, mrOutlineView = _mrOutlineView, mrLoaderIndicator = _mrLoaderIndicator, mrOutputTextField = _mrOutputTextField, mrCriteriaTextField = _mrCriteriaTextField, mrMapFunctionTextView = _mrMapFunctionTextView, mrReduceFunctionTextView = _mrReduceFunctionTextView;

- (instancetype)initWithCollection:(MODCollection *)collection connectionStore:(MHConnectionStore *)connectionStore
{
    self = [self init];
    if (self) {
        self.collection = collection;
        self.connectionStore = connectionStore;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedNotification:) name:MODCollection_Dropped_Notification object:self.collection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedNotification:) name:MODDatabase_Dropped_Notification object:self.collection.database];
        [self.collection addObserver:self forKeyPath:@"database" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.collection addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:nil object:nil];
    [self.collection removeObserver:self forKeyPath:@"database"];
    [self.collection removeObserver:self forKeyPath:@"name"];
    
    self.syntaxColoringController = nil;
    self.indexesOutlineViewController = nil;
    self.mrOutlineViewController = nil;
    self.findResultsViewController = nil;
    self.collection = nil;
    self.connectionStore = nil;
    
    [_jsonWindowControllers release];
    
    [super dealloc];
}

- (void)droppedNotification:(NSNotification *)notification
{
    NSLog(@"notif %@ %@", notification.name, notification.object);
    NSParameterAssert(notification.object == self.collection || notification.object == self.collection.database);
    if (notification.object == self.collection || notification.object == self.collection.database) {
        [self.tabViewController removeTabItemViewController:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.collection == object) {
        if ([keyPath isEqualToString:@"name"]) {
            self.title = self.collection.absoluteName;
        } else if ([keyPath isEqualToString:@"database"]) {
            self.title = self.collection.absoluteName;
            [NSNotificationCenter.defaultCenter removeObserver:self name:nil object:change[NSKeyValueChangeOldKey]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedNotification:) name:MODDatabase_Dropped_Notification object:self.collection.database];
        }
    }
}

- (NSString *)nibName
{
    return @"MHQueryWindow";
}

- (NSString *)formatedQuerySort
{
    NSString *result;
    
    result = self.findSortTextField.stringValue.mh_stringByTrimmingWhitespace;
    if ([result length] == 0) {
        result = @"{ \"_id\": 1}";
    }
    return result;
}

- (NSString *)formatedQueryWithReplace:(BOOL)replace
{
    NSString *query = @"";
    NSString *value;
    NSString *valueWithoutDoubleQuotes = nil;
  
    value = [self.findCriteriaComboBox.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([value hasPrefix:@"\""] && [value hasSuffix:@"\""] && ![value isEqualToString:@"\""]) {
        valueWithoutDoubleQuotes = [value substringWithRange:NSMakeRange(1, value.length - 2)];
    }
    if (IS_OBJECT_ID(value) || IS_OBJECT_ID(valueWithoutDoubleQuotes)) {
        // 24 char length and only hex char... it must be an objectid
        if (valueWithoutDoubleQuotes) {
            query = [NSString stringWithFormat:@"{\"_id\": ObjectId(\"%@\")}", valueWithoutDoubleQuotes];
        } else {
            query = [NSString stringWithFormat:@"{\"_id\": ObjectId(\"%@\")}", value];
        }
    } else if ([value length] > 0) {
        if ([value hasPrefix:@"{"]) {
            NSString *innerValue;
            
            innerValue = [[value substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([innerValue hasPrefix:@"\"$oid\""] || [innerValue hasPrefix:@"'$iod'"]) {
                query = [NSString stringWithFormat:@"{\"_id\": %@ }",value];
            } else {
                query = value;
            }
        } else if ([value hasPrefix:@"ObjectId"]) {
          query = [NSString stringWithFormat:@"{\"_id\": %@}",value];
        } else if ([value hasPrefix:@"\"$oid\""] || [value hasPrefix:@"'$iod'"]) {
          query = [NSString stringWithFormat:@"{\"_id\": {%@}}",value];
        } else if ([value hasPrefix:@"\""]) {
            query = [NSString stringWithFormat:@"{\"_id\": %@}",value];
        } else {
            query = [NSString stringWithFormat:@"{\"_id\": \"%@\"}",value];
        }
    }
    if (replace) {
        self.findCriteriaComboBox.stringValue = query;
        [self.findCriteriaComboBox selectText:nil];
    }
    return query;
}

- (void)awakeFromNib
{
    self.findResultsViewController = [[[MHResultsOutlineViewController alloc] initWithOutlineView:self.findResultsOutlineView] autorelease];
    self.indexesOutlineViewController = [[[MHResultsOutlineViewController alloc] initWithOutlineView:self.indexOutlineView] autorelease];
    self.mrOutlineViewController = [[[MHResultsOutlineViewController alloc] initWithOutlineView:self.mrOutlineView] autorelease];
    
    self.syntaxColoringController = [[UKSyntaxColoredTextViewController alloc] init];
    self.syntaxColoringController.delegate = self;
    self.syntaxColoringController.view = self.insertDataTextView;
    
    self.title = self.collection.absoluteName;
    _jsonWindowControllers = [[NSMutableDictionary alloc] init];
    [self findQueryComposer:nil];
    [self updateQueryComposer:nil];
    [self removeQueryComposer:nil];
    
    [self.insertDataTextView mh_jsonSetup];
    [self.mrReduceFunctionTextView mh_jsonSetup];
    [self.mrMapFunctionTextView mh_jsonSetup];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(findResultOutlineViewNotification:) name:NSOutlineViewSelectionDidChangeNotification object:self.findResultsOutlineView];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(indexOutlineViewNotification:) name:NSOutlineViewSelectionDidChangeNotification object:self.indexOutlineView];
}

- (void)select
{
    [super select];
    [self selectBestTextField];
}

- (void)_removeQuery
{
    MODSortedMutableDictionary *criteria;
    NSError *error;
    
    [self.removeQueryLoaderIndicator startAnimation:nil];
    criteria = [MODRagelJsonParser objectsFromJson:self.removeCriteriaTextField.stringValue withError:&error];
    if (error) {
        self.removeResultsTextField.stringValue = @"Error!";
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", error.localizedDescription);
        [self.removeQueryLoaderIndicator stopAnimation:nil];
        [NSViewHelpers cancelColorForTarget:self.removeResultsTextField selector:@selector(setTextColor:)];
        [NSViewHelpers setColor:self.removeResultsTextField.textColor fromColor:NSColor.redColor toTarget:self.removeResultsTextField withSelector:@selector(setTextColor:) delay:1];
    } else {
        [self.collection countWithCriteria:criteria readPreferences:nil callback:^(int64_t count, MODQuery *mongoQuery) {
            [self.collection removeWithCriteria:criteria callback:^(MODQuery *mongoQuery) {
                NSColor *flashColor;
                
                if (mongoQuery.error) {
                    self.removeResultsTextField.stringValue = @"Error!";
                    NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
                    flashColor = NSColor.redColor;
                } else {
                    self.removeResultsTextField.stringValue = [NSString stringWithFormat:@"Removed Documents: %lld", count];
                    flashColor = NSColor.greenColor;
                }
                [self.removeQueryLoaderIndicator stopAnimation:nil];
                [NSViewHelpers cancelColorForTarget:self.removeResultsTextField selector:@selector(setTextColor:)];
                [NSViewHelpers setColor:self.removeResultsTextField.textColor fromColor:flashColor toTarget:self.removeResultsTextField withSelector:@selector(setTextColor:) delay:1];
            }];
        }];
    }
}

- (void)removeAllDocumentsPanelDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    switch (returnCode) {
        case NSAlertAlternateReturn:
            [self _removeQuery];
            break;
            
        default:
            break;
    }
}

- (void)indexOutlineViewNotification:(NSNotification *)notification
{
    self.indexDropButton.enabled = self.indexOutlineView.selectedRowIndexes.count != 0;
}

- (void)controlTextDidChange:(NSNotification *)nd
{
    NSTextField *ed = [nd object];
    
    if (ed == self.findCriteriaComboBox || ed == self.findFieldsTextField || ed == self.findSortTextField || ed == self.findSkipTextField || ed == self.findLimitTextField) {
        [self findQueryComposer:nil];
    } else if (ed == self.updateCriteriaTextField || ed == self.updateUpdateTextField) {
        [self updateQueryComposer:nil];
    } else if (ed == self.removeCriteriaTextField) {
        [self removeQueryComposer:nil];
    }

}

- (void)showEditWindow:(id)sender
{
    for (NSDictionary *document in self.findResultsViewController.selectedDocuments) {
        id idValue;
        id jsonWindowControllerKey;
        
        MHJsonWindowController *jsonWindowController;
        
        idValue = [document objectForKey:@"objectvalueid"];
        if (idValue) {
            jsonWindowControllerKey = [MODClient convertObjectToJson:[MODSortedMutableDictionary sortedDictionaryWithObject:idValue forKey:@"_id"] pretty:NO strictJson:NO];
        } else {
            jsonWindowControllerKey = document;
        }
        jsonWindowController = [_jsonWindowControllers objectForKey:jsonWindowControllerKey];
        if (!jsonWindowController) {
            jsonWindowController = [[MHJsonWindowController alloc] init];
            jsonWindowController.collection = self.collection;
            jsonWindowController.jsonDict = document;
            [jsonWindowController showWindow:sender];
            [_jsonWindowControllers setObject:jsonWindowController forKey:jsonWindowControllerKey];
            [jsonWindowController release];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findQuery:) name:kJsonWindowSaved object:jsonWindowController];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsonWindowWillClose:) name:kJsonWindowWillClose object:jsonWindowController];
        } else {
            [jsonWindowController showWindow:self];
        }
    }
}

- (void)jsonWindowWillClose:(NSNotification *)notification
{
    MHJsonWindowController *jsonWindowController = notification.object;
    id idValue;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJsonWindowSaved object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJsonWindowWillClose object:notification.object];
    idValue = [jsonWindowController.jsonDict objectForKey:@"objectvalueid"];
    if (idValue) {
        [_jsonWindowControllers removeObjectForKey:[MODClient convertObjectToJson:[MODSortedMutableDictionary sortedDictionaryWithObject:idValue forKey:@"_id"] pretty:NO strictJson:NO]];
    } else {
        [_jsonWindowControllers removeObjectForKey:jsonWindowController.jsonDict];
    }
}

- (IBAction)segmentedControlAction:(id)sender
{
    NSString *identifier;
    
    identifier = [[NSString alloc] initWithFormat:@"%ld", (long)self.segmentedControl.selectedSegment];
    [self.tabView selectTabViewItemWithIdentifier:identifier];
    [identifier release];
    [self selectBestTextField];
}

- (void)selectBestTextField
{
    [self.findQueryTextField.window makeFirstResponder:self.tabView.selectedTabViewItem.initialFirstResponder ];
}

@end

@implementation MHQueryWindowController (FindTab)

- (void)findResultOutlineViewNotification:(NSNotification *)notification
{
    self.findRemoveButton.enabled = self.findResultsOutlineView.selectedRowIndexes.count != 0;
}

- (IBAction)findQuery:(id)sender
{
    int limit = self.findLimitTextField.intValue;
    NSMutableArray *fields;
    NSString *jsonCriteria;
    NSString *jsonSort = self.formatedQuerySort;
    NSString *queryTitle = [self.findCriteriaComboBox.stringValue retain];
    MODSortedMutableDictionary *criteria = nil;
    MODSortedMutableDictionary *sort = nil;
    NSError *error = nil;
    
    [self findQueryComposer:nil];
    if (limit <= 0) {
        limit = 30;
    }
    jsonCriteria = [self formatedQueryWithReplace:YES];
    fields = [[NSMutableArray alloc] init];
    for (NSString *field in [self.findFieldsTextField.stringValue componentsSeparatedByString:@","]) {
        field = field.mh_stringByTrimmingWhitespace;
        if ([field length] > 0) {
            [fields addObject:field];
        }
    }
    [self.findQueryLoaderIndicator startAnimation:nil];

    if (jsonCriteria.length > 0) {
        criteria = [MODRagelJsonParser objectsFromJson:jsonCriteria withError:&error];
    } else {
        criteria = [MODSortedMutableDictionary sortedDictionary];
    }
    if (!error) {
        if (jsonSort.length > 0) {
            sort = [MODRagelJsonParser objectsFromJson:jsonSort withError:&error];
        } else {
            sort = [MODSortedMutableDictionary sortedDictionary];
        }
    }
    if (error) {
        NSColor *currentColor;
        
        self.findTotalResultsTextField.stringValue = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        self.findQueryTextField.stringValue = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        [NSViewHelpers cancelColorForTarget:self.findTotalResultsTextField selector:@selector(setTextColor:)];
        currentColor = self.findTotalResultsTextField.textColor;
        self.findTotalResultsTextField.textColor = NSColor.redColor;
        [NSViewHelpers setColor:currentColor fromColor:NSColor.redColor toTarget:self.findTotalResultsTextField withSelector:@selector(setTextColor:) delay:1];
        [self.findQueryLoaderIndicator stopAnimation:nil];
    } else {
        [self.collection findWithCriteria:criteria fields:fields skip:self.findSkipTextField.intValue limit:limit sort:sort callback:^(NSArray *documents, NSArray *bsonData, MODQuery *mongoQuery) {
            NSColor *currentColor;
            NSColor *flashColor;
            
            if (mongoQuery.error) {
                flashColor = [NSColor redColor];
                self.findTotalResultsTextField.stringValue = [NSString stringWithFormat:@"Error: %@", [mongoQuery.error localizedDescription]];
                self.findQueryTextField.stringValue = [NSString stringWithFormat:@"Error: %@", [mongoQuery.error localizedDescription]];
            } else {
                if ([queryTitle length] > 0) {
                    [self.connectionStore addNewQuery:@{
                                                        @"title": queryTitle,
                                                        @"sort": self.findSortTextField.stringValue,
                                                        @"fields": self.findFieldsTextField.stringValue,
                                                        @"limit": self.findLimitTextField.stringValue,
                                                        @"skip": self.findSkipTextField.stringValue
                                                        }
                                     withDatabaseName:@""
                                       collectionName:self.collection.name];
                }
                self.findResultsViewController.results = [MODHelper convertForOutlineWithObjects:documents bsonData:bsonData];
                [self.collection countWithCriteria:criteria readPreferences:nil callback:^(int64_t count, MODQuery *mongoQuery) {
                    self.findTotalResultsTextField.stringValue = [NSString stringWithFormat:@"Total Results: %lld (%0.2fs)", count, [[mongoQuery.userInfo objectForKey:@"timequery"] duration]];
                }];
                flashColor = [NSColor greenColor];
            }
            [NSViewHelpers cancelColorForTarget:self.findTotalResultsTextField selector:@selector(setTextColor:)];
            currentColor = self.findTotalResultsTextField.textColor;
            self.findTotalResultsTextField.textColor = flashColor;
            [NSViewHelpers setColor:currentColor fromColor:flashColor toTarget:self.findTotalResultsTextField withSelector:@selector(setTextColor:) delay:1];
            [self.findQueryLoaderIndicator stopAnimation:nil];
        }];
    }
    [fields release];
    [queryTitle release];
}

- (IBAction)expandFindResults:(id)sender
{
    [self.findResultsOutlineView expandItem:nil expandChildren:YES];
}

- (IBAction)collapseFindResults:(id)sender
{
    [self.findResultsOutlineView collapseItem:nil collapseChildren:YES];
}

- (IBAction)removeRecord:(id)sender
{
    NSMutableArray *documentIds;
    MODSortedMutableDictionary *criteria;
    MODSortedMutableDictionary *inCriteria;
    
    [self.removeQueryLoaderIndicator startAnimation:nil];
    documentIds = [[NSMutableArray alloc] init];
    for (NSDictionary *document in self.findResultsViewController.selectedDocuments) {
        [documentIds addObject:[document objectForKey:@"objectvalueid"]];
    }
    
    inCriteria = [[MODSortedMutableDictionary alloc] initWithObjectsAndKeys:documentIds, @"$in", nil];
    criteria = [[MODSortedMutableDictionary alloc] initWithObjectsAndKeys:inCriteria, @"_id", nil];
    [self.collection removeWithCriteria:criteria callback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
        } else {
            
        }
        [self.removeQueryLoaderIndicator stopAnimation:nil];
        [self findQuery:nil];
    }];
    [criteria release];
    [documentIds release];
    [inCriteria release];
}

- (IBAction)findQueryComposer:(id)sender
{
    NSString *criteria = [self formatedQueryWithReplace:NO];
    NSString *jsFields;
    NSString *sortValue = [self formatedQuerySort];
    NSString *sort;
    
    if (self.findFieldsTextField.stringValue.length > 0) {
        NSArray *keys = [[NSArray alloc] initWithArray:[self.findFieldsTextField.stringValue componentsSeparatedByString:@","]];
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
    
    if ([sortValue length] > 0) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)", sortValue];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", self.findSkipTextField.intValue];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", self.findLimitTextField.intValue];
    NSString *col = [NSString stringWithFormat:@"%@.%@", self.collection.name, self.collection.name];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, criteria, jsFields, sort, skip, limit];
    [jsFields release];
    [sort release];
    [skip release];
    [limit release];
    self.findQueryTextField.stringValue = query;
}

@end

@implementation MHQueryWindowController (InsertTab)

- (IBAction)insertQuery:(id)sender
{
    id objects;
    NSError *error;
    
    [self.insertLoaderIndicator startAnimation:nil];
    objects = [MODRagelJsonParser objectsFromJson:self.insertDataTextView.string withError:&error];
    if (error) {
        NSColor *currentColor;
        
        [self.insertLoaderIndicator stopAnimation:nil];
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", error.localizedDescription);
        self.insertResultsTextField.stringValue = @"Parsing error";
        [NSViewHelpers cancelColorForTarget:self.insertResultsTextField selector:@selector(setTextColor:)];
        currentColor = self.insertResultsTextField.textColor;
        self.insertResultsTextField.textColor = [NSColor redColor];
        [NSViewHelpers setColor:currentColor fromColor:[NSColor redColor] toTarget:self.insertResultsTextField withSelector:@selector(setTextColor:) delay:1];
    } else {
        if ([objects isKindOfClass:[MODSortedMutableDictionary class]]) {
            objects = [NSArray arrayWithObject:objects];
        }
        [self.collection insertWithDocuments:objects callback:^(MODQuery *mongoQuery) {
            NSColor *currentColor;
            NSColor *flashColor;
            
            [self.insertLoaderIndicator stopAnimation:nil];
            if (mongoQuery.error) {
                flashColor = [NSColor redColor];
                [self.insertResultsTextField setStringValue:@"Error!"];
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            } else {
                flashColor = [NSColor greenColor];
                [self.insertResultsTextField setStringValue:@"Completed!"];
            }
            [NSViewHelpers cancelColorForTarget:self.insertResultsTextField selector:@selector(setTextColor:)];
            currentColor = self.insertResultsTextField.textColor;
            self.insertResultsTextField.textColor = flashColor;
            [NSViewHelpers setColor:currentColor fromColor:flashColor toTarget:self.insertResultsTextField withSelector:@selector(setTextColor:) delay:1];
        }];
    }
}

@end

@implementation MHQueryWindowController (UpdateTab)

- (IBAction)updateQuery:(id)sender
{
    MODSortedMutableDictionary *criteria = nil;
    MODSortedMutableDictionary *update = nil;
    NSError *error = nil;
    
    [self.updateQueryLoaderIndicator startAnimation:nil];
    criteria = [MODRagelJsonParser objectsFromJson:self.updateCriteriaTextField.stringValue withError:&error];
    if (!error) {
        update = [MODRagelJsonParser objectsFromJson:self.updateUpdateTextField.stringValue withError:&error];
    }
    if (error) {
        self.updateResultsTextField.stringValue = @"Error!";
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", error.localizedDescription);
        [self.updateQueryLoaderIndicator stopAnimation:nil];
        [NSViewHelpers cancelColorForTarget:self.updateResultsTextField selector:@selector(setTextColor:)];
        [NSViewHelpers setColor:self.updateResultsTextField.textColor fromColor:NSColor.redColor toTarget:self.updateResultsTextField withSelector:@selector(setTextColor:) delay:1];
    } else {
        [self.collection countWithCriteria:criteria readPreferences:nil callback:^(int64_t count, MODQuery *mongoQuery) {
            MODSortedMutableDictionary *realUpdate;
            if (self.updateMultiCheckBox.state == 0 && count > 0) {
                count = 1;
            }
            
            realUpdate = [[MODSortedMutableDictionary alloc] initWithObjectsAndKeys:update, @"$set", nil];
            [self.collection updateWithCriteria:criteria update:realUpdate upsert:self.updateUpsetCheckBox.state multiUpdate:self.updateMultiCheckBox.state callback:^(MODQuery *mongoQuery) {
                NSColor *flashColor;
                
                if (mongoQuery.error) {
                    self.updateResultsTextField.stringValue = @"Error!";
                    NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
                    flashColor = NSColor.redColor;
                } else {
                    self.updateResultsTextField.stringValue = [NSString stringWithFormat:@"Updated Documents: %lld", count];
                    flashColor = NSColor.greenColor;
                }
                [self.updateQueryLoaderIndicator stopAnimation:nil];
                [NSViewHelpers cancelColorForTarget:self.updateResultsTextField selector:@selector(setTextColor:)];
                [NSViewHelpers setColor:self.updateResultsTextField.textColor fromColor:flashColor toTarget:self.updateResultsTextField withSelector:@selector(setTextColor:) delay:1];
            }];
            [realUpdate release];
        }];
    }
}

- (IBAction)updateQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", self.collection.name, self.collection.name];
    NSString *critical;
    if (self.updateCriteriaTextField.stringValue.length > 0) {
        critical = self.updateCriteriaTextField.stringValue.copy;
    } else {
        critical = @"".copy;
    }
    NSString *sets;
    if (self.updateUpdateTextField.stringValue.length > 0) {
        sets = [[NSString alloc] initWithFormat:@", { $set: %@ }", self.updateUpdateTextField.stringValue];
    } else {
        sets = [[NSString alloc] initWithString:@""];
    }
    NSString *upset;
    if (self.updateUpsetCheckBox.state == 1) {
        upset = [[NSString alloc] initWithString:@", true"];
    } else {
        upset = [[NSString alloc] initWithString:@", false"];
    }
    
    NSString *multi;
    if (self.updateMultiCheckBox.state == 1) {
        multi = [[NSString alloc] initWithString:@", true"];
    } else {
        multi = [[NSString alloc] initWithString:@", false"];
    }
    
    NSString *query = [NSString stringWithFormat:@"db.%@.update(%@%@%@%@)", col, critical, sets, upset, multi];
    [critical release];
    [sets release];
    [upset release];
    [multi release];
    self.updateQueryTextField.stringValue = query;
}

@end

@implementation MHQueryWindowController (RemoveTab)

- (IBAction)removeQuery:(id)sender
{
    id objects;
    
    objects = [MODRagelJsonParser objectsFromJson:self.removeCriteriaTextField.stringValue withError:NULL];
    if (((self.removeCriteriaTextField.stringValue.mh_stringByTrimmingWhitespace.length == 0) || (objects && [objects count] == 0))
        && ((self.view.window.currentEvent.modifierFlags & NSCommandKeyMask) != NSCommandKeyMask)) {
        NSAlert *alert;
        
        alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to remove all documents in %@", self.collection.absoluteName] defaultButton:@"Cancel" alternateButton:@"Remove All" otherButton:nil informativeTextWithFormat:@"This action cannot be undone"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(removeAllDocumentsPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
    } else {
        [self _removeQuery];
    }
}

- (IBAction)removeQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", self.collection.name, self.collection.name];
    NSString *critical;
    if (self.removeCriteriaTextField.stringValue.length > 0) {
        critical = [[NSString alloc] initWithString:self.removeCriteriaTextField.stringValue];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *query = [NSString stringWithFormat:@"db.%@.remove(%@)", col, critical];
    [critical release];
    self.removeQueryTextField.stringValue = query;
}

@end

@implementation MHQueryWindowController (IndexTab)

- (IBAction)indexQueryAction:(id)sender
{
    [self.indexLoaderIndicator startAnimation:nil];
    [self.collection indexListWithCallback:^(NSArray *indexes, MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
        }
        self.indexesOutlineViewController.results = [MODHelper convertForOutlineWithObjects:indexes bsonData:nil];
        [self.indexLoaderIndicator stopAnimation:nil];
    }];
}

- (IBAction)createIndexAction:(id)sender
{
    [self.indexLoaderIndicator startAnimation:nil];
    [self.collection createIndex:self.indexTextField.stringValue name:nil options:0 callback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
        } else {
            self.indexTextField.stringValue = @"";
        }
        [self.indexLoaderIndicator stopAnimation:nil];
        [self indexQueryAction:nil];
    }];
}

- (IBAction)dropIndexAction:(id)sender
{
    NSArray *indexes;
    
    indexes = self.indexesOutlineViewController.selectedDocuments;
    if (indexes.count == 1) {
        [self.indexLoaderIndicator startAnimation:nil];
        [self.collection dropIndexName:[[[indexes objectAtIndex:0] objectForKey:@"objectvalue"] objectForKey:@"name"] callback:^(MODQuery *mongoQuery) {
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            }
            [self.indexLoaderIndicator stopAnimation:nil];
            [self indexQueryAction:nil];
        }];
    }
}

@end

@implementation MHQueryWindowController (mrTab)

- (IBAction)mapReduce:(id)sender
{
    NSString *stringQuery = self.mrCriteriaTextField.stringValue;
    MODSortedMutableDictionary *query = nil;
    NSString *stringOutput = self.mrOutputTextField.stringValue;
    MODSortedMutableDictionary *output = nil;
    NSError *error = nil;
    
    if (stringQuery.length > 0) {
        query = [MODRagelJsonParser objectsFromJson:stringQuery withError:&error];
    }
    if (!error && stringOutput.length > 0) {
        output = [MODRagelJsonParser objectsFromJson:stringOutput withError:&error];
    }
    if (error) {
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", error.localizedDescription);
    } else {
        [self.mrLoaderIndicator startAnimation:nil];
        [self.collection mapReduceWithMapFunction:self.mrMapFunctionTextView.string reduceFunction:self.mrReduceFunctionTextView.string query:query sort:nil limit:-1 output:output keepTemp:NO finalizeFunction:nil scope:nil jsmode:NO verbose:NO readPreferences:nil callback:^(MODQuery *mongoQuery, MODSortedMutableDictionary *documents) {
            [self.mrLoaderIndicator stopAnimation:nil];
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            }
        }];
    }
}

@end

@implementation MHQueryWindowController (MODCollectionDelegate)

- (void)mongoCollection:(MODCollection *)collection queryResultFetched:(NSArray *)result withMongoQuery:(MODQuery *)mongoQuery errorMessage:(NSString *)errorMessage
{
    [self.findQueryLoaderIndicator stopAnimation:nil];
    if (collection == self.collection) {
        if (errorMessage) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", errorMessage);
        } else {
            self.findResultsViewController.results = result;
        }
    }
}

- (void)mongoCollection:(MODCollection *)collection queryCountWithValue:(long long)value withMongoQuery:(MODQuery *)mongoQuery errorMessage:(NSString *)errorMessage
{
    if (collection == self.collection) {
        if ([mongoQuery.userInfo objectForKey:@"title"]) {
            if ([mongoQuery.userInfo objectForKey:@"timequery"]) {
                [[mongoQuery.userInfo objectForKey:@"textfield"] setStringValue:[NSString stringWithFormat:[mongoQuery.userInfo objectForKey:@"title"], value, [[mongoQuery.userInfo objectForKey:@"timequery"] duration]]];
            } else {
                [[mongoQuery.userInfo objectForKey:@"textfield"] setStringValue:[NSString stringWithFormat:[mongoQuery.userInfo objectForKey:@"title"], value]];
            }
        }
    }
}

- (void)mongoCollection:(MODCollection *)collection updateDonwWithMongoQuery:(MODQuery *)mongoQuery errorMessage:(NSString *)errorMessage
{
    if (collection == self.collection) {
        [self.findQueryLoaderIndicator stopAnimation:nil];
        if (errorMessage) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", errorMessage);
        }
    }
}

@end

@implementation MHQueryWindowController(NSComboBox)

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [self.connectionStore queryHistoryWithDatabaseName:@"" collectionName:self.collection.name].count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [[[self.connectionStore queryHistoryWithDatabaseName:@"" collectionName:self.collection.name] objectAtIndex:index] objectForKey:@"title"];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSArray *queries;
    NSUInteger index;
    
    index = self.findCriteriaComboBox.indexOfSelectedItem;
    queries = [self.connectionStore queryHistoryWithDatabaseName:@"" collectionName:self.collection.name];
    if (index < [queries count]) {
        NSDictionary *query;
        
        query = [queries objectAtIndex:self.findCriteriaComboBox.indexOfSelectedItem];
        if ([query objectForKey:@"fields"]) {
            self.findFieldsTextField.stringValue = [query objectForKey:@"fields"];
        } else {
            self.findFieldsTextField.stringValue = @"";
        }
        if ([query objectForKey:@"sort"]) {
            self.findSortTextField.stringValue = [query objectForKey:@"sort"];
        } else {
            self.findSortTextField.stringValue = @"";
        }
        if ([query objectForKey:@"skip"]) {
            self.findSkipTextField.stringValue = [query objectForKey:@"skip"];
        } else {
            self.findSkipTextField.stringValue = @"";
        }
        if ([query objectForKey:@"limit"]) {
            self.findLimitTextField.stringValue = [query objectForKey:@"limit"];
        } else {
            self.findLimitTextField.stringValue = @"";
        }
    }
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    NSUInteger result = NSNotFound;
    NSUInteger index = 0;
    
    for (NSDictionary *history in [self.connectionStore queryHistoryWithDatabaseName:@"" collectionName:self.collection.name]) {
        if ([[history objectForKey:@"title"] isEqualToString:string]) {
            result = index;
            [self comboBoxSelectionDidChange:nil];
            break;
        }
        index++;
    }
    return result;
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string
{
    NSString *result = nil;
    
    for (NSDictionary *history in [self.connectionStore queryHistoryWithDatabaseName:@"" collectionName:self.collection.name]) {
        if ([[history objectForKey:@"title"] hasPrefix:string]) {
            result = [history objectForKey:@"title"];
            break;
        }
    }
    return result;
}

@end

@implementation MHQueryWindowController (UKSyntaxColoredTextViewDelegate)

@end
