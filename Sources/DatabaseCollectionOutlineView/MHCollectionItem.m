//
//  MHCollectionItem.m
//  MongoHub
//
//  Created by Jérôme Lebel on 24/10/11.
//

#import "MHCollectionItem.h"
#import "MHDatabaseItem.h"
#import "MHServerItem.h"

@interface MHCollectionItem ()

@property (nonatomic, readwrite, retain) NSString *name;

@end

@implementation MHCollectionItem

@synthesize name = _name, databaseItem = _databaseItem;

- (id)initWithDatabaseItem:(MHDatabaseItem *)databaseItem name:(NSString *)name
{
    if (self = [self init]) {
        self.name = name;
        _databaseItem = databaseItem;
    }
    return self;
}

- (void)dealloc
{
    self.name = nil;
    [super dealloc];
}

- (MODCollection *)collection
{
    return [_databaseItem.serverItem.delegate collectionWithCollectionItem:self];
}

@end
