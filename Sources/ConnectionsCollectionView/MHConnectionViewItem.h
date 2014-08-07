//
//  MHConnectionViewItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "MHConnectionIconView.h"

@interface MHConnectionViewItem : NSCollectionViewItem
{
}
@end

@interface MHConnectionViewItem (MHConnectionIconViewDelegate) <MHConnectionIconViewDelegate>
@end
