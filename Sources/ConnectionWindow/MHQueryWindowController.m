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

@property (nonatomic, readwrite, weak) IBOutlet NSView *updateTabView;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *updateButton;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *updateCriteriaTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *updateUpsetCheckBox;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *updateMultiCheckBox;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *updateResultsTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *updateQueryTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *updateQueryLoaderIndicator;
@property (nonatomic, readwrite, strong) NSMutableArray *updateOperatorViews;
@property (nonatomic, readwrite, strong) NSArray *updateOperatorList;

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

@interface MHQueryWindowController (UpdateTab)
- (IBAction)updateAddOperatorAction:(id)sender;
- (IBAction)updateQueryComposer:(id)sender;

@end

@implementation MHQueryWindowController
@synthesize collection = _collection, connectionStore = _connectionStore;
@synthesize tabView = _tabView, segmentedControl = _segmentedControl;

@synthesize findResultsViewController = _findResultsViewController, findResultsOutlineView = _findResultsOutlineView, findRemoveButton = _findRemoveButton, findCriteriaComboBox = _findCriteriaComboBox, findFieldsTextField = _findFieldsTextField, findSkipTextField = _findSkipTextField, findLimitTextField = _findLimitTextField, findSortTextField = _findSortTextField, findTotalResultsTextField = _findTotalResultsTextField, findQueryTextField = _findQueryTextField, findQueryLoaderIndicator = _findQueryLoaderIndicator;

@synthesize insertDataTextView = _insertDataTextView, insertResultsTextField = _insertResultsTextField, insertLoaderIndicator = _insertLoaderIndicator, insertButton = _insertButton;
@synthesize syntaxColoringController = _syntaxColoringController;

@synthesize updateTabView = _updateTabView;
@synthesize updateButton = _updateButton;
@synthesize updateCriteriaTextField = _updateCriteriaTextField;
@synthesize updateUpsetCheckBox = _updateUpsetCheckBox;
@synthesize updateMultiCheckBox = _updateMultiCheckBox;
@synthesize updateResultsTextField = _updateResultsTextField;
@synthesize updateQueryTextField = _updateQueryTextField;
@synthesize updateQueryLoaderIndicator = _updateQueryLoaderIndicator;
@synthesize updateOperatorViews = _updateOperatorViews;
@synthesize updateOperatorList = _updateOperatorList;

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
        self.updateOperatorList = @[
                                    @{ @"title": @"Current Date",   @"key": @"$currentDate" },
                                    @{ @"title": @"Increment",      @"key": @"$inc" },
                                    @{ @"title": @"Max",            @"key": @"$max" },
                                    @{ @"title": @"Min",            @"key": @"$min" },
                                    @{ @"title": @"Multiply",       @"key": @"$mul" },
                                    @{ @"title": @"Rename",         @"key": @"$rename" },
                                    @{ @"title": @"Set On Insert",  @"key": @"$setOnInsert" },
                                    @{ @"title": @"Set",            @"key": @"$set" },
                                    @{ @"title": @"Unset",          @"key": @"$unset" },
                                    @{},
                                    @{ @"title": @"Add To Set",     @"key": @"$addToSet" },
                                    @{ @"title": @"Pop",            @"key": @"$pop" },
                                    @{ @"title": @"Pull All",       @"key": @"$pullAll" },
                                    @{ @"title": @"Pull",           @"key": @"$pull" },
                                    @{ @"title": @"Push All",       @"key": @"$pushAll" },
                                    @{ @"title": @"Push",           @"key": @"$push" },
                                    @{},
                                    @{ @"title": @"Bit",            @"key": @"$bit" },
                                    ];
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
    self.updateOperatorViews = nil;
    self.updateOperatorList = nil;
    
    [_jsonWindowControllers release];
    
    [super dealloc];
}

