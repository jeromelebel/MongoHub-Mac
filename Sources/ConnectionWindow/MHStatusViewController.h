//
//  MHStatusViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 02/12/2011.
//

#import "MHTabItemViewController.h"

@class MHDocumentOutlineViewController;
@class MODClient;
@class MHDatabaseItem;
@class MHCollectionItem;
@class MODQuery;
@class MHConnectionStore;

@interface MHStatusViewController : MHTabItemViewController
{
    MODClient                                   *_client;
    MHConnectionStore                           *_connectionStore;
    MHDocumentOutlineViewController             *_documentOutlineViewController;
}

@property (nonatomic, readonly, strong) MODClient *client;
@property (nonatomic, readonly, strong) MHConnectionStore *connectionStore;

- (instancetype)initWithClient:(MODClient *)client connectionStore:(MHConnectionStore *)connectionStore;

- (MODQuery *)showServerStatus;
- (MODQuery *)showDatabaseStatusWithDatabaseItem:(MHDatabaseItem *)databaseItem;
- (MODQuery *)showCollectionStatusWithCollectionItem:(MHCollectionItem *)collectionItem;

@end
