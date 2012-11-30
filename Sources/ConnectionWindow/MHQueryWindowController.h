//
//  MHQueryWindowController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHTabItemViewController.h"

@class DatabasesArrayController;
@class MHResultsOutlineViewController;
@class MODServer;
@class MODCollection;
@class MHConnectionStore;

@interface MHQueryWindowController : MHTabItemViewController
{
    DatabasesArrayController *databasesArrayController;
    IBOutlet MHResultsOutlineViewController *findResultsViewController;
    IBOutlet NSOutlineView *findResultsOutlineView;
    MODCollection *_mongoCollection;
    MHConnectionStore *_connectionStore;
    NSMutableDictionary *_jsonWindowControllers;
    
    IBOutlet NSTabView *tabView;
    IBOutlet NSSegmentedControl *segmentedControl;
    
    IBOutlet NSComboBox *_criteriaComboBox;
    IBOutlet NSTokenField *_fieldsTextField;
    IBOutlet NSTextField *_skipTextField;
    IBOutlet NSTextField *_limitTextField;
    IBOutlet NSTextField *_sortTextField;
    IBOutlet NSTextField *totalResultsTextField;
    IBOutlet NSTextField *findQueryTextField;
    IBOutlet NSProgressIndicator *findQueryLoaderIndicator;
    
    IBOutlet NSTextField *updateCriticalTextField;
    IBOutlet NSTextField *updateSetTextField;
    IBOutlet NSButton *upsetCheckBox;
    IBOutlet NSButton *multiCheckBox;
    IBOutlet NSTextField *updateResultsTextField;
    IBOutlet NSTextField *updateQueryTextField;
    IBOutlet NSProgressIndicator *updateQueryLoaderIndicator;
    
    IBOutlet NSTextField *removeCriticalTextField;
    IBOutlet NSTextField *removeResultsTextField;
    IBOutlet NSTextField *removeQueryTextField;
    IBOutlet NSProgressIndicator *removeQueryLoaderIndicator;
    
    IBOutlet NSTextView *insertDataTextView;
    IBOutlet NSTextField *insertResultsTextField;
    IBOutlet NSProgressIndicator *insertLoaderIndicator;
    
    IBOutlet NSTextField *indexTextField;
    IBOutlet MHResultsOutlineViewController *indexesOutlineViewController;
    IBOutlet NSProgressIndicator *indexLoaderIndicator;
    
    IBOutlet NSTextView *mapFunctionTextView;
    IBOutlet NSTextView *reduceFunctionTextView;
    IBOutlet NSTextField *mrcriticalTextField;
    IBOutlet NSTextField *mroutputTextField;
    IBOutlet NSProgressIndicator *mrLoaderIndicator;
    IBOutlet MHResultsOutlineViewController *mrOutlineViewController;
    
    IBOutlet NSTextField *expCriticalTextField;
    IBOutlet NSTokenField *expFieldsTextField;
    IBOutlet NSTextField *expSkipTextField;
    IBOutlet NSTextField *expLimitTextField;
    IBOutlet NSTextField *expSortTextField;
    IBOutlet NSTextField *expResultsTextField;
    IBOutlet NSTextField *expPathTextField;
    IBOutlet NSPopUpButton *expTypePopUpButton;
    IBOutlet NSTextField *expQueryTextField;
    IBOutlet NSButton *expJsonArrayCheckBox;
    IBOutlet NSProgressIndicator *expProgressIndicator;
    
    IBOutlet NSButton *impIgnoreBlanksCheckBox;
    IBOutlet NSButton *impDropCheckBox;
    IBOutlet NSButton *impHeaderlineCheckBox;
    IBOutlet NSTokenField *impFieldsTextField;
    IBOutlet NSTextField *impResultsTextField;
    IBOutlet NSTextField *impPathTextField;
    IBOutlet NSPopUpButton *impTypePopUpButton;
    IBOutlet NSButton *impJsonArrayCheckBox;
    IBOutlet NSButton *impStopOnErrorCheckBox;
    IBOutlet NSProgressIndicator *impProgressIndicator;
}

@property (nonatomic, retain) DatabasesArrayController *databasesArrayController;
@property (nonatomic, retain) MHResultsOutlineViewController *findResultsViewController;
@property (nonatomic, retain, readwrite) MODCollection *mongoCollection;
@property (nonatomic, retain, readwrite) MHConnectionStore *connectionStore;

@property (nonatomic, retain) NSTokenField *fieldsTextField;
@property (nonatomic, retain) NSTextField *skipTextField;
@property (nonatomic, retain) NSTextField *limitTextField;
@property (nonatomic, retain) NSTextField *totalResultsTextField;
@property (nonatomic, retain) NSTextField *findQueryTextField;
@property (nonatomic, retain) NSOutlineView *findResultsOutlineView;
@property (nonatomic, retain) NSProgressIndicator *findQueryLoaderIndicator;

