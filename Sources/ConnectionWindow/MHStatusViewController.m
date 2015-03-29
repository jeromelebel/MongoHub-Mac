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
#import "MODHelper.h"
#import "MHConnectionStore.h"
#import "MHDocumentOutlineViewController.h"

@interface MHStatusViewController ()
@property (nonatomic, readwrite, strong) MODClient *client;
@property (nonatomic, readwrite, strong) MHConnectionStore *connectionStore;
@property (nonatomic, readwrite, weak) IBOutlet MHDocumentOutlineViewController *documentOutlineViewController;

@end

@implementation MHStatusViewController

@synthesize client = _client;
@synthesize connectionStore = _connectionStore;
@synthesize documentOutlineViewController = _documentOutlineViewController;

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
    self.connectionStore = nil;
    [super dealloc];
}

- (NSString *)nibName
{
    return @"MHStatusView";
}

- (void)awakeFromNib
{
    [MHDocumentOutlineViewController addDocumentOutlineViewController:self.documentOutlineViewController intoView:self.view];
}

- (MODQuery *)showServerStatus
{
    MODQuery *result;
    
    self.title = @"Server Stats";
    result = [self.client serverStatusWithReadPreferences:nil callback:^(MODSortedDictionary *serverStatus, MODQuery *mongoQuery) {
        if (self.client == mongoQuery.owner) {
            NSArray *documents = nil;
            
            if (mongoQuery.error) {
                documents = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else if (serverStatus) {
                documents = [MODHelper convertForOutlineWithObject:serverStatus jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
            } else {
                documents = [NSArray array];
            }
            [self.documentOutlineViewController displayDocuments:documents withLabel:nil];
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
            NSArray *documents = nil;
            
            if (databaseStats) {
                documents = [MODHelper convertForOutlineWithObject:databaseStats jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
            } else if (mongoQuery.error) {
                documents = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else {
                documents = [NSArray array];
            }
            [self.documentOutlineViewController displayDocuments:documents withLabel:nil];
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
            NSArray *documents = nil;
            
            if (stats) {
                documents = [MODHelper convertForOutlineWithObject:stats jsonKeySortOrder:self.connectionStore.jsonKeySortOrderInSearch];
            } else if (mongoQuery.error) {
                documents = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[mongoQuery.error localizedDescription], @"value", @"error", @"name", nil]];
            } else {
                documents = [NSArray array];
            }
            [self.documentOutlineViewController displayDocuments:documents withLabel:nil];
        }];
    }
    return result;
}

@end
