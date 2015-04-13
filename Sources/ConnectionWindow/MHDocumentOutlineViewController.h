//
//  MHDocumentOutlineViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 06/03/2015.
//
//

#import <Cocoa/Cocoa.h>

@class MODCursor;
@class MHDocumentOutlineViewController;
@class MODSortedDictionary;

@protocol MHDocumentOutlineViewDelegate <NSObject>
- (void)documentOutlineViewController:(MHDocumentOutlineViewController *)controller shouldDeleteDocumentIds:(NSArray *)documentIds;
- (void)documentOutlineViewControllerBackButton:(MHDocumentOutlineViewController *)controller;
- (void)documentOutlineViewControllerNextButton:(MHDocumentOutlineViewController *)controller;
- (void)documentOutlineViewController:(MHDocumentOutlineViewController *)controller doubleClickOnDocuments:(NSArray *)documents;

@optional
- (void)documentOutlineViewControllerSelectionDidChange:(MHDocumentOutlineViewController *)controller;
@end

@interface MHDocumentOutlineViewController : NSViewController
{
    NSScrollView                            *_outlineViewScrollView;
    NSOutlineView                           *_outlineView;
    NSTextField                             *_feedbackLabel;
    NSButton                                *_expandPopUpButton;
    NSButton                                *_removeButton;
    NSButton                                *_backButton;
    NSButton                                *_nextButton;
    
    BOOL                                    _footerViewHidden;
    BOOL                                    _removeButtonHidden;
    BOOL                                    _nextBackButtonsHidden;
    BOOL                                    _disallowsMultipleSelection;
    
    id<MHDocumentOutlineViewDelegate>       _delegate;
    NSArray                                 *_documents;
}

@property (nonatomic, readwrite, weak) IBOutlet id<MHDocumentOutlineViewDelegate> delegate;
@property (nonatomic, readonly, copy) NSArray *documents;

+ (void)addDocumentOutlineViewController:(MHDocumentOutlineViewController *)controller intoView:(NSView *)view;

- (void)displayDocuments:(NSArray *)documents withLabel:(NSString *)label;
- (void)displayErrorLabel:(NSString *)label;
- (void)displayLabel:(NSString *)label;
- (NSArray *)selectedDocuments;
- (NSInteger)selectedDocumentCount;
- (void)setBackButtonEnabled:(BOOL)enabled;
- (void)removeDocumentsWithIds:(NSArray *)documentIds;
- (BOOL)canCopyDocuments;
- (void)copyDocuments;

@end
