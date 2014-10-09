//
//  MHCollectionItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import "MHCollectionItem.h"
#import "MHDatabaseItem.h"
#import "MHClientItem.h"
#import <MongoObjcDriver/MongoObjcDriver.h>

@interface MHCollectionItem ()
@property (nonatomic, readwrite, strong) MODCollection *collection;
@property (nonatomic, readwrite, assign) MHDatabaseItem *databaseItem;

@end

@implementation MHCollectionItem

@synthesize collection = _collection;
@synthesize databaseItem = _databaseItem;

- (instancetype)initWithDatabaseItem:(MHDatabaseItem *)databaseItem collection:(MODCollection *)collection
{
    NSParameterAssert(databaseItem);
    NSParameterAssert(collection);
    if (self = [self init]) {
        self.collection = collection;
        self.databaseItem = databaseItem;
    }
    return self;
}

- (void)dealloc
{
    self.collection = nil;
    self.databaseItem = nil;
    [super dealloc];
}

- (NSString *)name
{
    return self.collection.name;
}

@end
