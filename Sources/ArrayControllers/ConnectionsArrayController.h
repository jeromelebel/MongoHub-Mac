//
//  ConnectionsArrayController.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConnectionsArrayController : NSArrayController {

}

- (BOOL)checkDuplicate:(NSString *)alias;
- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate;

@end
