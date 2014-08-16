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
    NSView *_selectedTabView;
    MHTabTitleContainerView *_tabContainerView;
    NSMutableArray *_tabControllers;
    NSMutableArray *_tabTitleViewes;
    NSUInteger _selectedTabIndex;
    IBOutlet id<MHTabViewControllerDelegate> _delegate;
}

@property (nonatomic, assign, readwrite) NSUInteger selectedTabIndex;
@property (nonatomic, assign, readonly) NSUInteger tabCount;
@property (nonatomic, assign, readonly) NSArray *tabControllers;
@property (nonatomic, assign, readonly) MHTabItemViewController *selectedTabItemViewController;
@property (nonatomic, assign, readwrite) id<MHTabViewControllerDelegate> delegate;

- (void)addTabItemViewController:(MHTabItemViewController *)tabItemViewController;
- (void)removeTabItemViewController:(MHTabItemViewController *)tabItemViewController;
- (void)selectTabItemViewController:(MHTabItemViewController *)tabItemViewController;
- (MHTabItemViewController *)tabItemViewControlletAtIndex:(NSInteger)index;
- (void)moveTabItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
