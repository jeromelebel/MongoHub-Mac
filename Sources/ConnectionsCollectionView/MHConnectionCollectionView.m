//
//  MHConnectionCollectionView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import "MHConnectionCollectionView.h"

@implementation MHConnectionCollectionView

- (void)setItemSize:(NSSize)itemSize
{
    self.maxItemSize = itemSize;
    self.minItemSize = itemSize;
}

- (NSSize)itemSize
{
    return self.maxItemSize;
}

- (void)newItem
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegateNewItem:self];
}

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

- (void)openContextualMenuWithEvent:(NSEvent *)event
{
    NSMenu *menu;
    
    menu = [[[NSMenu alloc] init] autorelease];
    [menu addItemWithTitle:@"New Connection…" action:@selector(newItemAction:) keyEquivalent:@""].target = self;
    [NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    if ((event.modifierFlags & NSControlKeyMask) == NSControlKeyMask) {
        [self openContextualMenuWithEvent:event];
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    [self openContextualMenuWithEvent:event];
}

- (void)newItemAction:(id)sender
{
    [(id<MHConnectionCollectionViewDelegate>)self.delegate connectionViewItemDelegateNewItem:self];
}

@end