@property (nonatomic, retain) NSTextField *updateCriticalTextField;
@property (nonatomic, retain) NSTextField *updateSetTextField;
@property (nonatomic, retain) NSButton *upsetCheckBox;
@property (nonatomic, retain) NSButton *multiCheckBox;
@property (nonatomic, retain) NSTextField *updateResultsTextField;
@property (nonatomic, retain) NSTextField *updateQueryTextField;
@property (nonatomic, retain) NSProgressIndicator *updateQueryLoaderIndicator;

@property (nonatomic, retain) NSTextField *removeCriticalTextField;
@property (nonatomic, retain) NSTextField *removeResultsTextField;
@property (nonatomic, retain) NSTextField *removeQueryTextField;
@property (nonatomic, retain) NSProgressIndicator *removeQueryLoaderIndicator;

@property (nonatomic, retain) NSTextView *insertDataTextView;
@property (nonatomic, retain) NSTextField *insertResultsTextField;
@property (nonatomic, retain) NSProgressIndicator *insertLoaderIndicator;

@property (nonatomic, retain) NSTextField *indexTextField;
@property (nonatomic, retain) MHResultsOutlineViewController *indexesOutlineViewController;
@property (nonatomic, retain) NSProgressIndicator *indexLoaderIndicator;

@property (nonatomic, retain) NSTextView *mapFunctionTextView;
@property (nonatomic, retain) NSTextView *reduceFunctionTextView;
@property (nonatomic, retain) NSTextField *mrcriticalTextField;
@property (nonatomic, retain) NSTextField *mroutputTextField;
@property (nonatomic, retain) MHResultsOutlineViewController *mrOutlineViewController;
@property (nonatomic, retain) NSProgressIndicator *mrLoaderIndicator;

@property (nonatomic, retain) NSTextField *expCriticalTextField;
@property (nonatomic, retain) NSTokenField *expFieldsTextField;
@property (nonatomic, retain) NSTextField *expSkipTextField;
@property (nonatomic, retain) NSTextField *expLimitTextField;
@property (nonatomic, retain) NSTextField *expSortTextField;
@property (nonatomic, retain) NSTextField *expResultsTextField;
@property (nonatomic, retain) NSTextField *expPathTextField;
@property (nonatomic, retain) NSPopUpButton *expTypePopUpButton;
@property (nonatomic, retain) NSTextField *expQueryTextField;
@property (nonatomic, retain) NSButton *expJsonArrayCheckBox;
@property (nonatomic, retain) NSProgressIndicator *expProgressIndicator;

@property (nonatomic, retain) NSButton *impIgnoreBlanksCheckBox;
@property (nonatomic, retain) NSButton *impDropCheckBox;
@property (nonatomic, retain) NSButton *impHeaderlineCheckBox;
@property (nonatomic, retain) NSTokenField *impFieldsTextField;
@property (nonatomic, retain) NSTextField *impResultsTextField;
@property (nonatomic, retain) NSTextField *impPathTextField;
@property (nonatomic, retain) NSPopUpButton *impTypePopUpButton;
@property (nonatomic, retain) NSButton *impJsonArrayCheckBox;
@property (nonatomic, retain) NSButton *impStopOnErrorCheckBox;
@property (nonatomic, retain) NSProgressIndicator *impProgressIndicator;

+ (id)loadQueryController;

- (IBAction)segmentedControlAction:(id)sender;
- (IBAction)findQuery:(id)sender;
- (IBAction)expandFindResults:(id)sender;
- (IBAction)collapseFindResults:(id)sender;
- (IBAction)updateQuery:(id)sender;
- (IBAction)removeQuery:(id)sender;
- (IBAction)insertQuery:(id)sender;
- (IBAction)indexQuery:(id)sender;
- (IBAction)ensureIndex:(id)sender;
- (IBAction)reIndex:(id)sender;
- (IBAction)dropIndex:(id)sender;
- (IBAction) mapReduce:(id)sender;
- (IBAction)removeRecord:(id)sender;

- (IBAction)findQueryComposer:(id)sender;
- (IBAction)updateQueryComposer:(id)sender;
- (IBAction)removeQueryComposer:(id)sender;
- (IBAction) exportQueryComposer:(id)sender;

- (void)showEditWindow:(id)sender;
- (void)jsonWindowWillClose:(id)sender;

- (IBAction)chooseExportPath:(id)sender;
- (IBAction)chooseImportPath:(id)sender;
//- (mongo::BSONObj)parseCSVLine:(char *)line type:(int)_type sep:(const char *)_sep headerLine:(bool)_headerLine ignoreBlanks:(bool)_ignoreBlanks fields:(std::vector<std::string> &)_fields;
@end
