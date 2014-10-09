//
//  MHDatabaseItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import "MHDatabaseItem.h"
#import "MHClientItem.h"
#import "MHCollectionItem.h"
#import <MongoObjCDriver/MongoObjCDriver.h>

@interface MHDatabaseItem ()
@property (nonatomic, readwrite, assign) MHClientItem *clientItem;
@property (nonatomic, readwrite, strong) MODDatabase *database;

@end

@implementation MHDatabaseItem

@synthesize clientItem = _clientItem;
@synthesize database = _database;
@synthesize collectionItems = _collectionItems;

- (instancetype)initWithClientItem:(MHClientItem *)clientItem database:(MODDatabase *)database
{
    NSParameterAssert(clientItem);
    NSParameterAssert(database);
    if (self = [self init]) {
        self.clientItem = clientItem;
        self.database = database;
        _collectionItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.database = nil;
    self.clientItem = nil;
    [_collectionItems release];
    [super dealloc];
}

- (NSString *)name
{
    return self.database.name;
}

- (void)removeCollectionItemWithName:(NSString *)name
{
    NSInteger ii = 0;
    
    for (MHCollectionItem *collectionItem in _collectionItems) {
        if ([collectionItem.name isEqualToString:name]) {
            [_collectionItems removeObjectAtIndex:ii];
            break;
        }
        ii++;
    }
}

- (MHCollectionItem *)collectionItemWithName:(NSString *)name
{
    MHCollectionItem *result = nil;
    
    for (MHCollectionItem *collectionItem in _collectionItems) {
        if ([collectionItem.name isEqualToString:name]) {
            result = collectionItem;
        }
    }
    return result;
}

static NSInteger collectionItemSortFunction(id element1, id element2, void *context)
{
    return [[element1 name] compare:[element2 name] options:0];
}

- (BOOL)updateChildrenWithList:(NSArray *)list
{
    BOOL result = NO;
    NSArray *oldCollectionList;
    
    oldCollectionList = [_collectionItems copy];
    if (!self.database.dropped) {
        for (NSString *collectionName in list) {
            MHCollectionItem *collectionItem;
            
            collectionItem = [self collectionItemWithName:collectionName];
            if (!collectionItem) {
                collectionItem = [[MHCollectionItem alloc] initWithDatabaseItem:self collection:[self.database collectionForName:collectionName]];
                [_collectionItems addObject:collectionItem];
                [collectionItem release];
                result = YES;
            }
        }
    }
    for (MHCollectionItem *oldCollectionItem in oldCollectionList) {
        if ([list indexOfObject:oldCollectionItem.name] == NSNotFound) {
            [self removeCollectionItemWithName:oldCollectionItem.name];
            result = YES;
        }
    }
    [_collectionItems sortUsingFunction:collectionItemSortFunction context:NULL];
    [oldCollectionList release];
    return result;
}

@end
