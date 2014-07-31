//
//  MHKeychain.m
//  MongoHub
//
//  Created by Jérôme Lebel on 25/10/2013.
//  Copyright (c) 2013 ThePeppersStudio.COM. All rights reserved.
//

#import "MHKeychain.h"
#import <Security/Security.h>

@implementation MHKeychain

+ (NSMutableDictionary *)queryForHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port password:(NSString *)password
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
    [query setObject:(id)kSecClassInternetPassword forKey:(id)kSecClass];
    if (account)
        [query setObject:account forKey:(id)kSecAttrAccount];
    if (protocol)
        [query setObject:@"mongo" forKey:(id)kSecAttrProtocol];
    if (host)
        [query setObject:host forKey:(id)kSecAttrServer];
    if (port)
        [query setObject:[NSNumber numberWithUnsignedInteger:port] forKey:(id)kSecAttrPort];
    if (password) {
        [query setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        if (account) {
            [query setObject:[NSString stringWithFormat:@"%@ (%@)", host, account] forKey:(id)kSecAttrLabel];
        } else {
            [query setObject:host forKey:(id)kSecAttrLabel];
        }
    }
    
    return [query autorelease];
}

+ (BOOL)addItemWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port password:(NSString *)password
{
    NSDictionary *query;
    OSErr status = 0;
    
    query = [self queryForHost:host account:account protocol:protocol port:port password:password];
    
    status = SecItemAdd((CFDictionaryRef)query, NULL);
    if (status != 0) {
        NSLog(@"Error getting item: %d for service: %@, account: %@\n", (int)status, host, account);
    }
    
    return !status;
}

+ (NSString *)passwordWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port name:(NSString *)name
{
    NSMutableDictionary *query;
    CFTypeRef result;
    OSErr status;
    
    query = [self queryForHost:host account:account protocol:protocol port:port password:nil];
    [query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status != noErr) {
        return nil;
    } else {
        return [[[NSString alloc] initWithUTF8String:[(NSData *)result bytes]] autorelease];
    }
}

+ (BOOL)updateItemWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port name:(NSString *)name password:(NSString *)password
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForHost:host account:account protocol:protocol port:port password:password];
    
    status = SecItemUpdate((CFDictionaryRef)query, NULL);
    if (status != 0) {
        NSLog(@"Error updating item: %d for %@ %@ %@\n", (int)status, host, account, name);
    }
    
    return !status;
}

+ (NSString *)deleteItemWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port name:(NSString *)name
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForHost:host account:account protocol:protocol port:port password:nil];
    
    status = SecItemDelete((CFDictionaryRef)query);
    if (status != 0) {
        NSLog(@"Error deleting item: %d for %@ %@ %@\n", (int)status, host, account, name);
    }
    
    return !status;
}

@end
