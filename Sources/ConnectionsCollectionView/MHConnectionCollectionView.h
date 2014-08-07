//
//  MHConnectionCollectionView.h
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import <Cocoa/Cocoa.h>

@class MHConnectionCollectionView;
@class MHConnectionViewItem;

@protocol MHConnectionCollectionViewDelegate <NSCollectionViewDelegate>
- (void)connectionViewItemDelegateNewItem:(MHConnectionCollectionView *)connectionCollectionView;
- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView openItem:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView editItem:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView duplicateItem:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView copyURLItem:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView deleteItem:(MHConnectionViewItem *)connectionViewItem;

@end

@interface MHConnectionCollectionView : NSCollectionView
@property (nonatomic, readwrite, assign) NSSize itemSize;

- (void)newItem;
- (void)openItem:(MHConnectionViewItem *)item;
- (void)editItem:(MHConnectionViewItem *)item;
- (void)duplicateItem:(MHConnectionViewItem *)item;
- (void)copyURLItem:(MHConnectionViewItem *)item;
- (void)deleteItem:(MHConnectionViewItem *)item;

@end
