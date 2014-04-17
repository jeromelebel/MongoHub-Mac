//
//  MHServerItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import <Foundation/Foundation.h>

@class MODServer;
@class MHDatabaseItem;
@class MHCollectionItem;

@protocol MHServerItemDelegate <NSObject>
- (id)mongoDatabaseWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (id)mongoCollectionWithCollectionItem:(MHCollectionItem *)collectionItem;
@end

@interface MHServerItem : NSObject
{
    MODServer *_mongoServer;
    NSMutableArray *_databaseItems;
    id<MHServerItemDelegate> _delegate;
}

@property (nonatomic, readonly, retain) MODServer *mongoServer;
@property (nonatomic, readonly, retain) NSArray *databaseItems;
@property (nonatomic, readonly, assign) id<MHServerItemDelegate> delegate;

- (id)initWithMongoServer:(MODServer *)mongoServer delegate:(id)delegate;
- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (void)removeDatabaseItemWithName:(NSString *)databaseName;

@end
