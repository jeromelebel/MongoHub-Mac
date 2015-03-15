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

@property (nonatomic, readwrite, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *feedbackLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *expandPopUpButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *backButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *nextButton;

@property (nonatomic, readwrite, assign) BOOL removeButtonHidden;
@property (nonatomic, readwrite, assign) BOOL nextBackButtonsHidden;
@property (nonatomic, readwrite, copy) NSArray *documents;

@end

@interface MHDocumentOutlineViewController (NSOutlineViewDataSource) <NSOutlineViewDataSource>
@end

@implementation MHDocumentOutlineViewController

@synthesize outlineView = _outlineView;
@synthesize feedbackLabel = _feedbackLabel;
@synthesize expandPopUpButton = _expandPopUpButton;
@synthesize removeButton = _removeButton;
@synthesize backButton = _backButton;
@synthesize nextButton = _nextButton;

@synthesize removeButtonHidden = _removeButtonHidden;
@synthesize nextBackButtonsHidden = _nextBackButtonsHidden;
@synthesize documents = _documents;
@synthesize delegate = _delegate;

+ (void)addDocumentOutlineViewController:(MHDocumentOutlineViewController *)controller intoView:(NSView *)view
{
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

- (NSString *)nibName
{
    return @"MHDocumentOutlineView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)awakeFromNib
{
    self.removeButton.hidden = self.removeButtonHidden;
    self.backButton.hidden = self.nextBackButtonsHidden;
    self.nextButton.hidden = self.nextBackButtonsHidden;
}

- (void)displayDocuments:(NSArray *)newDocuments withLabel:(NSString *)label
{
    self.feedbackLabel.stringValue = label;
    [NSViewHelpers setColor:self.feedbackLabel.textColor
                  fromColor:[NSColor greenColor]
                   toTarget:self.feedbackLabel
               withSelector:@selector(setTextColor:)
                      delay:1];
    self.documents = newDocuments;
    [self.outlineView reloadData];
    [self _expandDocuments];
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
    
}

- (IBAction)backButtonAction:(id)sender
{
    
}

- (IBAction)removeButtonAction:(id)sender
{
    [self.delegate documentOutlineViewController:self shouldDeleteDocument:nil];
}

- (IBAction)expandPopUpButtonAction:(id)sender
{
    [self _expandDocuments];
}

@end
