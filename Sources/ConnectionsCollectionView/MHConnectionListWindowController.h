//
//  MHConnectionListWindowController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 09/04/2015.
//
//

#import <Cocoa/Cocoa.h>
#import "MHConnectionCollectionView.h"
#import "MHConnectionEditorWindowController.h"

@interface MHConnectionListWindowController : NSWindowController

@end

@interface MHConnectionListWindowController (MHConnectionViewItemDelegate) <MHConnectionCollectionViewDelegate>
@end

@interface MHConnectionListWindowController (MHConnectionEditorWindowControllerDelegate) <MHConnectionEditorWindowControllerDelegate>
@end
