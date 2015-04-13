//
//  MHQueryViewController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHQueryViewController.h"

#import "MHDocumentOutlineViewController.h"
#import "NSString+MongoHub.h"
#import "MHJsonWindowController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "MODHelper.h"
#import "MHConnectionStore.h"
#import "NSViewHelpers.h"
#import "NSTextView+MongoHub.h"
#import "UKSyntaxColoredTextViewController.h"
#import "MHTabViewController.h"
#import "MHIndexEditorController.h"
#import "MHApplicationDelegate.h"

#define IS_OBJECT_ID(value) ([value length] == 24 && [[value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefABCDEF"]] length] == 0)

@interface MHQueryViewController () <NSTextFieldDelegate>
@property (nonatomic, readwrite, strong) NSMutableDictionary *jsonWindowControllers;

@property (nonatomic, readwrite, weak) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic, readwrite, weak) IBOutlet NSTabView *tabView;

@property (nonatomic, readwrite, strong) MODCollection *collection;
@property (nonatomic, readwrite, strong) MHConnectionStore *connectionStore;

@property (nonatomic, readwrite, weak) IBOutlet NSComboBox *findCriteriaComboBox;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *findFieldFilterTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *findSkipTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *findLimitTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *findSortTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *findQueryTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *findQueryLoaderIndicator;
@property (nonatomic, readwrite, strong) IBOutlet MHDocumentOutlineViewController *findDocumentOutlineViewController;
@property (nonatomic, readwrite, weak) IBOutlet NSView *findResultView;

@property (nonatomic, readwrite, weak) IBOutlet NSButton *insertButton;
@property (nonatomic, readwrite, weak) IBOutlet NSTextView *insertDataTextView;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *insertResultsTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *insertLoaderIndicator;
@property (nonatomic, readwrite, strong) UKSyntaxColoredTextViewController *insertSyntaxColoringController;

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

