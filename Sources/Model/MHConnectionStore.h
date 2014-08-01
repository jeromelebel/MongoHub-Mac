//
//  MHConnectionStore.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <mongo-objc-driver/MOD_public.h>

@interface MHConnectionStore : NSManagedObject
{
}

- (NSArray *)queryHistoryWithDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName;
- (void)addNewQuery:(NSDictionary *)query withDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName;

@property (nonatomic, retain) NSString *servers;
@property (nonatomic, retain) NSString *repl_name;
@property (nonatomic, retain) NSString *alias;
@property (nonatomic, retain) NSString *adminuser;
@property (nonatomic, retain) NSString *adminpass;
@property (nonatomic, retain) NSString *defaultdb;
@property (nonatomic, retain) NSNumber *usessl;
@property (nonatomic, retain) NSNumber *usessh;
@property (nonatomic, retain) NSString *sshhost;
@property (nonatomic, retain) NSNumber *sshport;
@property (nonatomic, retain) NSString *sshuser;
@property (nonatomic, retain) NSString *sshpassword;
@property (nonatomic, retain) NSString *sshkeyfile;
@property (nonatomic, retain) NSString *bindaddress;
@property (nonatomic, retain) NSNumber *bindport;
@property (nonatomic, retain) NSNumber *userepl;
@property (nonatomic, assign) MODReadPreferencesReadMode defaultReadMode;

@end
