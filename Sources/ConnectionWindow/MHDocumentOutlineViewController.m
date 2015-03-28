//
//  MHDocumentOutlineViewController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 06/03/2015.
//
//

#import "MHDocumentOutlineViewController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "NSViewHelpers.h"

@interface MHDocumentOutlineViewController ()

@property (nonatomic, readwrite, weak) IBOutlet NSScrollView *outlineViewScrollView;
@property (nonatomic, readwrite, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *feedbackLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *expandPopUpButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *backButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *nextButton;

@property (nonatomic, readwrite, assign) BOOL footerViewHidden;
@property (nonatomic, readwrite, assign) BOOL removeButtonHidden;
@property (nonatomic, readwrite, assign) BOOL nextBackButtonsHidden;
@property (nonatomic, readwrite, assign) BOOL disallowsMultipleSelection;

@property (nonatomic, readwrite, copy) NSArray *documents;

@end

@interface MHDocumentOutlineViewController (NSOutlineViewDataSource) <NSOutlineViewDataSource>
@end

@implementation MHDocumentOutlineViewController

@synthesize outlineViewScrollView = _outlineViewScrollView;
@synthesize outlineView = _outlineView;
@synthesize feedbackLabel = _feedbackLabel;
@synthesize expandPopUpButton = _expandPopUpButton;
@synthesize removeButton = _removeButton;
@synthesize backButton = _backButton;
@synthesize nextButton = _nextButton;

@synthesize footerViewHidden = _footerViewHidden;
@synthesize removeButtonHidden = _removeButtonHidden;
@synthesize nextBackButtonsHidden = _nextBackButtonsHidden;
@synthesize disallowsMultipleSelection = _disallowsMultipleSelection;
@synthesize documents = _documents;
@synthesize delegate = _delegate;

+ (void)addDocumentOutlineViewController:(MHDocumentOutlineViewController *)controller intoView:(NSView *)view
{
    NSAssert(view != nil, @"should have a view where to put the outlineview");
    NSAssert(controller != nil, @"should have a controller");
    NSAssert(controller.view != nil, @"should have a controller view");
    [view addSubview:controller.view];
    controller.view.frame = view.bounds;
    [view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:0]];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:nil object:nil];
    [super dealloc];
}

- (NSString *)nibName
{
    return @"MHDocumentOutlineView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.outlineView setDoubleAction:@selector(doubleClickAction:)];
    self.backButton.enabled = NO;
    if (self.footerViewHidden) {
        [self.removeButton removeFromSuperview];
        self.removeButton = nil; // not on ARC yet
        [self.backButton removeFromSuperview];
        self.backButton = nil; // not on ARC yet
        [self.nextButton removeFromSuperview];
        self.nextButton = nil; // not on ARC yet
        [self.feedbackLabel removeFromSuperview];
        self.feedbackLabel = nil; // not on ARC yet
        [self.expandPopUpButton removeFromSuperview];
        self.expandPopUpButton = nil;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.outlineViewScrollView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
    } else {
        if (self.removeButtonHidden) {
            [self.removeButton removeFromSuperview];
            self.removeButton = nil; // not on ARC yet
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.expandPopUpButton
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.feedbackLabel
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:8.0]];
        }
        if (self.nextBackButtonsHidden) {
            [self.backButton removeFromSuperview];
            self.backButton = nil; // not on ARC yet
            [self.nextButton removeFromSuperview];
            self.nextButton = nil; // not on ARC yet
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.expandPopUpButton
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        }
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(outlineViewSelectionDidChangeNotification:) name:NSOutlineViewSelectionDidChangeNotification object:self.outlineView];
    self.outlineView.allowsMultipleSelection = !self.disallowsMultipleSelection;
}

- (void)removeDocumentsWithIds:(NSArray *)documentIds
{
    NSMutableArray *newDocumentList = [NSMutableArray array];
    
    for (NSDictionary *document in self.documents) {
        if (![documentIds containsObject:document[@"objectvalueid"]]) {
            [newDocumentList addObject:document];
        }
    }
    if (self.documents.count != newDocumentList.count) {
        self.documents = newDocumentList;
        [self.outlineView reloadData];
        if (documentIds.count == 1) {
            [self displayLabel:@"1 document removed"];
        } else {
            [self displayLabel:[NSString stringWithFormat:@"%ld documents removed", documentIds.count]];
        }
    }
}

- (void)displayDocuments:(NSArray *)newDocuments withLabel:(NSString *)label
{
    if (!label) {
        self.feedbackLabel.stringValue = @"";
    } else {
        [self displayLabel:label];
    }
    self.documents = newDocuments;
    [self.outlineView reloadData];
    [self _expandDocuments];
}

- (void)displayErrorLabel:(NSString *)label
{
    [NSViewHelpers cancelColorForTarget:self.feedbackLabel selector:@selector(setTextColor:)];
    self.feedbackLabel.stringValue = label;
    [NSViewHelpers setColor:self.feedbackLabel.textColor
                  fromColor:[NSColor redColor]
                   toTarget:self.feedbackLabel
               withSelector:@selector(setTextColor:)
                      delay:1];
    self.documents = nil;
    [self.outlineView reloadData];
}