@property (nonatomic, readwrite, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *removeCriteriaTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *removeResultsTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *removeQueryTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *removeQueryLoaderIndicator;

@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *indexLoaderIndicator;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *indexDropButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *indexCreateButton;
@property (nonatomic, readwrite, weak) IBOutlet NSView *indexResultView;
@property (nonatomic, readwrite, strong) IBOutlet MHDocumentOutlineViewController *indexDocumentOutlineViewController;
@property (nonatomic, readwrite, strong) MHIndexEditorController * indexEditorController;

@property (nonatomic, readwrite, weak) IBOutlet NSTextView *aggregationPipeline;
@property (nonatomic, readwrite, weak) IBOutlet NSTextView *aggregationOptions;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *aggregationLoaderIndicator;
@property (nonatomic, readwrite, weak) IBOutlet NSView *aggregationResultView;
@property (nonatomic, readwrite, strong) IBOutlet MHDocumentOutlineViewController *aggregationDocumentOutlineViewController;
@property (nonatomic, readwrite, strong) UKSyntaxColoredTextViewController *aggregationPipelineSyntaxColoringController;
@property (nonatomic, readwrite, strong) UKSyntaxColoredTextViewController *aggregationOptionsSyntaxColoringController;

@property (nonatomic, readwrite, weak) IBOutlet NSView *mrResultView;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *mrLoaderIndicator;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *mrOutputTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *mrCriteriaTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextView *mrMapFunctionTextView;
@property (nonatomic, readwrite, weak) IBOutlet NSTextView *mrReduceFunctionTextView;
@property (nonatomic, readwrite, strong) IBOutlet MHDocumentOutlineViewController *mrDocumentOutlineViewController;

- (void)selectBestTextField;

@end

@interface MHQueryViewController (FindTab)
- (IBAction)findQuery:(id)sender;
- (void)findQueryComposer;
- (void)defaultSortOrderChangedNotification:(NSNotification *)notification;

@end

@interface MHQueryViewController (UpdateTab)
- (IBAction)updateAddOperatorAction:(id)sender;
- (IBAction)updateQueryComposer:(id)sender;

@end

@interface MHQueryViewController (IndexTab) <MHIndexEditorControllerDelegate>
- (IBAction)indexQueryAction:(id)sender;
- (IBAction)createIndexAction:(id)sender;
- (IBAction)dropIndexAction:(id)sender;

@end

static NSString *defaultSortOrder(MHDefaultSortOrder defaultSortOrder)
{
    NSString *result;
    
    if (MHPreferenceWindowController.defaultSortOrder == MHDefaultSortOrderAscending) {
        result = @"{ \"_id\": 1}";
    } else {
        result = @"{ \"_id\": -1}";
    }
    return result;
}

@implementation MHQueryViewController

@synthesize tabView = _tabView, segmentedControl = _segmentedControl;

@synthesize findCriteriaComboBox = _findCriteriaComboBox;
@synthesize findFieldFilterTextField = _findFieldFilterTextField;
@synthesize findSkipTextField = _findSkipTextField;
@synthesize findLimitTextField = _findLimitTextField;
@synthesize findSortTextField = _findSortTextField;
@synthesize findQueryTextField = _findQueryTextField;
@synthesize findQueryLoaderIndicator = _findQueryLoaderIndicator;
@synthesize findResultView = _findResultView;

@synthesize insertDataTextView = _insertDataTextView;
@synthesize insertResultsTextField = _insertResultsTextField;
@synthesize insertLoaderIndicator = _insertLoaderIndicator;
@synthesize insertButton = _insertButton;

@synthesize updateTabView = _updateTabView;
@synthesize updateButton = _updateButton;
@synthesize updateCriteriaTextField = _updateCriteriaTextField;
@synthesize updateUpsetCheckBox = _updateUpsetCheckBox;
@synthesize updateMultiCheckBox = _updateMultiCheckBox;
@synthesize updateResultsTextField = _updateResultsTextField;
@synthesize updateQueryTextField = _updateQueryTextField;
@synthesize updateQueryLoaderIndicator = _updateQueryLoaderIndicator;

@synthesize removeButton = _removeButton;
@synthesize removeCriteriaTextField = _removeCriteriaTextField;
@synthesize removeResultsTextField = _removeResultsTextField;
@synthesize removeQueryTextField = _removeQueryTextField;
@synthesize removeQueryLoaderIndicator = _removeQueryLoaderIndicator;

@synthesize indexLoaderIndicator = _indexLoaderIndicator;
@synthesize indexDropButton = _indexDropButton;
@synthesize indexCreateButton = _indexCreateButton;
@synthesize indexResultView = _indexResultView;

@synthesize aggregationPipeline = _aggregationPipeline;
@synthesize aggregationOptions = _aggregationOptions;
@synthesize aggregationLoaderIndicator = _aggregationLoaderIndicator;
@synthesize aggregationResultView = _aggregationResultView;

@synthesize mrResultView = _mrResultView;
@synthesize mrLoaderIndicator = _mrLoaderIndicator;
@synthesize mrOutputTextField = _mrOutputTextField;
@synthesize mrCriteriaTextField = _mrCriteriaTextField;
@synthesize mrMapFunctionTextView = _mrMapFunctionTextView;
@synthesize mrReduceFunctionTextView = _mrReduceFunctionTextView;

- (instancetype)initWithCollection:(MODCollection *)collection connectionStore:(MHConnectionStore *)connectionStore
{
    self = [self init];
    if (self) {
        self.collection = collection;
        self.connectionStore = connectionStore;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedNotification:) name:MODCollection_Dropped_Notification object:self.collection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedNotification:) name:MODDatabase_Dropped_Notification object:self.collection.database];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultSortOrderChangedNotification:) name:MHDefaultSortOrderPreferenceChangedNotification object:nil];
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
    
    self.insertSyntaxColoringController = nil;
    self.findDocumentOutlineViewController = nil;
    self.indexDocumentOutlineViewController = nil;
    self.indexEditorController = nil;
    
    self.mrDocumentOutlineViewController = nil;
    self.collection = nil;
    self.connectionStore = nil;
    self.updateOperatorViews = nil;
    self.updateOperatorList = nil;
    
    self.aggregationDocumentOutlineViewController = nil;
    self.aggregationPipelineSyntaxColoringController = nil;
    self.aggregationOptionsSyntaxColoringController = nil;
    
    self.jsonWindowControllers = nil;
    
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
    return @"MHQueryView";
}

