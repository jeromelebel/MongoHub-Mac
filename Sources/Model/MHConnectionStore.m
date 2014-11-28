//
//  MHConnectionStore.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "MHConnectionStore.h"
#import "MHKeychain.h"
#import "NSString+MongoHub.h"
#import "NSDictionary+MongoHub.h"
#import "MHApplicationDelegate.h"

#define MAX_QUERY_PER_COLLECTION 20
#define QUERY_HISTORY_KEY @"query_history"
#define SORTED_TITLE_KEY @"sorted_titles"
#define QUERY_KEY @"queries"
#define MONGODB_SCHEME              @"mongodb://"

@implementation MHConnectionStore

@dynamic alias;
@dynamic servers;
@dynamic replicaSetName;
@dynamic slaveOK;
@dynamic adminUser;
@dynamic defaultDatabase;

@dynamic useSSL;
@dynamic weakCertificate;

@dynamic useSSH;
@dynamic sshHost;
@dynamic sshPort;
@dynamic sshUser;
@dynamic sshKeyFileName;
@dynamic defaultReadMode;

@synthesize adminPassword = _adminPassword;
@synthesize sshPassword = _sshPassword;

+ (NSString *)hostnameFromServer:(NSString *)server withPort:(NSInteger *)port
{
    NSArray *components;
    
    // just in case we have nil
    if (!server) {
        server = @"";
    }
    components = [server componentsSeparatedByString:@":"];
    if (port) {
        if (components.count > 1) {
            *port = [[components objectAtIndex:1] integerValue];
        } else {
            *port = 0;
        }
    }
    return [components objectAtIndex:0];
}

+ (NSString *)sortedServers:(NSString *)servers
{
    NSMutableArray *array;
    
    if (servers.length == 0) {
        servers = DEFAULT_MONGO_IP;
    }
    array = [self splitServers:servers];
    [array sortedArrayUsingSelector:@selector(compare:)];
    return [array componentsJoinedByString:@","];
}

+ (NSString *)cleanupServers:(NSString *)servers
{
    return [[self splitServers:servers] componentsJoinedByString:@","];
}

+ (NSString *)passwordForServers:(NSString *)servers username:(NSString *)username
{
    NSString *keychainServers;
    
    NSParameterAssert(username.length > 0);
    keychainServers = [self sortedServers:servers];
    return [MHKeychain passwordWithLabel:[NSString stringWithFormat:@"%@ (%@)", keychainServers, username] account:username service:keychainServers description:nil];
}

+ (NSMutableArray *)splitServers:(NSString *)servers
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *host in [servers componentsSeparatedByString:@","]) {
        host = [host stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        if (host.length > 0) {
            [array addObject:host];
        }
    }
    if (array.count == 0) {
        [array addObject:@""];
    }
    return array;
}


- (void)dealloc
{
    self.adminPassword = nil;
    self.sshPassword = nil;
    [super dealloc];
}

- (NSArray *)queryHistoryWithDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName
{
    NSString *absolute;
    NSMutableArray *result;
    NSDictionary *queries;
    
    absolute = [NSString stringWithFormat:@"%@.%@", databaseName, collectionName];
    result = [NSMutableArray array];
    @try {
        queries = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:QUERY_HISTORY_KEY] objectForKey:absolute] objectForKey:QUERY_KEY];
        for (NSString *title in [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:QUERY_HISTORY_KEY] objectForKey:absolute] objectForKey:SORTED_TITLE_KEY]) {
            [result addObject:[queries objectForKey:title]];
        }
    }
    @catch (NSException *exception) {
    }
    return result;
}

