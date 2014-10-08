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

@interface MHStatusViewController ()
@property (nonatomic, retain, readwrite) MODClient *client;
@property (nonatomic, retain, readwrite) MHResultsOutlineViewController *resultsOutlineViewController;
@property (nonatomic, assign, readwrite) IBOutlet NSOutlineView *outlineView;

@end

@implementation MHStatusViewController

@synthesize client = _client;
@synthesize resultsOutlineViewController = _resultsOutlineViewController;
@synthesize outlineView = _outlineView;

- (id)initWithClient:(MODClient *)client
{
    self = [super init];
    if (self) {
        self.client = client;
    }
    return self;
}

- (void)dealloc
{
    self.client = nil;
    self.resultsOutlineViewController = nil;
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
    
    self.title = @"Server stats";
    result = [self.client serverStatusWithReadPreferences:nil callback:^(MODSortedMutableDictionary *serverStatus, MODQuery *mongoQuery) {
        if (self.client == mongoQuery.owner) {
            if (mongoQuery.error) {
                self.resultsOutlineViewController.results = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else if (serverStatus) {
                self.resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:serverStatus];
            } else {
                self.resultsOutlineViewController.results = [NSArray array];
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
                self.resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:databaseStats];
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
        self.title = [NSString stringWithFormat:@"Collection %@.%@ stats", collectionItem.databaseItem.name, collectionItem.name];
        result = [collectionItem.collection statsWithCallback:^(MODSortedMutableDictionary *stats, MODQuery *mongoQuery) {
            if (stats) {
                self.resultsOutlineViewController.results = [MODHelper convertForOutlineWithObject:stats];
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
