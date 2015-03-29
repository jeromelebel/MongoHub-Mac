//
//  MHTabViewController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//

#import "MHTabViewController.h"
#import "MHTabTitleView.h"
#import "MHTabItemViewController.h"
#import "MHTabTitleContainerView.h"

#define TAB_HEIGHT 35.0

@interface MHTabViewController()

@property (nonatomic, readwrite, strong) NSMutableArray *mutableTabControllers;
@property (nonatomic, readwrite, strong) NSMutableArray *tabTitleViewes;
@property (nonatomic, readwrite, strong) MHTabTitleContainerView *tabContainerView;
@property (nonatomic, readwrite, weak) NSView *selectedTabView;

@end

@implementation MHTabViewController

@synthesize delegate = _delegate;
@synthesize selectedTabView = _selectedTabView;

- (void)dealloc
{
    for (MHTabItemViewController *controller in self.mutableTabControllers) {
        [controller removeObserver:self forKeyPath:@"title"];
    }
    self.mutableTabControllers = nil;
    self.tabTitleViewes = nil;
    self.tabContainerView = nil;
    [self.view removeObserver:self forKeyPath:@"frame"];
    [super dealloc];
}

- (NSString *)nibName
{
    return @"MHTabView";
}

- (void)awakeFromNib
{
    if (self.mutableTabControllers == nil) {
        _selectedTabIndex = NSNotFound;
        self.mutableTabControllers = [NSMutableArray array];
        self.tabTitleViewes = [NSMutableArray array];
        self.tabContainerView = [[[MHTabTitleContainerView alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height - TAB_HEIGHT, self.view.bounds.size.width, TAB_HEIGHT)] autorelease];
        [self.view addSubview:self.tabContainerView];
        [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [self.tabContainerView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    }
}

- (NSRect)_rectForTabTitleAtIndex:(NSUInteger)index
{
    NSRect result;
    NSUInteger count;
    
    count = [self.mutableTabControllers count];
    result = self.tabContainerView.bounds;
    result.origin.y += result.size.height - TAB_HEIGHT;
    result.size.height = TAB_HEIGHT;
    result.size.width = round(result.size.width / count);
    result.origin.x = result.size.width * index;
    return result;
}

- (void)_removeCurrentTabItemViewController
{
    [self.selectedTabView removeFromSuperview];
    self.selectedTabView = nil;
}

- (void)_tabItemViewControllerWithIndex:(NSInteger)index
{
    if (_selectedTabIndex != NSNotFound && _selectedTabIndex < [self.tabTitleViewes count]) {
        [[self.tabTitleViewes objectAtIndex:_selectedTabIndex] setNeedsDisplay:YES];
        [[self.tabTitleViewes objectAtIndex:_selectedTabIndex] setSelected:NO];
    }
    _selectedTabIndex = index;
    if (_selectedTabIndex != NSNotFound) {
        NSRect rect;
        
        [[self.tabTitleViewes objectAtIndex:_selectedTabIndex] setNeedsDisplay:YES];
        rect = self.view.bounds;
        self.selectedTabView = [[self.mutableTabControllers objectAtIndex:_selectedTabIndex] view];
        [self.view addSubview:self.selectedTabView];
        rect.size.height -= TAB_HEIGHT;
        self.selectedTabView.frame = rect;
        [[self.tabTitleViewes objectAtIndex:_selectedTabIndex] setSelected:YES];
    }
}

- (void)_updateTitleViewesWithAnimation:(BOOL)animation exceptView:(MHTabTitleView *)exceptView
{
    NSUInteger ii = 0;
    
    for (MHTabTitleView *titleView in self.tabTitleViewes) {
        if (animation && exceptView != titleView) {
            [[titleView animator] setFrame:[self _rectForTabTitleAtIndex:ii]];
        } else {
            [titleView setFrame:[self _rectForTabTitleAtIndex:ii]];
        }
        titleView.selected = self.selectedTabIndex == ii;
        titleView.tag = ii;
        ii++;
    }
}

- (void)addTabItemViewController:(MHTabItemViewController *)tabItemViewController
{
    NSParameterAssert(tabItemViewController);
    if ([self.mutableTabControllers indexOfObject:tabItemViewController] == NSNotFound) {
        MHTabTitleView *titleView;
        
        tabItemViewController.tabViewController = self;
        [self.mutableTabControllers addObject:tabItemViewController];
        tabItemViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        titleView = [[MHTabTitleView alloc] initWithFrame:self.tabContainerView.bounds];
        titleView.tabViewController = self;
        titleView.stringValue = tabItemViewController.title;
        [self.tabTitleViewes addObject:titleView];
        [self.tabContainerView addSubview:titleView];
        [titleView release];
        [tabItemViewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        
        self.selectedTabIndex = [self.mutableTabControllers count] - 1;
        [self _updateTitleViewesWithAnimation:NO exceptView:nil];
    }
}

- (void)removeTabItemViewController:(MHTabItemViewController *)tabItemViewController
{
    NSUInteger index;
    
    index = [self.mutableTabControllers indexOfObject:tabItemViewController];
    if (index != NSNotFound) {
        [tabItemViewController willRemoveFromTabViewController];
        [tabItemViewController retain];
        [self willChangeValueForKey:@"selectedTabIndex"];
        [self _removeCurrentTabItemViewController];
        [tabItemViewController removeObserver:self forKeyPath:@"title"];
        [self.mutableTabControllers removeObjectAtIndex:index];
        [[self.tabTitleViewes objectAtIndex:index] removeFromSuperview];
        [self.tabTitleViewes removeObjectAtIndex:index];
        if ([self.mutableTabControllers count] == 0) {
            [self _tabItemViewControllerWithIndex:NSNotFound];
        } else if (_selectedTabIndex == 0) {
            [self _tabItemViewControllerWithIndex:0];
        } else {
            NSUInteger newIndex = index > _selectedTabIndex ? _selectedTabIndex : _selectedTabIndex - 1;
            [self _tabItemViewControllerWithIndex: newIndex];
        }
        [self _updateTitleViewesWithAnimation:NO exceptView:nil];
        [self didChangeValueForKey:@"selectedTabIndex"];
        [_delegate tabViewController:self didRemoveTabItem:tabItemViewController];
        [tabItemViewController release];
    }
}

- (NSUInteger)tabCount
{
    return [self.mutableTabControllers count];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.view) {
        [self _updateTitleViewesWithAnimation:NO exceptView:nil];
    } else if ([object isKindOfClass:[MHTabItemViewController class]]) {
        NSUInteger index;
        
        index = [self.mutableTabControllers indexOfObject:object];
        NSAssert(index != NSNotFound, @"unknown tab");
        [[self.tabTitleViewes objectAtIndex:index] setStringValue:[object title]];
        [[self.tabTitleViewes objectAtIndex:index] setNeedsDisplay:YES];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSUInteger)selectedTabIndex
{
    return _selectedTabIndex;
}

- (void)setSelectedTabIndex:(NSUInteger)index
{
    if (index != _selectedTabIndex) {
        [self willChangeValueForKey:@"selectedTabIndex"];
        [self _removeCurrentTabItemViewController];
        [self _tabItemViewControllerWithIndex:index];
        [self didChangeValueForKey:@"selectedTabIndex"];
    }
}

- (void)selectTabItemViewController:(MHTabItemViewController *)tabItemViewController
{
    NSInteger index;
    
    index = [self.mutableTabControllers indexOfObject:tabItemViewController];
    if (index != NSNotFound) {
        self.selectedTabIndex = index;
    }
}

- (MHTabItemViewController *)selectedTabItemViewController
{
    if (self.selectedTabIndex == NSNotFound) {
        return nil;
    } else {
        return [self.mutableTabControllers objectAtIndex:self.selectedTabIndex];
    }
}

- (MHTabItemViewController *)tabItemViewControlletAtIndex:(NSInteger)index
{
    return [self.mutableTabControllers objectAtIndex:index];
}

- (void)moveTabItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    [self.mutableTabControllers exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    [self.tabTitleViewes exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    if (fromIndex == _selectedTabIndex) {
        _selectedTabIndex = toIndex;
    } else if (toIndex == _selectedTabIndex) {
        _selectedTabIndex = fromIndex;
    }
    [self _updateTitleViewesWithAnimation:YES exceptView:[self.tabTitleViewes objectAtIndex:toIndex]];
}

- (NSArray *)tabControllers
{
    return self.mutableTabControllers;
}

@end
