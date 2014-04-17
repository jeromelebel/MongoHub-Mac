//
//  MHStatusViewController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/11.
//

#import "MHStatusViewController.h"
#import "MHConnectionStore.h"
#import "MHDatabaseItem.h"
#import "MHCollectionItem.h"
#import "MOD_public.h"
#import "MHResultsOutlineViewController.h"
#import "MODHelper.h"

@implementation MHStatusViewController

@synthesize mongoServer = _mongoServer, connectionStore = _connectionStore;

+ (MHStatusViewController *)loadNewViewController
{
    return [[[MHStatusViewController alloc] initWithNibName:@"MHStatusViewController" bundle:nil] autorelease];
}

- (void)dealloc
{
    [_mongoServer release];
    [_connectionStore release];
    [super dealloc];
}

- (MODQuery *)showServerStatus
{
    MODQuery *result;
    
    self.title = @"Server stats";
    result = [_mongoServer fetchServerStatusWithCallback:^(MODSortedMutableDictionary *serverStatus, MODQuery *mongoQuery) {
        if (_mongoServer == [mongoQuery.parameters objectForKey:@"mongoserver"]) {
            if (serverStatus) {
                _resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:serverStatus];
            } else if (mongoQuery.error) {
                _resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
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
        
        result = [databaseItem.mongoDatabase fetchDatabaseStatsWithCallback:^(MODSortedMutableDictionary *databaseStats, MODQuery *mongoQuery) {
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
        result = [collectionItem.mongoCollection fetchCollectionStatsWithCallback:^(MODSortedMutableDictionary *stats, MODQuery *mongoQuery) {
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
