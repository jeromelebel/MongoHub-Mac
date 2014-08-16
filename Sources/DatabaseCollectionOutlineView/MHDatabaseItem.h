//
//  MHDatabaseItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import <Foundation/Foundation.h>

@class MHServerItem;
@class MHCollectionItem;
@class MODDatabase;

@interface MHDatabaseItem : NSObject
{
    MHServerItem *_serverItem;
    NSString *_name;
    NSMutableArray *_collectionItems;
    id _mongoDatabase;
}

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, assign) MHServerItem *serverItem;
@property (nonatomic, readonly, retain) NSArray *collectionItems;
@property (nonatomic, readonly, retain) MODDatabase *database;

- (id)initWithServerItem:(MHServerItem *)serverItem name:(NSString *)name;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (MHCollectionItem *)collectionItemWithName:(NSString *)databaseName;
- (void)removeCollectionItemWithName:(NSString *)name;

@end
