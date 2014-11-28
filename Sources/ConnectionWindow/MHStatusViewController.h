//
//  MHStatusViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//

#import "MHTabItemViewController.h"

@class MHResultsOutlineViewController, MODClient, MHDatabaseItem, MHCollectionItem, MODQuery, MHConnectionStore;

@interface MHStatusViewController : MHTabItemViewController
{
    MHResultsOutlineViewController              *_resultsOutlineViewController;
    MODClient                                   *_client;
    MHConnectionStore                           *_connectionStore;
    NSOutlineView                               *_outlineView;
}

@property (nonatomic, readonly, strong) MODClient *client;
@property (nonatomic, readonly, strong) MHConnectionStore *connectionStore;

- (instancetype)initWithClient:(MODClient *)client connectionStore:(MHConnectionStore *)connectionStore;

- (MODQuery *)showServerStatus;
- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;

@end
