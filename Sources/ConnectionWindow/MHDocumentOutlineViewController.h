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
- (BOOL)documentOutlineViewController:(MHDocumentOutlineViewController *)controller shouldDeleteDocument:(MODSortedDictionary *)document;
@end

@interface MHDocumentOutlineViewController : NSViewController
{
    NSOutlineView                           *_outlineView;
    NSTextField                             *_feedbackLabel;
    NSButton                                *_expandPopUpButton;
    NSButton                                *_removeButton;
    NSButton                                *_backButton;
    NSButton                                *_nextButton;
    
    id<MHDocumentOutlineViewDelegate>       _delegate;
    NSArray                                 *_documents;
}

@property (nonatomic, readwrite, weak) id<MHDocumentOutlineViewDelegate> delegate;
@property (nonatomic, readonly, copy) NSArray *documents;

+ (void)addDocumentOutlineViewController:(MHDocumentOutlineViewController *)controller intoView:(NSView *)view;

- (void)displayDocuments:(NSArray *)documents;

@end
