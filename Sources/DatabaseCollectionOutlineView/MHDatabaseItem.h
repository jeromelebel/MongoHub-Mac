//
//  MHDatabaseItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import <Foundation/Foundation.h>

@class MHClientItem;
@class MHCollectionItem;
@class MODDatabase;

@interface MHDatabaseItem : NSObject
{
    MHClientItem                        *_clientItem;
    MODDatabase                         *_database;
    NSMutableDictionary                 *_collectionItems;
    NSMutableArray                      *_sortedCollectionNames;
}

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, weak) MHClientItem *clientItem;
@property (nonatomic, readonly, strong) MODDatabase *database;
@property (nonatomic, readonly, strong) NSArray *sortedCollectionNames;
@property (nonatomic, readonly, strong) NSDictionary *collectionItems;

- (instancetype)initWithClientItem:(MHClientItem *)serverItem database:(MODDatabase *)database;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (MHCollectionItem *)collectionItemWithName:(NSString *)databaseName;
- (void)removeCollectionItemWithName:(NSString *)name;

@end
