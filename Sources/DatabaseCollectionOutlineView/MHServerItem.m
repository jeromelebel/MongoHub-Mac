//
//  MHServerItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import "MHServerItem.h"
#import "MHDatabaseItem.h"

@interface MHServerItem ()

@property (nonatomic, readwrite, retain) MODClient *client;
@property (nonatomic, readwrite, retain) NSMutableArray *databaseItems;
@property (nonatomic, readwrite, assign) id<MHServerItemDelegate> delegate;

@end

@implementation MHServerItem

@synthesize client = _client, databaseItems = _databaseItems, delegate = _delegate;

- (id)initWithClient:(MODClient *)client delegate:(id)delegate
{
    if (self = [self init]) {
        self.delegate = delegate;
        self.client = client;
        self.databaseItems = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.client = nil;
    self.databaseItems = nil;
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

- (void)removeDatabaseItemWithName:(NSString *)databaseName
{
    NSInteger ii = 0;
    
    for (MHDatabaseItem *databaseItem in self.databaseItems) {
        if ([[databaseItem name] isEqualToString:databaseName]) {
            [(NSMutableArray *)self.databaseItems removeObjectAtIndex:ii];
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
    
    oldDatabases = [self.databaseItems copy];
    for (NSString *databaseName in list) {
        MHDatabaseItem *databaseItem;
        
        databaseItem = [self databaseItemWithName:databaseName];
        if (!databaseItem) {
            databaseItem = [[MHDatabaseItem alloc] initWithServerItem:self name:databaseName];
            [(NSMutableArray *)self.databaseItems addObject:databaseItem];
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
    [(NSMutableArray *)self.databaseItems sortUsingFunction:databaseItemSortFunction context:NULL];
    [oldDatabases release];
    return result;
}

@end
