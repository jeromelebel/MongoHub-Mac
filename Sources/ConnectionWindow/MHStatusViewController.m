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
#import "MHConnectionStore.h"

@interface MHStatusViewController ()
@property (nonatomic, readwrite, strong) MODClient *client;
@property (nonatomic, readwrite, strong) MHResultsOutlineViewController *resultsOutlineViewController;
@property (nonatomic, readwrite, strong) MHConnectionStore *connectionStore;
@property (nonatomic, readwrite, assign) IBOutlet NSOutlineView *outlineView;

@end

@implementation MHStatusViewController

@synthesize client = _client;
@synthesize resultsOutlineViewController = _resultsOutlineViewController;
@synthesize connectionStore = _connectionStore;
@synthesize outlineView = _outlineView;

- (instancetype)initWithClient:(MODClient *)client connectionStore:(MHConnectionStore *)connectionStore
{
    self = [super init];
    if (self) {
        self.client = client;
        self.connectionStore = connectionStore;
    }
    return self;
}

- (void)dealloc
{
    self.client = nil;
    self.resultsOutlineViewController = nil;
    self.connectionStore = nil;
    [super dealloc];
}

- (NSString *)nibName
{
    return @"MHStatusView";
}

- (void)awakeFromNib
{
    self.resultsOutlineViewController = [[[MHResultsOutlineViewController alloc] initWithOutlineView:self.outlineView] autorelease];
}

- (MODQuery *)showServerStatus
{
    MODQuery *result;
    
    self.title = @"Server Stats";
    result = [self.client serverStatusWithReadPreferences:nil callback:^(MODSortedDictionary *serverStatus, MODQuery *mongoQuery) {
        if (self.client == mongoQuery.owner) {
            if (mongoQuery.error) {
                self.resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else if (serverStatus) {
                self.resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:serverStatus jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
            } else {
                self.resultsOutlineViewController.results = [NSArray array];
            }
        }
    }];
    return result;
}

- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem
{
    MODQuery *result = nil;
    
    if (databaseItem) {
        self.title = [NSString stringWithFormat:@"%@ Stats", databaseItem.name];
        
        result = [databaseItem.database statsWithReadPreferences:nil callback:^(MODSortedDictionary *databaseStats, MODQuery *mongoQuery) {
            if (databaseStats) {
                self.resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:databaseStats jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
            } else if (mongoQuery.error) {
                self.resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else {
                self.resultsOutlineViewController.results = [NSArray array];
            }
        }];
    }
    return result;
}

- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem
{
    MODQuery *result = nil;
    
    if (collectionItem) {
        self.title = [NSString stringWithFormat:@"%@ Stats", collectionItem.collection.absoluteName];
        result = [collectionItem.collection statsWithCallback:^(MODSortedDictionary *stats, MODQuery *mongoQuery) {
            if (stats) {
                self.resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:stats jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
            } else if (mongoQuery.error) {
                self.resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else {
                self.resultsOutlineViewController.results = [NSArray array];
            }
        }];
    }
    return result;
}

@end
