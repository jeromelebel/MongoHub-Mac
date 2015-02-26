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
    // database created but empty (so not yet in the server)
    NSMutableArray                  *_extraDatabaseNames;
}

@property (nonatomic, readonly, strong) MODClient *client;
@property (nonatomic, readonly, strong) NSArray *databaseItems;

- (instancetype)initWithClient:(MODClient *)client;
- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (void)addExtraDatabaseName:(NSString *)databaseName;
- (void)removeExtraDatabaseName:(NSString *)databaseName;

@end
