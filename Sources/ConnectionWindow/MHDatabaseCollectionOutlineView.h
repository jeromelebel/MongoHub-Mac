//
//  MHDatabaseCollectionOutlineView.h
//  MongoHub
//
//  Created by Jérôme Lebel on 04/10/2014.
//
//

#import <Cocoa/Cocoa.h>

@class MHDatabaseCollectionOutlineView;

@protocol MHDatabaseCollectionOutlineViewDelegate <NSObject>
- (NSMenu *)databaseCollectionOutlineView:(MHDatabaseCollectionOutlineView *)outlineView contextualMenuWithEvent:(NSEvent *)event;

@end

@interface MHDatabaseCollectionOutlineView : NSOutlineView

@end