- (void)addNewQuery:(NSDictionary *)query withDatabaseName:(NSString *)databaseName collectionName:(NSString *)collectionName
{
    NSString *absolute;
    NSMutableDictionary *allHistory;
    NSMutableDictionary *queriesAndTitles;
    NSMutableArray *sortedTitles;
    NSMutableDictionary *allQueries;
    
    absolute = [[NSString alloc] initWithFormat:@"%@.%@", databaseName, collectionName];
    allHistory = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:QUERY_HISTORY_KEY] mutableCopy];
    if (allHistory == nil) {
        allHistory = [[NSMutableDictionary alloc] init];
    }
    queriesAndTitles = [[allHistory objectForKey:absolute] mutableCopy];
    if (queriesAndTitles == nil || ![queriesAndTitles isKindOfClass:[NSDictionary class]]) {
        [queriesAndTitles release];
        queriesAndTitles = [[NSMutableDictionary alloc] init];
    }
    sortedTitles = [[queriesAndTitles objectForKey:SORTED_TITLE_KEY] mutableCopy];
    allQueries = [[queriesAndTitles objectForKey:QUERY_KEY] mutableCopy];
    if (sortedTitles == nil || ![sortedTitles isKindOfClass:[NSArray class]] || allQueries == nil || ![allQueries isKindOfClass:[NSMutableDictionary class]]) {
        [sortedTitles release];
        [allQueries release];
        sortedTitles = [[NSMutableArray alloc] init];
        allQueries = [[NSMutableDictionary alloc] init];
    }
    
    while ([sortedTitles count] >= MAX_QUERY_PER_COLLECTION) {
        [allQueries removeObjectForKey:[sortedTitles lastObject]];
        [sortedTitles removeLastObject];
    }
    if ([allQueries objectForKey:[query objectForKey:@"title"]]) {
        [sortedTitles removeObject:[query objectForKey:@"title"]];
    }
    [sortedTitles insertObject:[query objectForKey:@"title"] atIndex:0];
    [allQueries setObject:query forKey:[query objectForKey:@"title"]];
    
    [queriesAndTitles setObject:sortedTitles forKey:SORTED_TITLE_KEY];
    [queriesAndTitles setObject:allQueries forKey:QUERY_KEY];
    [allHistory setObject:queriesAndTitles forKey:absolute];
    [[NSUserDefaults standardUserDefaults] setObject:allHistory forKey:QUERY_HISTORY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [absolute release];
    [allHistory release];
    [queriesAndTitles release];
    [sortedTitles release];
    [allQueries release];
}

- (BOOL)setValuesFromStringURL:(NSString *)stringURL errorMessage:(NSString **)errorMessage
{
    NSString *user = nil;
    NSString *password = nil;
    NSString *servers = nil;
    NSString *databaseName = nil;
    
    NSArray *components;
    NSArray *pathComponents;
    NSArray *serverComponents;
    NSDictionary *parameterComponents = nil;
    
    if (![stringURL hasPrefix:MONGODB_SCHEME]) {
        if (errorMessage) {
            *errorMessage = @"Unknown scheme";
        }
        return NO;
    }
    
    stringURL = [stringURL substringFromIndex:MONGODB_SCHEME.length];
    if (stringURL.length == 0) {
        if (errorMessage) {
            *errorMessage = @"Empty URL";
        }
        return NO;
    }
    
    /* first try to find the parameters */
    components = [stringURL componentsSeparatedByString:@"?"];
    if (components.count > 2) {
        if (errorMessage) {
            *errorMessage = @"More than one \"?\" in the URL";
        }
        return NO;
    } else if (components.count == 2) {
        // remove the parameters from the url
        
        parameterComponents = [[NSDictionary mh_dictionaryFromURLParameters:[components objectAtIndex:1]] mh_setKeysToLowerCase];
        stringURL = [components objectAtIndex:0];
    }
    
    pathComponents = [stringURL componentsSeparatedByString:@"/"];
    
    serverComponents = [[pathComponents objectAtIndex:0] componentsSeparatedByString:@"@"];
    if (serverComponents.count == 1) {
        servers = [serverComponents objectAtIndex:0];
    } else if (serverComponents.count == 2) {
        servers = [serverComponents objectAtIndex:1];
        if ([[serverComponents objectAtIndex:0] length] > 0) {
            NSArray *userComponents = [[serverComponents objectAtIndex:0] componentsSeparatedByString:@":"];
            
            if (userComponents.count == 1) {
                user = [userComponents objectAtIndex:0];
            } else if (userComponents.count == 2) {
                user = [userComponents objectAtIndex:0];
                password = [userComponents objectAtIndex:1];
            } else {
                if (errorMessage) {
                    *errorMessage = @"Unable to parse user and password";
                }
                return NO;
            }
        }
    } else {
        if (errorMessage) {
            *errorMessage = @"Unable to parse host name(s) and user";
        }
        return NO;
    }
    
    
    
    if (user.length == 0 && password.length != 0) {
        NSLog(@"no user found while having a password in URL: %@", stringURL);
        if (errorMessage) {
            *errorMessage = @"User name required when having a password";
        }
        return NO;
    }
    
    self.adminUser = user;
    self.servers = servers;
    self.defaultDatabase = databaseName;
    self.adminPassword = password;
    if ([parameterComponents[@"replicaset"] length] > 0) {
        self.replicaSetName = [parameterComponents objectForKey:@"replicaset"];
    }
    if ([parameterComponents[@"slaveok"] isEqualToString:@"true"]) {
        self.slaveOK = @YES;
    }
    if ([parameterComponents[@"ssl"] isEqualToString:@"true"]) {
        self.useSSL = @YES;
    }
    
    if (errorMessage) {
        *errorMessage = nil;
    }
    return YES;
}

