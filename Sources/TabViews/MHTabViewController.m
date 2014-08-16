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

@implementation MHTabViewController

@synthesize tabControllers = _tabControllers, delegate = _delegate;

- (void)dealloc
{
    for (MHTabItemViewController *controller in _tabControllers) {
        [controller removeObserver:self forKeyPath:@"title"];
    }
    [_tabControllers release];
    [_tabTitleViewes release];
    [_tabContainerView release];
    [self.view removeObserver:self forKeyPath:@"frame"];
    [super dealloc];
}

- (void)awakeFromNib
{
    if (_tabControllers == nil) {
        _selectedTabIndex = NSNotFound;
        _tabControllers = [[NSMutableArray alloc] init];
        _tabTitleViewes = [[NSMutableArray alloc] init];
        _tabContainerView = [[MHTabTitleContainerView alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height - TAB_HEIGHT, self.view.bounds.size.width, TAB_HEIGHT)];
        [self.view addSubview:_tabContainerView];
        [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [_tabContainerView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    }
}

- (NSRect)_rectForTabTitleAtIndex:(NSUInteger)index
{
    NSRect result;
    NSUInteger count;
    
    count = [_tabControllers count];
    result = _tabContainerView.bounds;
    result.origin.y += result.size.height - TAB_HEIGHT;
    result.size.height = TAB_HEIGHT;
    result.size.width = round(result.size.width / count);
    result.origin.x = result.size.width * index;
    return result;
}

- (void)_removeCurrentTabItemViewController
{
    [_selectedTabView removeFromSuperview];
    _selectedTabView = nil;
}

- (void)_tabItemViewControllerWithIndex:(NSInteger)index
{
    if (_selectedTabIndex != NSNotFound && _selectedTabIndex < [_tabTitleViewes count]) {
        [[_tabTitleViewes objectAtIndex:_selectedTabIndex] setNeedsDisplay:YES];
        [[_tabTitleViewes objectAtIndex:_selectedTabIndex] setSelected:NO];
    }
    _selectedTabIndex = index;
    if (_selectedTabIndex != NSNotFound) {
        NSRect rect;
        
        [[_tabTitleViewes objectAtIndex:_selectedTabIndex] setNeedsDisplay:YES];
        rect = self.view.bounds;
        _selectedTabView = [[_tabControllers objectAtIndex:_selectedTabIndex] view];
        [self.view addSubview:_selectedTabView];
        rect.size.height -= TAB_HEIGHT;
        _selectedTabView.frame = rect;
        [[_tabTitleViewes objectAtIndex:_selectedTabIndex] setSelected:YES];
    }
}

- (void)_updateTitleViewesWithAnimation:(BOOL)animation exceptView:(MHTabTitleView *)exceptView
{
    NSUInteger ii = 0;
    
    for (MHTabTitleView *titleView in _tabTitleViewes) {
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
    if ([_tabControllers indexOfObject:tabItemViewController] == NSNotFound) {
        MHTabTitleView *titleView;
        
        tabItemViewController.tabViewController = self;
        [_tabControllers addObject:tabItemViewController];
        tabItemViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        titleView = [[MHTabTitleView alloc] initWithFrame:_tabContainerView.bounds];
        titleView.tabViewController = self;
        titleView.stringValue = tabItemViewController.title;
        [_tabTitleViewes addObject:titleView];
        [_tabContainerView addSubview:titleView];
        [titleView release];
        [tabItemViewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        
        self.selectedTabIndex = [_tabControllers count] - 1;
        [self _updateTitleViewesWithAnimation:NO exceptView:nil];
    }
}

- (void)removeTabItemViewController:(MHTabItemViewController *)tabItemViewController
{
    NSUInteger index;
    
    index = [_tabControllers indexOfObject:tabItemViewController];
    if (index != NSNotFound) {
        [tabItemViewController retain];
        [self willChangeValueForKey:@"selectedTabIndex"];
        [self _removeCurrentTabItemViewController];
        [tabItemViewController removeObserver:self forKeyPath:@"title"];
        [_tabControllers removeObjectAtIndex:index];
        [[_tabTitleViewes objectAtIndex:index] removeFromSuperview];
        [_tabTitleViewes removeObjectAtIndex:index];
        if ([_tabControllers count] == 0) {
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
    return [_tabControllers count];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.view) {
        [self _updateTitleViewesWithAnimation:NO exceptView:nil];
    } else if ([object isKindOfClass:[MHTabItemViewController class]]) {
        NSUInteger index;
        
        index = [_tabControllers indexOfObject:object];
        NSAssert(index != NSNotFound, @"unknown tab");
        [[_tabTitleViewes objectAtIndex:index] setStringValue:[object title]];
        [[_tabTitleViewes objectAtIndex:index] setNeedsDisplay:YES];
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
    
    index = [_tabControllers indexOfObject:tabItemViewController];
    if (index != NSNotFound) {
        self.selectedTabIndex = index;
    }
}

- (MHTabItemViewController *)selectedTabItemViewController
{
    if (self.selectedTabIndex == NSNotFound) {
        return nil;
    } else {
        return [_tabControllers objectAtIndex:self.selectedTabIndex];
    }
}

- (MHTabItemViewController *)tabItemViewControlletAtIndex:(NSInteger)index
{
    return [_tabControllers objectAtIndex:index];
}

- (void)moveTabItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    [_tabControllers exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    [_tabTitleViewes exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    if (fromIndex == _selectedTabIndex) {
        _selectedTabIndex = toIndex;
    } else if (toIndex == _selectedTabIndex) {
        _selectedTabIndex = fromIndex;
    }
    [self _updateTitleViewesWithAnimation:YES exceptView:[_tabTitleViewes objectAtIndex:toIndex]];
}

@end
