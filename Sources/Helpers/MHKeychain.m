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

+ (NSMutableDictionary *)queryForClass:(CFTypeRef)itemClass label:(NSString *)label protocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
    [query setObject:itemClass forKey:(id)kSecClass];
    if (account)
        [query setObject:account forKey:(id)kSecAttrAccount];
    if (protocol)
        [query setObject:protocol forKey:(id)kSecAttrProtocol];
    if (host)
        [query setObject:host forKey:(id)kSecAttrServer];
    if (port)
        [query setObject:[NSNumber numberWithUnsignedInteger:port] forKey:(id)kSecAttrPort];
    if (password) {
        [query setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        if (label) {
            [query setObject:label forKey:(id)kSecAttrLabel];
        } else if (host && account) {
            [query setObject:[NSString stringWithFormat:@"%@ (%@)", host, account] forKey:(id)kSecAttrLabel];
        } else if (host) {
            [query setObject:host forKey:(id)kSecAttrLabel];
        }
    }
    
    return [query autorelease];
}
@end

@implementation MHKeychain (InternetPassword)

+ (BOOL)addInternetPasswordWithProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password
{
    NSDictionary *query;
    OSErr status = noErr;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account password:password];
    status = SecItemAdd((CFDictionaryRef)query, NULL);
    if (status != noErr) {
        NSLog(@"Error getting item: %d for service: %@, account: %@\n", (int)status, host, account);
    }
    
    return status == noErr;
}

+ (BOOL)updateInternetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password
{
    NSDictionary *update;
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account password:nil];
    update = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account password:password];
    status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)update);
    if (status != noErr) {
        NSLog(@"Error updating item: %d for %@ %@ %@\n", (int)status, host, account, account);
    }
    
    return status == noErr;
}

+ (BOOL)addOrUpdateInternetPasswordWithProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password
{
    BOOL result;
    NSString *oldPassword;
    
    oldPassword = [self internetPasswordProtocol:protocol host:host port:port account:account];
    if (oldPassword == nil) {
        result = [self addInternetPasswordWithProtocol:protocol host:host port:port account:account password:password];
    } else if (![oldPassword isEqualToString:password]){
        result = [self updateInternetPasswordProtocol:protocol host:host port:port account:account password:password];
    }
    return result;
}

+ (NSString *)internetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account
{
    NSMutableDictionary *query;
    CFTypeRef result;
    OSErr status;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account password:nil];
    [query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status != noErr) {
        return nil;
    } else {
        return [[[NSString alloc] initWithUTF8String:[(NSData *)result bytes]] autorelease];
    }
}

+ (BOOL)deleteInternetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account password:nil];
    
    status = SecItemDelete((CFDictionaryRef)query);
    if (status != noErr) {
        NSLog(@"Error deleting item: %d for %@ %@ %@\n", (int)status, host, account, account);
    }
    
    return status == noErr;
}

@end

@implementation MHKeychain (GenericPassword)

+ (BOOL)addItemWithLabel:(NSString *)label host:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port password:(NSString *)password
{
    NSDictionary *query;
    OSErr status = noErr;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:protocol host:host port:port account:account password:password];
    
    status = SecItemAdd((CFDictionaryRef)query, NULL);
    if (status != noErr) {
        NSLog(@"Error getting item: %d for service: %@, account: %@\n", (int)status, host, account);
    }
    
    return status == noErr;
}

+ (BOOL)updateItemWithLabel:(NSString *)label host:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port password:(NSString *)password
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:protocol host:host port:port account:account password:nil];
    
    status = SecItemUpdate((CFDictionaryRef)query, NULL);
    if (status != noErr) {
        NSLog(@"Error updating item: %d for %@ %@\n", (int)status, host, account);
    }
    
    return status == noErr;
}

+ (BOOL)addOrUpdateItemWithLabel:(NSString *)label host:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port password:(NSString *)password
{
    BOOL result;
    
    result = [self addItemWithLabel:label host:host account:account protocol:protocol port:port password:password];
    if (!result) {
        result = [self updateItemWithLabel:label host:host account:account protocol:protocol port:port password:password];
    }
    return result;
}

+ (NSString *)passwordWithLabel:(NSString *)label host:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port
{
    NSMutableDictionary *query;
    CFTypeRef result;
    OSErr status;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:protocol host:host port:port account:account password:nil];
    [query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status != noErr) {
        return nil;
    } else {
        return [[[NSString alloc] initWithUTF8String:[(NSData *)result bytes]] autorelease];
    }
}

+ (BOOL)deleteItemWithLabel:(NSString *)label host:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:protocol host:host port:port account:account password:nil];
    
    status = SecItemDelete((CFDictionaryRef)query);
    if (status != noErr) {
        NSLog(@"Error deleting item: %d for %@ %@\n", (int)status, host, account);
    }
    
    return status == noErr;
}

@end