- (NSString *)sshPassword
{
    if (_sshPassword) {
        return _sshPassword;
    } else if (self.sshHost.length > 0 && self.sshUser > 0) {
        return [MHKeychain internetPasswordProtocol:kSecAttrProtocolSSH host:self.sshHost port:self.sshPort.unsignedIntegerValue account:self.sshUser];
    } else {
        return nil;
    }
}

- (NSString *)adminPassword
{
    if (_adminPassword) {
        return _adminPassword;
    } else if (self.adminUser.length > 0) {
        return [self.class passwordForServers:[self.class sortedServers:self.servers] username:self.adminUser];
    } else {
        return nil;
    }
}

- (NSArray *)arrayServers
{
    return [self.class splitServers:self.servers];
}

- (void)didSave
{
    if (_sshPassword.length > 0 && self.useSSH && self.sshUser.length > 0 && self.sshHost.length > 0) {
        [MHKeychain addOrUpdateInternetPasswordWithProtocol:kSecAttrProtocolSSH host:self.sshHost port:self.sshPort.unsignedIntegerValue account:self.sshUser password:_sshPassword];
    }
    if (_adminPassword.length > 0 && self.adminUser.length > 0) {
        NSString *keychainServers;
        
        keychainServers = [self.class sortedServers:self.servers];
        [MHKeychain addOrUpdateItemWithLabel:[NSString stringWithFormat:@"%@ (%@)", keychainServers, self.adminUser] account:self.adminUser service:keychainServers description:nil password:_adminPassword];
    }
    self.adminPassword = nil;
    self.sshPassword = nil;
}

- (NSString *)stringURLWithSSHMapping:(NSDictionary *)sshMapping
{
    NSString *auth = @"";
    NSString *uri;
    NSString *servers;
    NSMutableArray *options = [NSMutableArray array];
    
    if (self.adminUser.length > 0) {
        if (self.adminPassword.length > 0) {
            auth = [NSString stringWithFormat:@"%@:%@@", self.adminUser.mh_stringByEscapingURL, self.adminPassword.mh_stringByEscapingURL];
        } else {
            auth = [NSString stringWithFormat:@"%@@", self.adminUser.mh_stringByEscapingURL];
        }
    }
    if (!self.useSSH.boolValue || !sshMapping) {
        servers = self.servers;
    } else {
        NSMutableString *mappedIps;
        
        mappedIps = [NSMutableString string];
        for (NSString *hostnameAndPort in self.arrayServers) {
            NSNumber *bindedPort = [sshMapping objectForKey:hostnameAndPort];
            
            if (mappedIps.length > 0) {
                [mappedIps appendFormat:@",127.0.0.1:%ld", (long)bindedPort.integerValue];
            } else {
                [mappedIps appendFormat:@"127.0.0.1:%ld", (long)bindedPort.integerValue];
            }
        }
        servers = mappedIps;
    }
    if (servers.length == 0) {
        servers = DEFAULT_MONGO_IP;
    }
    if (self.useSSL.boolValue) {
        [options addObject:@"ssl=true"];
    }
    if ([(MHApplicationDelegate *)[NSApp delegate] connectTimeout] != 0) {
        [options addObject:[NSString stringWithFormat:@"connecttimeoutms=%u", [(MHApplicationDelegate *)[NSApp delegate] connectTimeout]]];
    }
    if ([(MHApplicationDelegate *)[NSApp delegate] socketTimeout]) {
        [options addObject:[NSString stringWithFormat:@"sockettimeoutms=%u", [(MHApplicationDelegate *)[NSApp delegate] socketTimeout]]];
    }
    if (self.replicaSetName.length > 0) {
        [options addObject:[NSString stringWithFormat:@"replicaSet=%@", self.replicaSetName.mh_stringByEscapingURL]];
    }
    if (self.slaveOK.boolValue) {
        [options addObject:@"slaveok=true"];
    }
    uri = [NSString stringWithFormat:@"%@%@%@/%@?%@", MONGODB_SCHEME, auth, servers, self.defaultDatabase.mh_stringByEscapingURL, [options componentsJoinedByString:@"&"]];
    return uri;
}

@end

@implementation MHConnectionStore (Preferences)

- (MHDefaultSortOrder)defaultSortOrder
{
    return MHPreferenceWindowController.defaultSortOrder;
}

- (MODJsonKeySortOrder)jsonKeySortOrderInSearch
{
    return MHPreferenceWindowController.jsonKeySortOrderInSearch;
}

@end