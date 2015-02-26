//
//  MHClientItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/2011.
//

#import "MHClientItem.h"
#import "MHDatabaseItem.h"
#import <MongoObjcDriver/MongoObjcDriver.h>

@interface MHClientItem ()

@property (nonatomic, readwrite, strong) MODClient *client;
@property (nonatomic, readwrite, strong) NSMutableArray *databaseItems;
@property (nonatomic, readwrite, strong) NSMutableArray *extraDatabaseNames;

@end

@implementation MHClientItem

@synthesize client = _client, databaseItems = _databaseItems;

- (instancetype)initWithClient:(MODClient *)client
{
    NSParameterAssert(client);
    if (self = [self init]) {
        self.client = client;
        self.databaseItems = [NSMutableArray array];
        self.extraDatabaseNames = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.client = nil;
    self.databaseItems = nil;
    self.extraDatabaseNames = nil;
    [super dealloc];
}

- (MHDatabaseItem *)databaseItemWithName:(NSString *)databaseName
{
    MHDatabaseItem *result = nil;
    
    for (MHDatabaseItem *databaseItem in self.databaseItems) {
        if ([[databaseItem name] isEqualToString:databaseName]) {
            result = databaseItem;
            break;
        }
    }
    return result;
}

- (void)_removeDatabaseItemWithName:(NSString *)databaseName
{
    NSInteger ii = 0;
    
    for (MHDatabaseItem *databaseItem in self.databaseItems) {
        if ([[databaseItem name] isEqualToString:databaseName]) {
            [(NSMutableArray *)self.databaseItems removeObjectAtIndex:ii];
            break;
        }
        ii++;
    }
    [self.extraDatabaseNames removeObject:databaseName];
}

static NSInteger databaseItemSortFunction(id element1, id element2, void *context)
{
    return [[element1 name] compare:[element2 name] options:0];
}

- (MHDatabaseItem *)_addNewDatabaseWithName:(NSString *)databaseName
{
    MHDatabaseItem *databaseItem;
    
    databaseItem = [[MHDatabaseItem alloc] initWithClientItem:self database:[self.client databaseForName:databaseName]];
    [(NSMutableArray *)self.databaseItems addObject:databaseItem];
    [databaseItem release];
    return databaseItem;
}

- (BOOL)updateChildrenWithList:(NSArray *)list
{
    NSArray *oldDatabases;
    BOOL databaseListUpdated = NO;
    
    oldDatabases = [self.databaseItems copy];
    for (NSString *databaseName in list) {
        MHDatabaseItem *databaseItem;
        
        databaseItem = [self databaseItemWithName:databaseName];
        if (databaseItem != nil) {
            databaseItem.temporary = NO;
        } else {
            [self _addNewDatabaseWithName:databaseName];
            databaseListUpdated = YES;
        }
        [self.extraDatabaseNames removeObject:databaseName];
    }
    for (NSString *databaseName in self.extraDatabaseNames) {
        if ([self databaseItemWithName:databaseName] == nil) {
            MHDatabaseItem *databaseItem;
            
            databaseItem = [self _addNewDatabaseWithName:databaseName];
            databaseItem.temporary = YES;
            databaseListUpdated = YES;
        }
    }
    for (MHDatabaseItem *databaseItem in oldDatabases) {
        if ([list indexOfObject:databaseItem.name] == NSNotFound && [self.extraDatabaseNames indexOfObject:databaseItem.name] == NSNotFound) {
            [self _removeDatabaseItemWithName:databaseItem.name];
            databaseListUpdated = YES;
        }
    }
    [(NSMutableArray *)self.databaseItems sortUsingFunction:databaseItemSortFunction context:NULL];
    [oldDatabases release];
    return databaseListUpdated;
}

- (void)addExtraDatabaseName:(NSString *)databaseName
{
    if (![self.extraDatabaseNames containsObject:databaseName]) {
        [self.extraDatabaseNames addObject:databaseName];
    }
}

- (void)removeExtraDatabaseName:(NSString *)databaseName
{
    [self.extraDatabaseNames removeObject:databaseName];
}

@end
