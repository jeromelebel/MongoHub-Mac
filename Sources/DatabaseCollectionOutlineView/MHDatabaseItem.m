//
//  MHDatabaseItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import "MHDatabaseItem.h"
#import "MHServerItem.h"
#import "MHCollectionItem.h"

@implementation MHDatabaseItem

@synthesize name = _name, serverItem = _serverItem, collectionItems = _collectionItems;

- (id)initWithServerItem:(MHServerItem *)serverItem name:(NSString *)name
{
    if (self = [self init]) {
        _serverItem = serverItem;
        _name = [name retain];
        _collectionItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_collectionItems release];
    [_mongoDatabase release];
    [super dealloc];
}

- (id)mongoDatabase
{
    if (!_mongoDatabase) {
        _mongoDatabase = [[_serverItem.delegate mongoDatabaseWithDatabaseItem:self] retain];
    }
    return _mongoDatabase;
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
    for (NSString *name in list) {
        MHCollectionItem *collectionItem;
        
        collectionItem = [self collectionItemWithName:name];
        if (!collectionItem) {
            collectionItem = [[MHCollectionItem alloc] initWithDatabaseItem:self name:name];
            [_collectionItems addObject:collectionItem];
            [collectionItem release];
            result = YES;
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
