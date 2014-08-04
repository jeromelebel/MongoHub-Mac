//
//  MHMongoHubMigration7to8.m
//  MongoHub
//
//  Created by Jérôme Lebel on 31/07/2014.
//
//

#import "MHMongoHubMigration7to8.h"
#import "MHKeychain.h"

@implementation MHMongoHubMigration7to8

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *destMOC = manager.destinationContext;
    NSManagedObject *newConnection;
    NSString *mainHost = [sourceInstance valueForKey:@"host"];
    NSNumber *mainHostPort = [sourceInstance valueForKey:@"hostport"];
    NSString *servers = [sourceInstance valueForKey:@"servers"];
    NSString *user = [sourceInstance valueForKey:@"adminuser"];
    NSString *password = [sourceInstance valueForKey:@"adminpass"];
    NSMutableArray *allServersArray;
    NSString *newServersValue;

    if (mainHostPort.integerValue != 0) {
        allServersArray = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@:%@", mainHost, mainHostPort], nil];
    } else {
        allServersArray = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@", mainHost], nil];
    }
    if (servers.length > 0) {
        for (NSString *host in [servers componentsSeparatedByString:@","]) {
            [allServersArray addObject:[host stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]];
        }
    }
    [allServersArray sortUsingSelector:@selector(compare:)];
    if (user.length == 0) {
        newServersValue = [allServersArray componentsJoinedByString:@","];
    } else {
        newServersValue = [allServersArray componentsJoinedByString:@","];
        if (password.length > 0) {
            [MHKeychain addOrUpdateItemWithLabel:[NSString stringWithFormat:@"%@ (%@)", newServersValue, user] account:user service:newServersValue description:nil password:password];
        }
    }
    
    newConnection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:destMOC];
    NSArray *keys = sourceInstance.entity.attributesByName.allKeys;
    NSMutableDictionary *values = [[sourceInstance dictionaryWithValuesForKeys:keys] mutableCopy];
    [values removeObjectForKey:@"host"];
    [values removeObjectForKey:@"hostport"];
    [values removeObjectForKey:@"servers"];
    [values removeObjectForKey:@"adminpass"];
    [values setObject:newServersValue forKey:@"servers"];
    [newConnection setValuesForKeysWithDictionary:values];
    [manager associateSourceInstance:sourceInstance withDestinationInstance:newConnection forEntityMapping:mapping];
    [values release];
    return YES;
}

@end
