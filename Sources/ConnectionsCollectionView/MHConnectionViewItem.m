//
//  MHConnectionViewItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import "MHConnectionViewItem.h"
#import "MHConnectionCollectionView.h"

@interface MHConnectionViewItem ()

@end

@implementation MHConnectionViewItem

-(void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    
    MHConnectionIconView* connectionIconView = (MHConnectionIconView* )self.view;
    connectionIconView.needsDisplay = YES;
}

- (void)menuOpenAction:(id)sender
{
    [(MHConnectionCollectionView *)self.collectionView openItem:self];
}

- (void)menuEditAction:(id)sender
{
    [(MHConnectionCollectionView *)self.collectionView editItem:self];
}

- (void)menuDuplicateAction:(id)sender
{
    [(MHConnectionCollectionView *)self.collectionView duplicateItem:self];
}

- (void)menuCopyURLAction:(id)sender
{
    [(MHConnectionCollectionView *)self.collectionView copyURLItem:self];
}

- (void)menuDeleteAction:(id)sender
{
    [(MHConnectionCollectionView *)self.collectionView deleteItem:self];
}

@end

@implementation MHConnectionViewItem (MHConnectionIconViewDelegate)

- (void)connectionIconViewDoubleClick:(MHConnectionIconView *)connectionIconView
{
    [self menuOpenAction:nil];
}

- (void)connectionIconViewOpenContextualMenu:(MHConnectionIconView *)connectionIconView withEvent:(NSEvent *)event
{
    NSMenu *menu;
    
    menu = [[[NSMenu alloc] init] autorelease];
    [menu addItemWithTitle:@"Open" action:@selector(menuOpenAction:) keyEquivalent:@""].target = self;
    [menu addItemWithTitle:@"Edit…" action:@selector(menuEditAction:) keyEquivalent:@""].target = self;
    [menu addItemWithTitle:@"Duplicate…" action:@selector(menuDuplicateAction:) keyEquivalent:@""].target = self;
    [menu addItemWithTitle:@"Copy URL" action:@selector(menuCopyURLAction:) keyEquivalent:@""].target = self;
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Delete…" action:@selector(menuDeleteAction:) keyEquivalent:@""].target = self;
    [NSMenu popUpContextMenu:menu withEvent:event forView:connectionIconView];
}

@end
