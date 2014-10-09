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
    MHResultsOutlineViewController              *_resultsOutlineViewController;
    MODClient                                   *_client;
    NSOutlineView                               *_outlineView;
}

@property (nonatomic, retain, readonly) MODClient *client;

- (instancetype)initWithClient:(MODClient *)client;

- (MODQuery *)showServerStatus;
- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;

@end
