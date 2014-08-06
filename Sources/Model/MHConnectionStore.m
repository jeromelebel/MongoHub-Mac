//
//  MHConnectionStore.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "MHConnectionStore.h"
#import "MHKeychain.h"

#define MAX_QUERY_PER_COLLECTION 20
#define QUERY_HISTORY_KEY @"query_history"
#define SORTED_TITLE_KEY @"sorted_titles"
#define QUERY_KEY @"queries"
#define MONGODB_SCHEME              @"mongodb://"

@implementation MHConnectionStore

@dynamic servers;
@dynamic repl_name;
@dynamic alias;
@dynamic adminuser;
@dynamic defaultdb;
@dynamic userepl;

@dynamic usessl;
@dynamic usessh;
@dynamic sshhost;
@dynamic sshport;
@dynamic sshuser;
@dynamic sshkeyfile;
@dynamic bindaddress;
@dynamic bindport;
@dynamic defaultReadMode;

@synthesize adminpass = _adminpass;
@synthesize sshpassword = _sshpassword;

+ (NSString *)hostnameFromServer:(NSString *)server WithPort:(NSInteger *)port
{
    NSArray *components;
    
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
    NSMutableArray *array = [NSMutableArray array];
    
    if (servers.length == 0) {
        servers = DEFAULT_MONGO_IP;
    }
    for (NSString *host in [servers componentsSeparatedByString:@","]) {
        [array addObject:[host stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]];
    }
    [array sortedArrayUsingSelector:@selector(compare:)];
    return [array componentsJoinedByString:@","];
}

+ (NSString *)cleanupServers:(NSString *)servers
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *host in [servers componentsSeparatedByString:@","]) {
        [array addObject:[host stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]];
    }
    return [array componentsJoinedByString:@","];
}

+ (NSString *)passwordForServers:(NSString *)servers username:(NSString *)username
{
    NSString *keychainServers;
    
    NSParameterAssert(username.length > 0);
    keychainServers = [self sortedServers:servers];
    return [MHKeychain passwordWithLabel:[NSString stringWithFormat:@"%@ (%@)", keychainServers, username] account:username service:keychainServers description:nil];
}

- (void)dealloc
{
    self.adminpass = nil;
    self.sshpassword = nil;
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
    
    NSArray *pathComponents;
    NSArray *serverComponents;
    
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
    
    self.adminuser = user;
    self.servers = servers;
    self.defaultdb = databaseName;
    self.adminpass = password;
    
    if (errorMessage) {
        *errorMessage = nil;
    }
    return YES;
}

- (NSString *)sshpassword
{
    if (_sshpassword) {
        return _sshpassword;
    } else if (self.sshhost.length > 0 && self.sshuser > 0) {
        return [MHKeychain internetPasswordProtocol:kSecAttrProtocolSSH host:self.sshhost port:self.sshport.unsignedIntegerValue account:self.sshuser];
    } else {
        return nil;
    }
}

- (NSString *)adminpass
{
    if (_adminpass) {
        return _adminpass;
    } else if (self.adminuser.length > 0) {
        return [self.class passwordForServers:[self.class sortedServers:self.servers] username:self.adminuser];
    } else {
        return nil;
    }
}

- (NSArray *)arrayServers
{
    return [[super valueForKey:@"servers"] componentsSeparatedByString:@","];
}

- (void)didSave
{
    if (_sshpassword.length > 0 && self.usessh && self.sshuser.length > 0 && self.sshhost.length > 0) {
        [MHKeychain addOrUpdateInternetPasswordWithProtocol:kSecAttrProtocolSSH host:self.sshhost port:self.sshport.unsignedIntegerValue account:self.sshuser password:_sshpassword];
    }
    if (_adminpass.length > 0 && self.adminuser.length > 0) {
        NSString *keychainServers;
        
        keychainServers = [self.class sortedServers:self.servers];
        [MHKeychain addOrUpdateItemWithLabel:[NSString stringWithFormat:@"%@ (%@)", keychainServers, self.adminuser] account:self.adminuser service:keychainServers description:nil password:_adminpass];
    }
    self.adminpass = nil;
    self.sshpassword = nil;
}

@end