- (void)droppedNotification:(NSNotification *)notification
{
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

- (void)awakeFromNib
{
    self.updateOperatorViews = [NSMutableArray array];
    [self updateAddOperatorAction:nil];
    
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

- (NSString *)formatedJsonWithTextField:(NSTextField *)textField replace:(BOOL)replace emptyValid:(BOOL)emptyValid
{
    NSString *query = @"";
    NSString *value;
    NSString *valueWithoutDoubleQuotes = nil;
    
    value = [textField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
        } else if ([value rangeOfString:@":"].location != NSNotFound) {
            query = [NSString stringWithFormat:@"{ %@ }", value];
        } else if ([value hasPrefix:@"\""]) {
            query = [NSString stringWithFormat:@"{\"_id\": %@}", value];
        } else {
            query = [NSString stringWithFormat:@"{\"_id\": \"%@\"}", value];
        }
    }
    if (replace) {
        textField.stringValue = query;
        [textField selectText:nil];
    }
    if (!emptyValid && [query isEqualToString:@""]) {
        query = @"{}";
    }
    return query;
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

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = notification.object;
    
    if (textField == self.findCriteriaComboBox || textField == self.findFieldsTextField || textField == self.findSortTextField || textField == self.findSkipTextField || textField == self.findLimitTextField) {
        [self findQueryComposer:nil];
    } else if (textField == self.updateCriteriaTextField || textField.superview.superview == self.updateTabView) {
        [self updateQueryComposer:nil];
    } else if (textField == self.removeCriteriaTextField) {
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

- (NSString *)formatedQuerySort
{
    NSString *result;
    
    result = self.findSortTextField.stringValue.mh_stringByTrimmingWhitespace;
    if ([result length] == 0) {
        result = @"{ \"_id\": 1}";
    }
    return result;
}

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
    jsonCriteria = [self formatedJsonWithTextField:self.findCriteriaComboBox replace:YES emptyValid:NO];
    fields = [[NSMutableArray alloc] init];
    for (NSString *field in [self.findFieldsTextField.stringValue componentsSeparatedByString:@","]) {
        field = field.mh_stringByTrimmingWhitespace;
        if ([field length] > 0) {
            [fields addObject:field];
        }
    }
    [self.findQueryLoaderIndicator startAnimation:nil];

    criteria = [MODRagelJsonParser objectsFromJson:jsonCriteria withError:&error];
    if (!error) {
        sort = [MODRagelJsonParser objectsFromJson:jsonSort withError:&error];
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
            [NSViewHelpers setColor:currentColor
                          fromColor:flashColor
                           toTarget:self.findTotalResultsTextField
                       withSelector:@selector(setTextColor:)
                              delay:1];
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
    NSString *criteria = [self formatedJsonWithTextField:self.findCriteriaComboBox replace:NO emptyValid:YES];
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

- (void)_updatePrint
{
    NSUInteger ii = 0;
    
    for (NSDictionary *views in self.updateOperatorViews) {
        NSLog(@"%lu %@ %@", (unsigned long)ii, [views[@"popup"] titleOfSelectedItem], views[@"main"]);
        ii++;
    }
}

- (NSString *)_updateStringOperatorWithPopUpButton:(NSPopUpButton *)button
{
    NSUInteger index = button.indexOfSelectedItem;
    NSDictionary *item;
    
    NSAssert(index < self.updateOperatorList.count, @"index too high %lu %lu", (unsigned long)index, (unsigned long)self.updateOperatorList.count);
    item = self.updateOperatorList[index];
    NSAssert(item.count == 2, @"it should be a regular item %@", item);
    return item[@"key"];
}

- (void)_updatePopUpButtonSetup:(NSPopUpButton *)button
{
    NSMenu *menu = button.menu;
    NSUInteger index = 0, ii;
    
    [menu removeAllItems];
    ii = 0;
    for (NSDictionary *item in self.updateOperatorList) {
        if (item.count == 0) {
            [menu addItem:[NSMenuItem separatorItem]];
        } else {
            [menu addItemWithTitle:item[@"title"] action:nil keyEquivalent:@""];
            if ([item[@"key"] isEqualToString:@"$set"]) {
                index = ii;
            }
        }
        ii++;
    }
    if (self.updateOperatorViews.count == 0) {
        // the first NSPopUpButton should be set to "Set"
        // it is probably the most common operator used
        [button selectItemAtIndex:index];
    }
}

- (NSUInteger)_updateIndexOfOperatorWithView:(NSView *)view
{
    NSUInteger index = NSNotFound, ii;
    
    ii = 0;
    for (NSDictionary *views in self.updateOperatorViews) {
        if ([views.allValues containsObject:view]) {
            index = ii;
            break;
        }
        ii++;
    }
    return index;
}

- (void)_updateCreateLayoutConstraintsWithOperatorMainView:(NSView *)mainView previousView:(NSView *)previousView
{
    for (NSLayoutConstraint *constraint in self.updateTabView.constraints) {
        if (constraint.firstItem == mainView) {
            [self.updateTabView removeConstraint:constraint];
        }
    }
    [self.updateTabView addConstraint:[NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0]];
    [self.updateTabView addConstraint:[NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.updateTabView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.updateTabView addConstraint:[NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.updateTabView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
}

- (IBAction)updateAddOperatorAction:(id)sender
{
    NSArray *topLevelObjects = nil;
    NSMutableDictionary *line = [NSMutableDictionary dictionary];
    NSView *mainView = nil;
    NSView *previousView;
    NSUInteger previousViewIndex;
    
    [NSBundle.mainBundle loadNibNamed:@"MHQueryUpdateOperator" owner:nil topLevelObjects:&topLevelObjects];
    NSAssert(topLevelObjects, @"Should have top level objects");
    NSAssert(topLevelObjects.count == 2, @"Should have only one top level object");
    for (id topLevelObject in topLevelObjects) {
        if ([topLevelObject isKindOfClass:NSView.class]) {
            NSAssert(mainView == nil, @"should have only one NSView as top level object");
            mainView = topLevelObject;
        }
    }
    NSAssert(mainView != nil, @"Should have found one top level object");
    line[@"main"] = mainView;
    line[@"popup"] = [mainView viewWithTag:1];
    line[@"textfield"] = [mainView viewWithTag:2];
    line[@"+"] = [mainView viewWithTag:3];
    line[@"-"] = [mainView viewWithTag:4];
    [line[@"textfield"] setDelegate:self];
    [line[@"+"] setTarget:self];
    [line[@"+"] setAction:@selector(updateAddOperatorAction:)];
    [line[@"-"] setTarget:self];
    [line[@"-"] setAction:@selector(updateRemoveOperatorAction:)];
    [line[@"-"] setTarget:self];
    [line[@"popup"] setAction:@selector(updateOperatorPopButtonAction:)];
    [self _updatePopUpButtonSetup:line[@"popup"]];
    [line[@"popup"] menu].autoenablesItems = NO;
    for (NSMenuItem *item in [line[@"popup"] menu].itemArray) {
        item.target = self;
        item.action = @selector(updateOperatorPopButtonAction:);
    }
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.updateTabView addSubview:mainView];
    
    if (sender) {
        previousView = [sender superview];
        previousViewIndex = [self _updateIndexOfOperatorWithView:previousView];
    } else {
        previousView = self.updateCriteriaTextField;
        previousViewIndex = NSNotFound;
    }
    [self _updateCreateLayoutConstraintsWithOperatorMainView:mainView previousView:previousView];
    
    if (sender) {
        [self.updateOperatorViews insertObject:line atIndex:previousViewIndex + 1];
        if (self.updateOperatorViews.count > previousViewIndex + 2) {
            [self _updateCreateLayoutConstraintsWithOperatorMainView:[[self.updateOperatorViews objectAtIndex:previousViewIndex + 2] objectForKey:@"main"] previousView:mainView];
        }
    } else {
        [self.updateOperatorViews addObject:line];
    }
    
    [self updateOperatorPopButtonAction:nil];
}

- (IBAction)updateRemoveOperatorAction:(id)sender
{
    NSView *mainView = [sender superview];
    NSUInteger index = [self _updateIndexOfOperatorWithView:mainView];
    
    [mainView removeFromSuperview];
    [self.updateOperatorViews removeObjectAtIndex:index];
    if (index == 0) {
        [self _updateCreateLayoutConstraintsWithOperatorMainView:[[self.updateOperatorViews objectAtIndex:index] objectForKey:@"main"] previousView:self.updateCriteriaTextField];
    } else if (self.updateOperatorViews.count > index) {
        [self _updateCreateLayoutConstraintsWithOperatorMainView:[[self.updateOperatorViews objectAtIndex:index] objectForKey:@"main"] previousView:[[self.updateOperatorViews objectAtIndex:index - 1] objectForKey:@"main"]];
    }

    [self updateOperatorPopButtonAction:nil];
}

- (IBAction)updateOperatorPopButtonAction:(id)sender
{
    NSMutableIndexSet *usedIndexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *unusedIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.updateOperatorList.count)];
    NSMutableArray *shouldBeUpdated = [NSMutableArray array];
    
    [self.updateOperatorList enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger index, BOOL *stop) {
        if (item.count == 0) {
            [usedIndexes addIndex:index];
            [unusedIndexes removeIndex:index];
        }
    }];
    for (NSDictionary *lineViews in self.updateOperatorViews) {
        NSPopUpButton *popupButton = lineViews[@"popup"];
        NSUInteger selectedItem = [popupButton indexOfSelectedItem];
        
        if ([usedIndexes containsIndex:selectedItem]) {
            [shouldBeUpdated addObject:popupButton];
        } else {
            [usedIndexes addIndex:selectedItem];
            [unusedIndexes removeIndex:selectedItem];
        }
    }
    for (NSPopUpButton *button in shouldBeUpdated) {
        NSUInteger index = [unusedIndexes firstIndex];
        
        [button.menu itemAtIndex:index].enabled = YES;
        [button selectItemAtIndex:index];
        [unusedIndexes removeIndex:index];
        [usedIndexes addIndex:index];
    }
    for (NSDictionary *lineViews in self.updateOperatorViews) {
        NSUInteger ii, selectedItemIndex;
        NSMenu *menu;
        
        [lineViews[@"+"] setEnabled:(usedIndexes.count != self.updateOperatorList.count)];
        [lineViews[@"-"] setEnabled:(usedIndexes.count != 1)];
        menu = lineViews[@"popup"];
        selectedItemIndex = [lineViews[@"popup"] indexOfSelectedItem];
        for (ii = 0; ii < self.updateOperatorList.count; ii++) {
            if (ii != selectedItemIndex) {
                [menu itemAtIndex:ii].enabled = [unusedIndexes containsIndex:ii];
            }
        }
    }
    [self updateQueryComposer:nil];
}

- (IBAction)updateQuery:(id)sender
{
    MODSortedMutableDictionary *query = nil;
    MODSortedMutableDictionary *update = [MODSortedMutableDictionary sortedDictionary];
    NSError *error = nil;
    
    [self.updateQueryLoaderIndicator startAnimation:nil];
    query = [MODRagelJsonParser objectsFromJson:[self formatedJsonWithTextField:self.updateCriteriaTextField replace:NO emptyValid:NO] withError:&error];
    if (error) {
        NSBeginAlertSheet(@"Error In Query", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", error.localizedDescription);
        [NSViewHelpers cancelColorForTarget:self.updateResultsTextField selector:@selector(setTextColor:)];
        [NSViewHelpers setColor:self.updateResultsTextField.textColor
                      fromColor:NSColor.redColor
                       toTarget:self.updateResultsTextField
                   withSelector:@selector(setTextColor:)
                          delay:1];
        [self.updateCriteriaTextField becomeFirstResponder];
        self.findTotalResultsTextField.stringValue = @"";
        return;
    }
    for (NSDictionary *views in self.updateOperatorViews) {
        NSTextField *textField = views[@"textfield"];
        NSPopUpButton *popUpButton = views[@"popup"];
        MODSortedMutableDictionary *value;
        NSString *key;
        
        value = [MODRagelJsonParser objectsFromJson:[self formatedJsonWithTextField:textField replace:NO emptyValid:NO] withError:&error];
        if (error) {
            NSBeginAlertSheet([NSString stringWithFormat:@"Error In %@", key], @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", error.localizedDescription);
            [NSViewHelpers cancelColorForTarget:self.updateResultsTextField selector:@selector(setTextColor:)];
            [NSViewHelpers setColor:self.updateResultsTextField.textColor
                          fromColor:NSColor.redColor
                           toTarget:self.updateResultsTextField
                       withSelector:@selector(setTextColor:)
                              delay:1];
            [textField becomeFirstResponder];
            self.findTotalResultsTextField.stringValue = @"";
            return;
        }
        key = [self _updateStringOperatorWithPopUpButton:popUpButton];
        [update setObject:value forKey:key];
    }
    [self.collection countWithCriteria:query readPreferences:nil callback:^(int64_t count, MODQuery *mongoQuery) {
        if (self.updateMultiCheckBox.state == 0 && count > 0) {
            count = 1;
        }
        
        [self.collection updateWithCriteria:query
                                     update:update
                                     upsert:self.updateUpsetCheckBox.state
                                multiUpdate:self.updateMultiCheckBox.state
                                   callback:^(MODQuery *mongoQuery) {
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
            [NSViewHelpers setColor:self.updateResultsTextField.textColor
                          fromColor:flashColor
                           toTarget:self.updateResultsTextField
                       withSelector:@selector(setTextColor:)
                              delay:1];
        }];
    }];
}

- (IBAction)updateQueryComposer:(id)sender
{
    NSUInteger ii;
    NSString *col = [NSString stringWithFormat:@"%@.%@", self.collection.name, self.collection.name];
    NSString *critical;
    NSMutableString *sets;
    NSMutableString *options = [NSMutableString string];
    
    critical = [self formatedJsonWithTextField:self.updateCriteriaTextField replace:NO emptyValid:NO];
    sets = [NSMutableString stringWithString:@", {"];
    ii = 0;
    for (NSDictionary *views in self.updateOperatorViews) {
        if (ii > 0) {
            [sets appendString:@", "];
        }
        [sets appendString:[self _updateStringOperatorWithPopUpButton:views[@"popup"]]];
        [sets appendString:@": "];
        [sets appendString:[self formatedJsonWithTextField:views[@"textfield"] replace:NO emptyValid:NO]];
        ii++;
    }
    [sets appendString:@"}"];

    if (self.updateUpsetCheckBox.state == 1) {
        [options appendString:@", { upset: true"];
    }
    
    if (self.updateMultiCheckBox.state == 1) {
        if (options.length == 0) {
            [options appendString:@", { "];
        } else {
            [options appendString:@", "];
        }
        [options appendString:@"multi: true "];
    }
    if (options.length != 0) {
        [options appendString:@"}"];
    }
    
    self.updateQueryTextField.stringValue = [NSString stringWithFormat:@"db.%@.update(%@%@%@)", col, critical, sets, options];
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
