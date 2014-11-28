//
//  MHConnectionStore.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MongoObjCDriver/MongoObjCDriver.h>
#import "MHPreferenceWindowController.h"

#define DEFAULT_MONGO_IP                            @"127.0.0.1"

@interface MHConnectionStore : NSManagedObject
{
    NSString                    *_adminPassword;
    NSString                    *_sshPassword;
}
+ (NSString *)hostnameFromServer:(NSString *)server withPort:(NSInteger *)port;
+ (NSString *)cleanupServers:(NSString *)servers;
+ (NSString *)passwordForServers:(NSString *)servers username:(NSString *)username;
+ (NSString *)sortedServers:(NSString *)servers;
+ (NSMutableArray *)splitServers:(NSString *)servers;

- (BOOL)setValuesFromStringURL:(NSString *)stringURL errorMessage:(NSString **)errorMessage;
- (NSArray *)queryHistoryWithDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName;
- (void)addNewQuery:(NSDictionary *)query withDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName;
- (NSString *)stringURLWithSSHMapping:(NSDictionary *)sshMapping;

@property (nonatomic, strong) NSString *alias;
@property (nonatomic, strong) NSString *servers;
@property (nonatomic, strong) NSString *replicaSetName;
@property (nonatomic, strong) NSNumber *slaveOK;
@property (nonatomic, strong) NSString *adminUser;
@property (nonatomic, strong) NSString *adminPassword;
@property (nonatomic, strong) NSString *defaultDatabase;

@property (nonatomic, strong) NSNumber *useSSL;
@property (nonatomic, strong) NSNumber *weakCertificate;

@property (nonatomic, strong) NSNumber *useSSH;
@property (nonatomic, strong) NSString *sshHost;
@property (nonatomic, strong) NSNumber *sshPort;
@property (nonatomic, strong) NSString *sshUser;
@property (nonatomic, strong) NSString *sshPassword;
@property (nonatomic, strong) NSString *sshKeyFileName;
@property (nonatomic, assign) MODReadPreferencesReadMode defaultReadMode;

@property (nonatomic, readonly, assign) NSArray *arrayServers;

@end

@interface MHConnectionStore (Preferences)

- (MHDefaultSortOrder)defaultSortOrder;
- (MODJsonKeySortOrder)jsonKeySortOrderInSearch;

@end