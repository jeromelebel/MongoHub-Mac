//
//  MHConnectionCollectionView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import "MHConnectionCollectionView.h"

@implementation MHConnectionCollectionView

- (void)openItem:(MHConnectionViewItem *)item
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegate:self openItem:item];
}

- (void)editItem:(MHConnectionViewItem *)item
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegate:self editItem:item];
}

- (void)duplicateItem:(MHConnectionViewItem *)item
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegate:self duplicateItem:item];
}

- (void)copyURLItem:(MHConnectionViewItem *)item
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegate:self copyURLItem:item];
}

- (void)deleteItem:(MHConnectionViewItem *)item
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegate:self deleteItem:item];
}

@end
