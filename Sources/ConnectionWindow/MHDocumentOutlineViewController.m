//
//  MHDocumentOutlineViewController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 06/03/2015.
//
//

#import "MHDocumentOutlineViewController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>

@interface MHDocumentOutlineViewController ()

@property (nonatomic, readwrite, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *feedbackLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *expandPopUpButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *backButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *nextButton;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)displayDocuments:(NSArray *)newDocuments
{
    self.documents = newDocuments;
    [self.outlineView reloadData];
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
    
}

@end
