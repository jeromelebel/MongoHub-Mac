//
//  MHClientItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import <Foundation/Foundation.h>

@class MODClient;
@class MHDatabaseItem;
@class MHCollectionItem;
@class MODDatabase;
@class MODCollection;

@interface MHClientItem : NSObject
{
    MODClient                       *_client;
    NSMutableArray                  *_databaseItems;
}

@property (nonatomic, readonly, retain) MODClient *client;
@property (nonatomic, readonly, retain) NSArray *databaseItems;

- (instancetype)initWithClient:(MODClient *)client;
- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (void)removeDatabaseItemWithName:(NSString *)databaseName;

@end
