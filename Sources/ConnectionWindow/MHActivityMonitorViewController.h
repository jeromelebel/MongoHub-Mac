//
//  MHActivityMonitorViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 20/10/2014.
//
//

#import "MHTabItemViewController.h"

@class MODClient;
@class MODSortedDictionary;
@class MODQuery;

@interface MHActivityMonitorViewController : MHTabItemViewController
{
    MODClient                               *_client;
    NSTimer                                 *_timer;
    MODSortedDictionary                     *_previousServerStatusForDelta;
    NSMutableArray                          *_data;
    MODQuery                                *_query;
    
    NSTableView                             *_tableView;
}

- (id)initWithClient:(MODClient *)client;

@end
