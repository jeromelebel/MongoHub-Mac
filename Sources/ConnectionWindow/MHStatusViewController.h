//
//  MHStatusViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//

#import "MHTabItemViewController.h"

@class MHResultsOutlineViewController, MODClient, MHConnectionStore, MHDatabaseItem, MHCollectionItem, MODQuery;

@interface MHStatusViewController : MHTabItemViewController
{
    IBOutlet MHResultsOutlineViewController     *_resultsOutlineViewController;
    MODClient                                   *_client;
    MHConnectionStore                           *_connectionStore;
}

@property (nonatomic, retain, readwrite) MODClient *client;
@property (nonatomic, retain, readwrite) MHConnectionStore *connectionStore;

- (MODQuery *)showServerStatus;
- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;

@end
