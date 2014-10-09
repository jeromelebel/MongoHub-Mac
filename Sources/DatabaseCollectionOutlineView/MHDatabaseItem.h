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
    NSMutableArray                      *_collectionItems;
}

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, assign) MHClientItem *clientItem;
@property (nonatomic, readonly, retain) NSArray *collectionItems;
@property (nonatomic, readonly, strong) MODDatabase *database;

- (instancetype)initWithClientItem:(MHClientItem *)serverItem database:(MODDatabase *)database;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (MHCollectionItem *)collectionItemWithName:(NSString *)databaseName;
- (void)removeCollectionItemWithName:(NSString *)name;

@end
