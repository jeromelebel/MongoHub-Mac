//
//  MHConnectionViewItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "MHConnectionIconView.h"

@class MHConnectionViewItem;

@protocol MHConnectionViewItemDelegate <NSObject>
- (void)connectionViewItemDelegateOpen:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegateEdit:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegateDuplicate:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegateCopyURL:(MHConnectionViewItem *)connectionViewItem;
- (void)connectionViewItemDelegateDelete:(MHConnectionViewItem *)connectionViewItem;

@end

@interface MHConnectionViewItem : NSCollectionViewItem
{
    id<MHConnectionViewItemDelegate>                _delegate;
}
@property (nonatomic, readwrite, assign) id<MHConnectionViewItemDelegate> delegate;
@end

@interface MHConnectionViewItem (MHConnectionIconViewDelegate) <MHConnectionIconViewDelegate>
@end
