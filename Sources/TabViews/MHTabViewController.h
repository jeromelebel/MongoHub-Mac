//
//  MHTabViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//  Copyright (c) 2011 fotonauts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MHTabTitleView, MHTabItemViewController, MHTabViewController, MHTabTitleContainerView;

@protocol MHTabViewControllerDelegate <NSObject>
- (void)tabViewController:(MHTabViewController *)tabViewController didRemoveTabItem:(MHTabItemViewController *)tabItemViewController;
@end

@interface MHTabViewController : NSViewController
{
    NSView                                      *_selectedTabView;
    NSUInteger                                  _selectedTabIndex;
    id<MHTabViewControllerDelegate>             _delegate;
}

@property (nonatomic, readwrite, weak) IBOutlet id<MHTabViewControllerDelegate> delegate;

- (void)addTabItemViewController:(MHTabItemViewController *)tabItemViewController;
- (void)removeTabItemViewController:(MHTabItemViewController *)tabItemViewController;
- (void)selectTabItemViewController:(MHTabItemViewController *)tabItemViewController;
- (MHTabItemViewController *)tabItemViewControlletAtIndex:(NSInteger)index;
- (void)moveTabItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (NSUInteger)tabCount;
- (MHTabItemViewController *)selectedTabItemViewController;
- (NSUInteger)selectedTabIndex;
- (void)setSelectedTabIndex:(NSUInteger)index;
- (NSArray *)tabControllers;

@end
