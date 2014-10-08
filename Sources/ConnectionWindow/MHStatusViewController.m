//
//  MHStatusViewController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//

#import "MHStatusViewController.h"
#import "MHDatabaseItem.h"
#import "MHCollectionItem.h"
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "MHResultsOutlineViewController.h"
#import "MODHelper.h"

@implementation MHStatusViewController

@synthesize client = _client;

- (void)dealloc
{
    self.client = nil;
    [super dealloc];
}

- (NSString *)nibName
{
    return @"MHStatusView";
}

- (MODQuery *)showServerStatus
{
    MODQuery *result;
    
    self.title = @"Server stats";
    result = [self.client serverStatusWithReadPreferences:nil callback:^(MODSortedMutableDictionary *serverStatus, MODQuery *mongoQuery) {
        if (self.client == mongoQuery.owner) {
            if (mongoQuery.error) {
                _resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else if (serverStatus) {
                _resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:serverStatus];
            } else {
                _resultsOutlineViewController.results = [NSArray array];
            }
        }
    }];
    return result;
}

- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem
{
    MODQuery *result;
    
    if (databaseItem) {
        self.title = [NSString stringWithFormat:@"Database %@ stats", databaseItem.name];
        
        result = [databaseItem.database statsWithReadPreferences:nil callback:^(MODSortedMutableDictionary *databaseStats, MODQuery *mongoQuery) {
            if (databaseStats) {
                _resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:databaseStats];
            } else if (mongoQuery.error) {
                _resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else {
                _resultsOutlineViewController.results = [NSArray array];
            }
        }];
    }
    return result;
}

- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem
{
    MODQuery *result = nil;
    
    if (collectionItem) {
        self.title = [NSString stringWithFormat:@"Collection %@.%@ stats", collectionItem.databaseItem.name, collectionItem.name];
        result = [collectionItem.collection statsWithCallback:^(MODSortedMutableDictionary *stats, MODQuery *mongoQuery) {
            if (stats) {
                _resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:stats];
            } else if (mongoQuery.error) {
                _resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else {
                _resultsOutlineViewController.results = [NSArray array];
            }
        }];
    }
    return result;
}

@end
