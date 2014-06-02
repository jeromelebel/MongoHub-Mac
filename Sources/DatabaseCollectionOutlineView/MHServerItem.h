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
@class MODDatabase;
@class MODCollection;

@protocol MHServerItemDelegate <NSObject>
- (MODDatabase *)databaseWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODCollection *)collectionWithCollectionItem:(MHCollectionItem *)collectionItem;
@end

@interface MHServerItem : NSObject
{
    MODClient                       *_client;
    NSMutableArray                  *_databaseItems;
    id<MHServerItemDelegate>        _delegate;
}

@property (nonatomic, readonly, retain) MODClient *client;
@property (nonatomic, readonly, retain) NSArray *databaseItems;
@property (nonatomic, readonly, assign) id<MHServerItemDelegate> delegate;

- (id)initWithClient:(MODClient *)client delegate:(id)delegate;
- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName;
- (BOOL)updateChildrenWithList:(NSArray *)list;
- (void)removeDatabaseItemWithName:(NSString *)databaseName;

@end
