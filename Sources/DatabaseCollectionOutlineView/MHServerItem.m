//
//  MHServerItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import "MHServerItem.h"
#import "MHDatabaseItem.h"

@implementation MHServerItem

@synthesize mongoServer = _mongoServer, databaseItems = _databaseItems, delegate = _delegate;

- (id)initWithMongoServer:(MODClient *)mongoServer delegate:(id)delegate
{
    if (self = [self init]) {
        _delegate = delegate;
        _mongoServer = [mongoServer retain];
        _databaseItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_mongoServer release];
    [_databaseItems release];
    [super dealloc];
}

- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName
{
    MHDatabaseItem *result = nil;
    
    for (MHDatabaseItem *databaseItem in _databaseItems) {
        if ([[databaseItem name] isEqualToString:databaseName]) {
            result = databaseItem;
            break;
        }
    }
    return result;
}

- (void)removeDatabaseItemWithName:(NSString *)databaseName
{
    NSInteger ii = 0;
    
    for (MHDatabaseItem *databaseItem in _databaseItems) {
        if ([[databaseItem name] isEqualToString:databaseName]) {
            [_databaseItems removeObjectAtIndex:ii];
            break;
        }
        ii++;
    }
}

static NSInteger databaseItemSortFunction(id element1, id element2, void *context)
{
    return [[element1 name] compare:[element2 name] options:0];
}

- (BOOL)updateChildrenWithList:(NSArray *)list
{
    NSArray *oldDatabases;
    BOOL result = NO;
    
    oldDatabases = [_databaseItems copy];
    for (NSString *databaseName in list) {
        MHDatabaseItem *databaseItem;
        
        databaseItem = [self databaseItemWithName:databaseName];
        if (!databaseItem) {
            databaseItem = [[MHDatabaseItem alloc] initWithServerItem:self name:databaseName];
            [_databaseItems addObject:databaseItem];
            [databaseItem release];
            result = YES;
        }
    }
    for (MHDatabaseItem *databaseItem in oldDatabases) {
        if ([list indexOfObject:databaseItem.name] == NSNotFound) {
            [self removeDatabaseItemWithName:databaseItem.name];
            result = YES;
        }
    }
    [_databaseItems sortUsingFunction:databaseItemSortFunction context:NULL];
    [oldDatabases release];
    return result;
}

@end