- (void)awakeFromNib
{
    MHApplicationDelegate *appDelegate = (MHApplicationDelegate *)NSApplication.sharedApplication.delegate;
    
    self.updateOperatorViews = [NSMutableArray array];
    [self updateAddOperatorAction:nil];
    
    [MHDocumentOutlineViewController addDocumentOutlineViewController:self.findDocumentOutlineViewController intoView:self.findResultView];
    
    self.insertSyntaxColoringController = MOD_AUTORELEASE([[UKSyntaxColoredTextViewController alloc] init]);
    self.insertSyntaxColoringController.delegate = self;
    self.insertSyntaxColoringController.view = self.insertDataTextView;
    
    [MHDocumentOutlineViewController addDocumentOutlineViewController:self.indexDocumentOutlineViewController intoView:self.indexResultView];
    
    [MHDocumentOutlineViewController addDocumentOutlineViewController:self.mrDocumentOutlineViewController intoView:self.mrResultView];
    
    self.title = self.collection.absoluteName;
    self.jsonWindowControllers = [NSMutableDictionary dictionary];
    [self defaultSortOrderChangedNotification:nil]; // this will call findQueryComposer
    [self updateQueryComposer:nil];
    [self removeQueryComposer:nil];
    
    self.aggregationPipelineSyntaxColoringController = MOD_AUTORELEASE([[UKSyntaxColoredTextViewController alloc] init]);
    self.aggregationPipelineSyntaxColoringController.delegate = self;
    self.aggregationPipelineSyntaxColoringController.view = self.aggregationPipeline;
    self.aggregationOptionsSyntaxColoringController = MOD_AUTORELEASE([[UKSyntaxColoredTextViewController alloc] init]);
    self.aggregationOptionsSyntaxColoringController.delegate = self;
    self.aggregationOptionsSyntaxColoringController.view = self.aggregationOptions;
    [MHDocumentOutlineViewController addDocumentOutlineViewController:self.aggregationDocumentOutlineViewController intoView:self.aggregationResultView];
    
    [self.insertDataTextView mh_jsonSetup];
    [self.mrReduceFunctionTextView mh_jsonSetup];
    [self.mrMapFunctionTextView mh_jsonSetup];
    
    if (!appDelegate.hasCollectionMapReduceTab) {
        // remove map/reduce
        self.segmentedControl.segmentCount = 6;
        [self.tabView removeTabViewItem:[self.tabView tabViewItemAtIndex:6]];
    }
    if (!appDelegate.hasCollectionAggregationTab) {
        // remove aggregation
        [self.segmentedControl setImage:[self.segmentedControl imageForSegment:6] forSegment:5];
        [self.segmentedControl setImageScaling:[self.segmentedControl imageScalingForSegment:6] forSegment:5];
        [self.segmentedControl setLabel:[self.segmentedControl labelForSegment:6] forSegment:5];
        [self.segmentedControl setMenu:[self.segmentedControl menuForSegment:6] forSegment:5];
        [self.segmentedControl setSelected:[self.segmentedControl isSelectedForSegment:6] forSegment:5];
        [self.segmentedControl setEnabled:[self.segmentedControl isEnabledForSegment:6] forSegment:5];
        [self.segmentedControl setWidth:[self.segmentedControl widthForSegment:6] forSegment:5];
        self.segmentedControl.segmentCount = 6;
        [self.tabView removeTabViewItem:[self.tabView tabViewItemAtIndex:5]];
    }
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

- (void)_removeQueryWithCriteria:(MODSortedDictionary *)criteria
{
    [self.removeQueryLoaderIndicator startAnimation:nil];
    [self.collection countWithCriteria:criteria readPreferences:nil callback:^(int64_t count, MODQuery *mongoQuery) {
        [self.collection removeWithCriteria:criteria callback:^(MODQuery *removeQuery) {
            NSColor *flashColor;
            
            if (removeQuery.error) {
                self.removeResultsTextField.stringValue = @"Error!";
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", removeQuery.error.localizedDescription);
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

- (void)removeAllDocumentsPanelDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(MODSortedDictionary *)criteria
{
    switch (returnCode) {
        case NSAlertAlternateReturn:
            [self _removeQueryWithCriteria:criteria];
            break;
            
        default:
            break;
    }
    [criteria release];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = notification.object;
    
    if (textField == self.findCriteriaComboBox || textField == self.findFieldFilterTextField || textField == self.findSortTextField || textField == self.findSkipTextField || textField == self.findLimitTextField) {
        [self findQueryComposer];
    } else if (textField == self.updateCriteriaTextField || textField.superview.superview == self.updateTabView) {
        [self updateQueryComposer:nil];
    } else if (textField == self.removeCriteriaTextField) {
        [self removeQueryComposer:nil];
    }

}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
    NSTextField *textField = notification.object;
    
    if ((textField == self.findCriteriaComboBox || textField == self.findFieldFilterTextField || textField == self.findSortTextField || textField == self.findSkipTextField || textField == self.findLimitTextField) && [notification.userInfo[@"NSTextMovement"] intValue] == NSReturnTextMovement ) {
        [self findQuery:nil];
    }
}

- (void)jsonWindowWillClose:(NSNotification *)notification
{
    MHJsonWindowController *jsonWindowController = notification.object;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJsonWindowSaved object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJsonWindowWillClose object:notification.object];
    [self.jsonWindowControllers removeObjectForKey:jsonWindowController.windowControllerId];
}

- (IBAction)segmentedControlAction:(id)sender
{
    [self.tabView selectTabViewItemAtIndex:self.segmentedControl.selectedSegment];
    [self selectBestTextField];
}

- (void)selectBestTextField
{
    [self.findQueryTextField.window makeFirstResponder:self.tabView.selectedTabViewItem.initialFirstResponder ];
}

// REMOVE when 10.9 is not supported anymore
- (BOOL)canPerformCopy
{
    if ([[self.tabView selectedTabViewItem].identifier isEqualToString:@"find"]) {
        return self.findDocumentOutlineViewController.canCopyDocuments;
    } else if ([[self.tabView selectedTabViewItem].identifier isEqualToString:@"aggregation"]) {
        return self.aggregationDocumentOutlineViewController.canCopyDocuments;
    } else if ([[self.tabView selectedTabViewItem].identifier isEqualToString:@"mapreduce"]) {
        return self.mrDocumentOutlineViewController.canCopyDocuments;
    }
    return NO;
}

// REMOVE when 10.9 is not supported anymore
- (void)performCopy
{
    if ([[self.tabView selectedTabViewItem].identifier isEqualToString:@"find"] && self.findDocumentOutlineViewController.canCopyDocuments) {
        [self.findDocumentOutlineViewController copyDocuments];
    } else if ([[self.tabView selectedTabViewItem].identifier isEqualToString:@"aggregation"] && self.aggregationDocumentOutlineViewController.canCopyDocuments) {
        [self.aggregationDocumentOutlineViewController copyDocuments];
    } else if ([[self.tabView selectedTabViewItem].identifier isEqualToString:@"mapreduce"] && self.mrDocumentOutlineViewController.canCopyDocuments) {
        [self.mrDocumentOutlineViewController copyDocuments];
    }
}

@end

@implementation MHQueryViewController (FindTab)

- (NSString *)formatedQuerySort
{
    NSString *result;
    
    result = [self formatedJsonWithTextField:self.findSortTextField replace:NO emptyValid:YES];
    if ([result length] == 0) {
        result = defaultSortOrder(MHPreferenceWindowController.defaultSortOrder);
    }
    return result;
}

- (IBAction)findQuery:(id)sender
{
    int limit = self.findLimitTextField.intValue;
    NSString *criteriaJson;
    NSString *fieldFilterJson;
    NSString *sortJson = self.formatedQuerySort;
    NSString *queryTitle = self.findCriteriaComboBox.stringValue;
    MODSortedDictionary *criteria = nil;
    MODSortedDictionary *fieldFilter = nil;
    MODSortedDictionary *sort = nil;
    id fieldWithError = nil;
    NSError *error = nil;
    
    [self findQueryComposer];
    if (limit <= 0) {
        limit = 30;
    }
    criteriaJson = [self formatedJsonWithTextField:self.findCriteriaComboBox replace:YES emptyValid:NO];
    fieldFilterJson = [self formatedJsonWithTextField:self.findFieldFilterTextField replace:YES emptyValid:NO];
    [self.findQueryLoaderIndicator startAnimation:nil];

    criteria = [MODRagelJsonParser objectsFromJson:criteriaJson withError:&error];
    fieldWithError = self.findCriteriaComboBox;
    if (!error) {
        sort = [MODRagelJsonParser objectsFromJson:sortJson withError:&error];
        fieldWithError = self.findSortTextField;
    }
    if (!error) {
        fieldFilter = [MODRagelJsonParser objectsFromJson:fieldFilterJson withError:&error];
        fieldWithError = self.findFieldFilterTextField;
    }
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        
        [self.findDocumentOutlineViewController displayErrorLabel:errorMessage];
        self.findQueryTextField.stringValue = errorMessage;
        [self.findQueryLoaderIndicator stopAnimation:nil];
        [fieldWithError becomeFirstResponder];
    } else {
        [self.collection findWithCriteria:criteria
                                   fields:fieldFilter
                                     skip:self.findSkipTextField.intValue
                                    limit:limit
                                     sort:sort
                                 callback:^(NSArray *documents, NSArray *bsonData, MODQuery *mongoQuery) {
            if (mongoQuery.error) {
                NSString *errorMessage = [NSString stringWithFormat:@"Error: %@", [mongoQuery.error localizedDescription]];
                [self.findDocumentOutlineViewController displayErrorLabel:errorMessage];
                self.findQueryTextField.stringValue = errorMessage;
            } else {
                NSArray *convertedDocuments = nil;
                
                if ([queryTitle length] > 0) {
                    [self.connectionStore addNewQuery:@{
                                                        @"title": queryTitle,
                                                        @"sort": self.findSortTextField.stringValue,
                                                        @"fields": self.findFieldFilterTextField.stringValue,
                                                        @"limit": self.findLimitTextField.stringValue,
                                                        @"skip": self.findSkipTextField.stringValue
                                                        }
                                     withDatabaseName:@""
                                       collectionName:self.collection.name];
                }
                convertedDocuments = [MODHelper convertForOutlineWithObjects:documents bsonData:bsonData jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
                [self.findDocumentOutlineViewController displayDocuments:convertedDocuments withLabel:nil];
                [self.findDocumentOutlineViewController setBackButtonEnabled:self.findSkipTextField.stringValue.integerValue != 0];
                [self.collection countWithCriteria:criteria readPreferences:nil callback:^(int64_t count, MODQuery *countQuery) {
                    [self.findDocumentOutlineViewController displayLabel:[NSString stringWithFormat:@"Total Results: %lld (%0.2fs)", count, [[countQuery.userInfo objectForKey:@"timequery"] duration]]];
                }];
            }
            [self.findQueryLoaderIndicator stopAnimation:nil];
        }];
    }
}

- (void)findQueryComposer
{
    NSString *criteria = [self formatedJsonWithTextField:self.findCriteriaComboBox replace:NO emptyValid:YES];
    NSString *fieldFilterJson = [self formatedJsonWithTextField:self.findFieldFilterTextField replace:NO emptyValid:YES];
    NSString *sortValue = [self formatedQuerySort];
    NSString *sort;
    
    if (fieldFilterJson.length > 0) {
        fieldFilterJson = [NSString stringWithFormat:@", %@", fieldFilterJson];
    }
    
    if ([sortValue length] > 0) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)", sortValue];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", self.findSkipTextField.intValue];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", self.findLimitTextField.intValue];
    NSString *col = [NSString stringWithFormat:@"%@", self.collection.name];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, criteria, fieldFilterJson, sort, skip, limit];
    [sort release];
    [skip release];
    [limit release];
    self.findQueryTextField.stringValue = query;
}

- (void)defaultSortOrderChangedNotification:(NSNotification *)notification
{
    [self.findSortTextField.cell setPlaceholderString:defaultSortOrder([MHPreferenceWindowController defaultSortOrder])];
    [self findQueryComposer];
}

@end

@implementation MHQueryViewController (InsertTab)

- (IBAction)insertQuery:(id)sender
{
    id objects;
    NSError *error;
    NSString *json;
    
    [self.insertLoaderIndicator startAnimation:nil];
    if ([[self.insertDataTextView.string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] characterAtIndex:0] == '[') {
        json = self.insertDataTextView.string;
    } else {
        json = [NSString stringWithFormat:@"[ %@ ]", self.insertDataTextView.string];
    }
    objects = [MODRagelJsonParser objectsFromJson:json withError:&error];
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
        if ([objects isKindOfClass:[MODSortedDictionary class]]) {
            objects = [NSArray arrayWithObject:objects];
        }
        [self.collection insertWithDocuments:objects writeConcern:nil callback:^(MODQuery *mongoQuery) {
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

@implementation MHQueryViewController (UpdateTab)

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
    [button selectItemAtIndex:-1];
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
    [self.updateTabView addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:previousView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:8.0]];
    [self.updateTabView addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.updateTabView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    [self.updateTabView addConstraint:[NSLayoutConstraint constraintWithItem:mainView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.updateTabView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1.0
                                                                    constant:0.0]];
}

- (IBAction)updateAddOperatorAction:(id)sender
{
    NSMutableDictionary *line = [NSMutableDictionary dictionary];
    NSView *mainView = nil;
    NSView *previousView;
    NSUInteger previousViewIndex;
    NSViewController *viewController = [[[NSViewController alloc] init] autorelease];

    [NSBundle.mainBundle loadNibNamed:@"MHQueryUpdateOperatorView" owner:viewController topLevelObjects:nil];
    mainView = viewController.view;
    NSAssert(mainView != nil, @"Should have found one top level object");
    line[@"main"] = mainView;
    line[@"popup"] = [mainView viewWithTag:1];
    line[@"textfield"] = [mainView viewWithTag:2];
    line[@"+"] = [mainView viewWithTag:3];
    line[@"-"] = [mainView viewWithTag:4];
    [(NSTextField *)line[@"textfield"] setDelegate:self];
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
    
    if (!sender) {
        [line[@"-"] setNextKeyView:self.updateCriteriaTextField.nextKeyView];
        self.updateCriteriaTextField.nextKeyView = line[@"popup"];
    } else {
        [line[@"-"] setNextKeyView:[[self.updateOperatorViews[previousViewIndex] objectForKey:@"-"] nextKeyView]];
        [[self.updateOperatorViews[previousViewIndex] objectForKey:@"-"] setNextKeyView:line[@"popup"]];
    }
    
    [self updateOperatorPopButtonAction:nil];
}

- (IBAction)updateRemoveOperatorAction:(id)sender
{
    NSView *mainView = [sender superview];
    NSUInteger index = [self _updateIndexOfOperatorWithView:mainView];
    
    if (index == 0) {
        self.updateCriteriaTextField.nextKeyView = [[self.updateOperatorViews[index] objectForKey:@"-"] nextKeyView];
    } else {
        [[self.updateOperatorViews[index - 1] objectForKey:@"-"] setNextKeyView:[[self.updateOperatorViews[index] objectForKey:@"-"] nextKeyView]];
    }
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
        NSInteger selectedItem = [popupButton indexOfSelectedItem];
        
        if (selectedItem == -1 || [usedIndexes containsIndex:selectedItem]) {
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
        [lineViews[@"-"] setEnabled:(self.updateOperatorViews.count > 1)];
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
    MODSortedDictionary *query = nil;
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
        return;
    }
    for (NSDictionary *views in self.updateOperatorViews) {
        NSTextField *textField = views[@"textfield"];
        NSPopUpButton *popUpButton = views[@"popup"];
        MODSortedDictionary *value;
        NSString *key = popUpButton.titleOfSelectedItem;
        
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
                               writeConcern:nil
                                   callback:^(MODQuery *updateQuery) {
            NSColor *flashColor;
            
            if (updateQuery.error) {
                self.updateResultsTextField.stringValue = @"Error!";
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", updateQuery.error.localizedDescription);
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
    
    self.updateQueryTextField.stringValue = [NSString stringWithFormat:@"db.%@.update(%@%@%@)", self.collection.name, critical, sets, options];
}

@end

@implementation MHQueryViewController (RemoveTab)

- (IBAction)removeQuery:(id)sender
{
    MODSortedDictionary *criteria;
    NSError *error;
    
    criteria = [MODRagelJsonParser objectsFromJson:[self formatedJsonWithTextField:self.removeCriteriaTextField replace:NO emptyValid:NO] withError:&error];
    if (error) {
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, @"%@", @"%@", error.localizedDescription);
    } else if ([criteria count] == 0 && ((self.view.window.currentEvent.modifierFlags & NSCommandKeyMask) != NSCommandKeyMask)) {
        NSAlert *alert;
        
        alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to remove all documents in %@", self.collection.absoluteName] defaultButton:@"Cancel" alternateButton:@"Remove All" otherButton:nil informativeTextWithFormat:@"This action cannot be undone"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(removeAllDocumentsPanelDidEnd:returnCode:contextInfo:) contextInfo:[criteria retain]];
    } else {
        [self _removeQueryWithCriteria:criteria];
    }
}

- (IBAction)removeQueryComposer:(id)sender
{
    NSString *criteria = [self formatedJsonWithTextField:self.removeCriteriaTextField replace:NO emptyValid:NO];
    
    self.removeQueryTextField.stringValue = [NSString stringWithFormat:@"db.%@.remove(%@)", self.collection.name, criteria];
}

@end

@implementation MHQueryViewController (IndexTab)

- (IBAction)indexQueryAction:(id)sender
{
    [self.indexLoaderIndicator startAnimation:nil];
    [self.collection findIndexesWithCallback:^(NSArray *indexes, MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
        } else {
            [self.indexDocumentOutlineViewController displayDocuments:[MODHelper convertForOutlineWithObjects:indexes bsonData:nil jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch] withLabel:nil];
        }
        [self.indexLoaderIndicator stopAnimation:nil];
    }];
}

- (IBAction)createIndexAction:(id)sender
{
    NSAssert(self.indexEditorController == nil, @"should have no index editor");
    self.indexEditorController = [[[MHIndexEditorController alloc] init] autorelease];
    [self.indexEditorController modalForWindow:self.view.window];
    self.indexEditorController.delegate = self;
}

- (IBAction)dropIndexAction:(id)sender
{
    NSArray *indexes;
    
    indexes = self.indexDocumentOutlineViewController.selectedDocuments;
    if (indexes.count == 1) {
        [self.indexLoaderIndicator startAnimation:nil];
        [self.collection dropIndexName:[[[indexes objectAtIndex:0] objectForKey:@"objectvalue"] objectForKey:@"name"] callback:^(MODQuery *mongoQuery) {
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            } else {
                NSArray *objectIds = @[ [[indexes objectAtIndex:0] objectForKey:@"objectvalueid"] ];
                [self.indexDocumentOutlineViewController removeDocumentsWithIds:objectIds];
            }
            [self.indexLoaderIndicator stopAnimation:nil];
        }];
    }
}

- (void)indexEditorControllerDidCancel:(MHIndexEditorController *)controller
{
    self.indexEditorController = nil;
}

- (void)indexEditorControllerDidValidate:(MHIndexEditorController *)controller
{
    [self.indexLoaderIndicator startAnimation:nil];
    [self.collection createIndexWithKeys:controller.keys indexOptions:controller.indexOptions callback:^(MODQuery *mongoQuery) {
        [self indexQueryAction:nil];
    }];
    self.indexEditorController = nil;
}

@end

@implementation MHQueryViewController (Aggregation)

- (IBAction)aggregationRunAction:(id)sender
{
    NSArray *pipeline = nil;
    MODSortedDictionary *options = nil;
    NSError *error = nil;
    
    if ([self.aggregationPipeline.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        pipeline = [MODRagelJsonParser objectsFromJson:self.aggregationPipeline.string withError:&error];
        if (error) {
            NSBeginAlertSheet(@"Error in Pipeline", @"OK", nil, nil, self.view.window, nil, nil, nil, @"%@", @"%@", error.localizedDescription);
            return;
        }
        if ([pipeline isKindOfClass:[MODSortedDictionary class]]) {
            // just make it easier for the user if he omits []
            pipeline = @[ pipeline ];
        }
    }
    if ([self.aggregationOptions.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        options = [MODRagelJsonParser objectsFromJson:self.aggregationOptions.string withError:&error];
        if (error) {
            NSBeginAlertSheet(@"Error in Options", @"OK", nil, nil, self.view.window, nil, nil, nil, @"%@", @"%@", error.localizedDescription);
            return;
        }
    }
    [self.aggregationLoaderIndicator startAnimation:nil];
    [self.collection aggregateWithFlags:MODQueryFlagsNone pipeline:pipeline options:options readPreferences:nil callback:^(MODQuery *mongoQuery, MODCursor *cursor) {
        [self.aggregationLoaderIndicator stopAnimation:nil];
        
        if (mongoQuery.error) {
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            [self.aggregationDocumentOutlineViewController displayDocuments:nil withLabel:nil];
        } else {
            NSMutableArray *documents = [NSMutableArray array];
            NSMutableArray *allData = [NSMutableArray array];
            
            [cursor forEachDocumentWithCallbackDocumentCallback:^(uint64_t index, MODSortedDictionary *document, NSData *documentData) {
                                                        [documents addObject:document];
                                                        [allData addObject:documentData];
                                                        return YES;
                                                    }
                                                    endCallback:^(uint64_t documentCounts, BOOL cursorStopped, MODQuery *forEachQuery) {
                                                        NSString *label = [NSString stringWithFormat:@"%lld documents", documentCounts];
                                                        NSArray *displayedDocuments = [MODHelper convertForOutlineWithObjects:documents bsonData:allData jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
                                                        [self.aggregationDocumentOutlineViewController displayDocuments:displayedDocuments withLabel:label];
                                                    }];
        }
    }];
}

@end

@implementation MHQueryViewController (mrTab)

- (IBAction)mapReduce:(id)sender
{
    NSString *stringQuery = self.mrCriteriaTextField.stringValue;
    MODSortedDictionary *query = nil;
    NSString *stringOutput = self.mrOutputTextField.stringValue;
    MODSortedDictionary *output = nil;
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
        [self.collection mapReduceWithMapFunction:self.mrMapFunctionTextView.string
                                   reduceFunction:self.mrReduceFunctionTextView.string
                                            query:query
                                             sort:nil
                                            limit:-1
                                           output:output
                                         keepTemp:NO
                                 finalizeFunction:nil
                                            scope:nil
                                           jsmode:NO
                                          verbose:NO
                                  readPreferences:nil
                                         callback:^(MODQuery *mongoQuery, MODSortedDictionary *documents) {
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            } else {
                NSArray *convertedDocuments;
                
                convertedDocuments = [MODHelper convertForOutlineWithObjects:@[ documents ] bsonData:nil jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
                [self.mrDocumentOutlineViewController displayDocuments:convertedDocuments withLabel:[NSString stringWithFormat:@"%0.2fs", [[mongoQuery.userInfo objectForKey:@"timequery"] duration]]];
            }
            [self.mrLoaderIndicator stopAnimation:nil];
        }];
    }
}

@end

@implementation MHQueryViewController(NSComboBox)

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
            self.findFieldFilterTextField.stringValue = [query objectForKey:@"fields"];
        } else {
            self.findFieldFilterTextField.stringValue = @"";
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

@implementation MHQueryViewController (UKSyntaxColoredTextViewDelegate)

@end

@implementation MHQueryViewController (MHDocumentOutlineViewDelegate)

- (void)documentOutlineViewController:(MHDocumentOutlineViewController *)controller shouldDeleteDocumentIds:(NSArray *)documentIds
{
    [self.removeQueryLoaderIndicator startAnimation:nil];
    if (documentIds.count > 0) {
        MODSortedDictionary *criteria;
        MODSortedDictionary *inCriteria;
        
        inCriteria = [MODSortedDictionary sortedDictionaryWithObjectsAndKeys:documentIds, @"$in", nil];
        criteria = [MODSortedDictionary sortedDictionaryWithObjectsAndKeys:inCriteria, @"_id", nil];
        [self.collection removeWithCriteria:criteria callback:^(MODQuery *mongoQuery) {
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.view.window, nil, nil, nil, NULL, @"%@", mongoQuery.error.localizedDescription);
            } else {
                [controller removeDocumentsWithIds:documentIds];
            }
            [self.removeQueryLoaderIndicator stopAnimation:nil];
        }];
    }
}

- (void)documentOutlineViewControllerBackButton:(MHDocumentOutlineViewController *)controller
{
    if (controller == self.findDocumentOutlineViewController) {
        NSInteger skipValue;
        
        skipValue = self.findSkipTextField.stringValue.integerValue;
        if (skipValue > 0) {
            NSInteger limitValue;
            
            limitValue = self.findLimitTextField.stringValue.integerValue;
            skipValue -= limitValue;
            if (skipValue < 0) {
                skipValue = 0;
            }
            self.findSkipTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)skipValue];
            [self findQuery:nil];
        }
    }
}

- (void)documentOutlineViewControllerNextButton:(MHDocumentOutlineViewController *)controller
{
    if (controller == self.findDocumentOutlineViewController) {
        NSInteger skipValue;
        NSInteger limitValue;
        
        skipValue = self.findSkipTextField.stringValue.integerValue;
        limitValue = self.findLimitTextField.stringValue.integerValue;
        skipValue += limitValue;
        self.findSkipTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)skipValue];
        [self findQuery:nil];
    }
}

