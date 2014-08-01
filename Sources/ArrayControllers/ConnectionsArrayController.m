//
//  ConnectionsArrayController.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "ConnectionsArrayController.h"


@implementation ConnectionsArrayController

- (void)awakeFromNib
{
    if ([NSArrayController instancesRespondToSelector:@selector(awakeFromNib)]) {
        [super awakeFromNib];
    }
    [self setClearsFilterPredicateOnInsertion:NO];
}

- (void)remove:(id)sender
{
    if (![self selectedObjects]){
        return;
    }
    [super remove:sender];
}

- (BOOL)checkDuplicate:(NSString *)alias
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alias=%@", alias];
    if ([[self itemsUsingFetchPredicate:predicate] count]>0) {
        return YES;
    }else {
        return NO;
    }
}

- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate
{
    NSError *error = nil;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:[self entityName]
                                   inManagedObjectContext:[self managedObjectContext]]];
    NSArray *objects = [[self managedObjectContext]  
                        executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Fetch error! In AWViewPositionArrayController:itemsUseingFetchPredicate");
    }
    return [objects filteredArrayUsingPredicate:fetchPredicate];
}

@end
