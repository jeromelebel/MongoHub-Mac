//
//  MHQueryViewController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHTabItemViewController.h"
#import "UKSyntaxColoredTextViewController.h"
#import "MHDocumentOutlineViewController.h"

@class MODCollection;
@class MHConnectionStore;
@class MHIndexEditorController;
@class MHDocumentOutlineViewController;

@interface MHQueryViewController : MHTabItemViewController
{
    NSTabView                                   *_tabView;
    NSSegmentedControl                          *_segmentedControl;
    
    NSComboBox                                  *_findCriteriaComboBox;
    NSTextField                                 *_findFieldFilterTextField;
    NSTextField                                 *_findSkipTextField;
    NSTextField                                 *_findLimitTextField;
    NSTextField                                 *_findSortTextField;
    NSTextField                                 *_findTotalResultsTextField;
    NSTextField                                 *_findQueryTextField;
    NSProgressIndicator                         *_findQueryLoaderIndicator;
    NSView                                      *_findResultView;
    
    NSButton                                    *_insertButton;
    NSTextView                                  *_insertDataTextView;
    NSTextField                                 *_insertResultsTextField;
    NSProgressIndicator                         *_insertLoaderIndicator;
    
    NSView                                      *_updateTabView;
    NSButton                                    *_updateButton;
    NSTextField                                 *_updateCriteriaTextField;
    NSButton                                    *_updateUpsetCheckBox;
    NSButton                                    *_updateMultiCheckBox;
    NSTextField                                 *_updateResultsTextField;
    NSTextField                                 *_updateQueryTextField;
    NSProgressIndicator                         *_updateQueryLoaderIndicator;
    
    NSButton                                    *_removeButton;
    NSTextField                                 *_removeCriteriaTextField;
    NSTextField                                 *_removeResultsTextField;
    NSTextField                                 *_removeQueryTextField;
    NSProgressIndicator                         *_removeQueryLoaderIndicator;
    
    NSOutlineView                               *_indexOutlineView;
    NSProgressIndicator                         *_indexLoaderIndicator;
    NSButton                                    *_indexDropButton;
    NSButton                                    *_indexCreateButton;
    NSView                                      *_indexResultView;
    
    NSTextView                                  *_aggregationPipeline;
    NSTextView                                  *_aggregationOptions;
    NSProgressIndicator                         *_aggregationLoaderIndicator;
    NSView                                      *_aggregationResultView;
    
    NSTextView                                  *_mrMapFunctionTextView;
    NSTextView                                  *_mrReduceFunctionTextView;
    NSTextField                                 *_mrCriteriaTextField;
    NSTextField                                 *_mrOutputTextField;
    NSProgressIndicator                         *_mrLoaderIndicator;
    NSOutlineView                               *_mrOutlineView;
    NSView                                      *_mrResultView;
}

@property (nonatomic, readonly, strong) MODCollection *collection;
@property (nonatomic, readonly, strong) MHConnectionStore *connectionStore;

- (instancetype)initWithCollection:(MODCollection *)collection connectionStore:(MHConnectionStore *)connectionStore;

- (IBAction)segmentedControlAction:(id)sender;

- (void)jsonWindowWillClose:(id)sender;
- (BOOL)canPerformCopy;
- (void)performCopy;

@end

@interface MHQueryViewController (InsertTab)
- (IBAction)insertQuery:(id)sender;

@end

@interface MHQueryViewController (RemoveTab)
- (IBAction)removeQuery:(id)sender;
- (void)removeQueryComposer:(id)sender;

@end

@interface MHQueryViewController (mrTab)
- (IBAction)mapReduce:(id)sender;

@end

@interface MHQueryViewController (UKSyntaxColoredTextViewDelegate) <UKSyntaxColoredTextViewDelegate>
@end

@interface MHQueryViewController (MHDocumentOutlineViewDelegate) <MHDocumentOutlineViewDelegate>

@end
