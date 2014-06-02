//
//  MHServerItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import <Foundation/Foundation.h>

@class MODClient;
@class MHDatabaseItem;
@class MHCollectionItem;

@protocol MHServerItemDelegate <NSObject>
- (id)mongoDatabaseWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (id)mongoCollectionWithCollectionItem:(MHCollectionItem *)collectionItem;
@end

@interface MHServerItem : NSObject
{
    MODClient *_mongoServer;
    NSMutableArray *_databaseItems;
    id<MHServerItemDelegate> _delegate;
}

@property (nonatomic, readonly, retain) MODClient *mongoServer;
@property (nonatomic, readonly, retain) NSArray *databaseItems;
@property (nonatomic, readonly, assign) id<MHServerItemDelegate> delegate;

- (id)initWithMongoServer:(MODClient *)mongoServer delegate:(id)delegate;
- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (void)removeDatabaseItemWithName:(NSString *)databaseName;

@end
