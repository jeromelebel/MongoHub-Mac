//
//  MHMongoHubMigration6to7.m
//  MongoHub
//
//  Created by Jérôme Lebel on 25/07/2014.
//
//

#import "MHMongoHubMigration6to7.h"
#import "MHKeychain.h"
#import "MHConnectionStore.h"

@implementation MHMongoHubMigration6to7

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *destMOC = manager.destinationContext;
    MHConnectionStore *newConnection;
    NSString *password = [sourceInstance valueForKey:@"sshpassword"];
    NSString *user = [sourceInstance valueForKey:@"sshuser"];
    NSString *host;

    if ([[sourceInstance valueForKey:@"sshport"] integerValue] == 0) {
        host = [NSString stringWithFormat:@"%@", [sourceInstance valueForKey:@"sshhost"]];
    } else {
        host = [NSString stringWithFormat:@"%@:%@", [sourceInstance valueForKey:@"sshhost"], [sourceInstance valueForKey:@"sshport"]];
    }
    if (password && password.length > 0) {
        [MHKeychain addItemWithHost:host account:user protocol:@"ssh" port:[[sourceInstance valueForKey:@"sshport"] unsignedIntegerValue] password:password];
    }
    newConnection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:destMOC];
    NSArray *keys = sourceInstance.entity.attributesByName.allKeys;
    NSMutableDictionary *values = [[sourceInstance dictionaryWithValuesForKeys:keys] mutableCopy];
    [values removeObjectForKey:@"sshpassword"];
    [newConnection setValuesForKeysWithDictionary:values];
    [manager associateSourceInstance:sourceInstance withDestinationInstance:newConnection forEntityMapping:mapping];
    [values release];
    return YES;
}

@end
