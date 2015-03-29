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
@property (nonatomic, readwrite, weak) MHClientItem *clientItem;
@property (nonatomic, readwrite, strong) MODDatabase *database;
@property (nonatomic, readwrite, strong) NSMutableArray *sortedCollectionNames;
@property (nonatomic, readwrite, strong) NSMutableDictionary *collectionItems;

@end

@implementation MHDatabaseItem

@synthesize clientItem = _clientItem;
@synthesize database = _database;
@synthesize collectionItems = _collectionItems;
@synthesize sortedCollectionNames = _sortedCollectionNames;

- (instancetype)initWithClientItem:(MHClientItem *)clientItem database:(MODDatabase *)database
{
    NSParameterAssert(clientItem);
    NSParameterAssert(database);
    if (self = [self init]) {
        self.clientItem = clientItem;
        self.database = database;
        self.collectionItems = [NSMutableDictionary dictionary];
        self.sortedCollectionNames = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.database = nil;
    self.clientItem = nil;
    self.sortedCollectionNames = nil;
    self.collectionItems = nil;
    [super dealloc];
}

- (NSString *)name
{
    return self.database.name;
}

- (void)removeCollectionItemWithName:(NSString *)name
{
    [(NSMutableDictionary *)self.collectionItems removeObjectForKey:name];
    [(NSMutableArray *)self.sortedCollectionNames removeObjectIdenticalTo:name];
}

- (MHCollectionItem *)collectionItemWithName:(NSString *)name
{
    return self.collectionItems[name];
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
                [(NSMutableDictionary *)self.collectionItems setObject:collectionItem forKey:collectionName];
                [(NSMutableArray *)self.sortedCollectionNames addObject:collectionName];
                [collectionItem release];
                result = YES;
            }
        }
    }
    for (NSString *oldCollectionName in oldCollectionList) {
        if ([list indexOfObject:oldCollectionName] == NSNotFound) {
            [self removeCollectionItemWithName:oldCollectionName];
            result = YES;
        }
    }
    [(NSMutableArray *)self.sortedCollectionNames sortUsingSelector:@selector(compare:)];
    [oldCollectionList release];
    return result;
}

@end
