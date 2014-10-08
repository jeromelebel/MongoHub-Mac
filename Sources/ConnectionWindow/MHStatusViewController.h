//
//  MHStatusViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//

#import "MHTabItemViewController.h"

@class MHResultsOutlineViewController, MODClient, MHDatabaseItem, MHCollectionItem, MODQuery;

@interface MHStatusViewController : MHTabItemViewController
{
    IBOutlet MHResultsOutlineViewController     *_resultsOutlineViewController;
    MODClient                                   *_client;
}

@property (nonatomic, retain, readonly) MODClient *client;

- (id)initWithClient:(MODClient *)client;

- (MODQuery *)showServerStatus;
- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;

@end
