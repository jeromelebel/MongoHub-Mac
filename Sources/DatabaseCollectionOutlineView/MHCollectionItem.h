//
//  MHCollectionItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import <Foundation/Foundation.h>

@class MHDatabaseItem;
@class MODCollection;

@interface MHCollectionItem : NSObject
{
    MODCollection                       *_collection;
    MHDatabaseItem                      *_databaseItem;
}

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, assign) MHDatabaseItem *databaseItem;
@property (nonatomic, readonly, strong) MODCollection *collection;

- (instancetype)initWithDatabaseItem:(MHDatabaseItem *)databaseItem collection:(MODCollection *)collection;

@end