- (void)documentOutlineViewController:(MHDocumentOutlineViewController *)controller doubleClickOnDocuments:(NSArray *)documents
{
    if (controller == self.findDocumentOutlineViewController) {
        for (NSDictionary *document in documents) {
            id idValue;
            MHJsonWindowController *jsonWindowController;
            
            idValue = [document objectForKey:@"objectvalueid"];
            jsonWindowController = self.jsonWindowControllers[idValue];
            NSAssert(idValue != nil, @"No idValue for %@", document);
            if (!jsonWindowController) {
                jsonWindowController = [[MHJsonWindowController alloc] init];
                jsonWindowController.collection = self.collection;
                jsonWindowController.windowControllerId = idValue;
                jsonWindowController.jsonDocument = document[@"objectvalue"];
                jsonWindowController.bsonData = document[@"bsondata"];
                [jsonWindowController showWindow:nil];
                self.jsonWindowControllers[idValue] = jsonWindowController;
                [jsonWindowController release];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findQuery:) name:kJsonWindowSaved object:jsonWindowController];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsonWindowWillClose:) name:kJsonWindowWillClose object:jsonWindowController];
            } else {
                [jsonWindowController showWindow:self];
            }
        }
    }
}

- (void)documentOutlineViewControllerSelectionDidChange:(MHDocumentOutlineViewController *)controller
{
    if (controller == self.indexDocumentOutlineViewController) {
        self.indexDropButton.enabled = self.indexDocumentOutlineViewController.selectedDocumentCount > 0;
    }
}

@end