- (void)displayLabel:(NSString *)label
{
    [NSViewHelpers cancelColorForTarget:self.feedbackLabel selector:@selector(setTextColor:)];
    self.feedbackLabel.stringValue = label;
    [NSViewHelpers setColor:self.feedbackLabel.textColor
                  fromColor:[NSColor greenColor]
                   toTarget:self.feedbackLabel
               withSelector:@selector(setTextColor:)
                      delay:1];
}

- (void)setBackButtonEnabled:(BOOL)enabled
{
    self.backButton.enabled = enabled;
}

- (void)_expandDocuments
{
    NSInteger expandValue;
    
    expandValue = self.expandPopUpButton.selectedTag;
    if (expandValue == 0) {
        [self.outlineView collapseItem:nil collapseChildren:YES];
    } else if (expandValue == 100) {
        [self.outlineView collapseItem:nil collapseChildren:NO];
        [self.outlineView expandItem:nil expandChildren:YES];
    } else if (expandValue > 0) {
        NSInteger index = 0;
        id item;;
        NSOutlineView *outlineView = self.outlineView;
        
        while ((item = [outlineView itemAtRow:index])) {
            if ([outlineView levelForItem:item] < expandValue) {
                [outlineView expandItem:item];
            } else {
                [outlineView collapseItem:item];
            }
            index++;
        }
    }
}

- (void)outlineViewSelectionDidChangeNotification:(NSNotification *)notification
{
    self.removeButton.enabled = self.outlineView.selectedRowIndexes.count != 0;
    if ([self.delegate respondsToSelector:@selector(documentOutlineViewControllerSelectionDidChange:)]) {
        [self.delegate documentOutlineViewControllerSelectionDidChange:self];
    }
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    if (anItem.action == @selector(copy:)) {
        return (id)self.view.window.firstResponder == self.outlineView && self.selectedDocumentCount > 0;
    }
    return [self respondsToSelector:anItem.action];
}

- (void)copy:(id)sender
{
    if ((id)self.view.window.firstResponder == self.outlineView && self.selectedDocumentCount > 0) {
        NSPasteboard *pasteboard;
        
        pasteboard = NSPasteboard.generalPasteboard;
        [pasteboard clearContents];
        [self outlineView:self.outlineView writeItems:self.selectedDocuments toPasteboard:pasteboard];
    }
}

- (NSArray *)selectedDocuments
{
    NSMutableArray *documents;
    
    documents = [NSMutableArray array];
    [self.outlineView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id currentItem = [self.outlineView itemAtRow:idx];
        
        [documents addObject:[self rootForItem:currentItem]];
    }];
    return documents;
}

- (NSArray *)selectedDocumentIds
{
    NSMutableArray *documentIds;
    
    documentIds = [NSMutableArray array];
    [self.outlineView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id currentItem = [self.outlineView itemAtRow:idx];
        
        [documentIds addObject:[[self rootForItem:currentItem] objectForKey:@"objectvalueid"]];
    }];
    return documentIds;
}

- (NSInteger)selectedDocumentCount
{
    return self.outlineView.selectedRowIndexes.count;
}

- (id)rootForItem:(id)item
{
    id parentItem = [self.outlineView parentForItem:item];
    
    if (parentItem) {
        return [self rootForItem:parentItem];
    } else {
        return item;
    }
    
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableString *string = [NSMutableString stringWithString:@"[\n"];
    BOOL firstDocument = YES;
    
    for (NSDictionary *item in items) {
        if (firstDocument) {
            firstDocument = NO;
        } else {
            [string appendString:@",\n"];
        }
        [string appendString:[MODClient convertObjectToJson:[[self rootForItem:item] objectForKey:@"objectvalue"] pretty:YES strictJson:NO jsonKeySortOrder:MODJsonKeySortOrderDocument]];
    }
    [string appendString:@"\n]\n"];
    [pasteboard setString:string forType:NSStringPboardType];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
    return NO;
}

- (IBAction)doubleClickAction:(id)sender
{
    [self.delegate documentOutlineViewController:self doubleClickOnDocuments:self.selectedDocuments];
}

@end

@implementation MHDocumentOutlineViewController (NSOutlineViewDataSource)

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.documents count];
    } else {
        return [[item objectForKey:@"child"] count];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return self.documents[index];
    } else {
        return [[item objectForKey:@"child" ] objectAtIndex:index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [[item objectForKey:@"child"] count] != 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return [item objectForKey:tableColumn.identifier];
}

@end

@implementation MHDocumentOutlineViewController (UI)

- (IBAction)nextButtonAction:(id)sender
{
    [self.delegate documentOutlineViewControllerNextButton:self];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.delegate documentOutlineViewControllerBackButton:self];
}

- (IBAction)removeButtonAction:(id)sender
{
    NSArray *selectedDocumentIds = [self selectedDocumentIds];
    
    [self.delegate documentOutlineViewController:self shouldDeleteDocumentIds:selectedDocumentIds];
}

- (IBAction)expandPopUpButtonAction:(id)sender
{
    [self _expandDocuments];
}

@end
