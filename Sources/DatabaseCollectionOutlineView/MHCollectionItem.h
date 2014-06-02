//
//  MHCollectionItem.h
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import <Foundation/Foundation.h>

@class MHDatabaseItem;
@class MODCollection;

@interface MHCollectionItem : NSObject
{
    NSString                            *_name;
    MHDatabaseItem                      *_databaseItem;
}

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, assign) MHDatabaseItem *databaseItem;
@property (nonatomic, readonly, assign) MODCollection *collection;

- (id)initWithDatabaseItem:(MHDatabaseItem *)databaseItem name:(NSString *)name;

@end
