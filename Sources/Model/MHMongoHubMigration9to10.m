//
//  MHMongoHubMigration9to10.m
//  MongoHub
//
//  Created by Jérôme Lebel on 25/08/2014.
//
//

#import "MHMongoHubMigration9to10.h"

@implementation MHMongoHubMigration9to10

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *destMOC = manager.destinationContext;
    NSManagedObject *newConnection;
    NSDictionary *convertKeys = @{ @"adminuser": @"adminUser",
                                   @"defaultdb": @"defaultDatabase",
                                   @"repl_name": @"replicaSetName",
                                   @"sshhost": @"sshHost",
                                   @"sshport": @"sshPort",
                                   @"sshuser": @"sshUser",
                                   @"usessl": @"useSSL",
                                   @"usessh": @"useSSH",
                                   @"sshkeyfile": @"sshKeyFileName" };
    
    newConnection = [NSEntityDescription insertNewObjectForEntityForName:@"Connection" inManagedObjectContext:destMOC];
    NSArray *keys = sourceInstance.entity.attributesByName.allKeys;
    NSMutableDictionary *values = [[sourceInstance dictionaryWithValuesForKeys:keys] mutableCopy];
    
    for (NSString *key in convertKeys.allKeys) {
        if (values[key]) {
            values[convertKeys[key]] = values[key];
            [values removeObjectForKey:key];
        }
    }
    [values removeObjectForKey:@"bindport"];
    [values removeObjectForKey:@"bindaddress"];
    [newConnection setValuesForKeysWithDictionary:values];
    [manager associateSourceInstance:sourceInstance withDestinationInstance:newConnection forEntityMapping:mapping];
    [values release];
    return YES;
}

@end
