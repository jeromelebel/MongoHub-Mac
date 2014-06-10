//
//  MHConnectionStore.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MHConnectionStore : NSManagedObject
{
    NSString *host;
    NSNumber *hostport;
    NSString *servers;
    NSString *repl_name;
    NSString *alias;
    NSString *adminuser;
    NSString *adminpass;
    NSString *defaultdb;
    NSString *sshhost;
    NSNumber *sshport;
    NSString *sshuser;
    NSString *sshpassword;
    NSString *sshkeyfile;
    NSString *bindaddress;
    NSNumber *bindport;
    NSSet *databases;
    NSNumber *usessh;
    NSNumber *userepl;
}

- (NSArray *)queryHistoryWithDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName;
- (void)addNewQuery:(NSDictionary *)query withDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName;

@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSNumber *hostport;
@property (nonatomic, retain) NSString *servers;
@property (nonatomic, retain) NSString *repl_name;
@property (nonatomic, retain) NSString *alias;
@property (nonatomic, retain) NSString *adminuser;
@property (nonatomic, retain) NSString *adminpass;
@property (nonatomic, retain) NSString *defaultdb;
@property (nonatomic, retain) NSSet *databases;
@property (nonatomic, retain) NSString *sshhost;
@property (nonatomic, retain) NSNumber *sshport;
@property (nonatomic, retain) NSString *sshuser;
@property (nonatomic, retain) NSString *sshpassword;
@property (nonatomic, retain) NSString *sshkeyfile;
@property (nonatomic, retain) NSString *bindaddress;
@property (nonatomic, retain) NSNumber *bindport;
@property (nonatomic, retain) NSNumber *usessh;
@property (nonatomic, retain) NSNumber *userepl;
@property (nonatomic, assign) BOOL slaveOK;

@end
