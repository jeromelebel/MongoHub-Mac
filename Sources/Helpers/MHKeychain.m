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
// errSecNoAccessForItem

+ (NSMutableDictionary *)queryForClass:(CFTypeRef)itemClass label:(NSString *)label protocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account service:(NSString *)service description:(NSString *)description password:(NSString *)password
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    [query setObject:itemClass forKey:(id)kSecClass];
    if (service) {
        [query setObject:service forKey:kSecAttrService];
    }
    if (description) {
        [query setObject:description forKey:(id)kSecAttrDescription];
    }
    if (account) {
        [query setObject:account forKey:(id)kSecAttrAccount];
    }
    if (protocol) {
        [query setObject:protocol forKey:(id)kSecAttrProtocol];
    }
    if (host) {
        [query setObject:host forKey:(id)kSecAttrServer];
    }
    if (port) {
        [query setObject:[NSNumber numberWithUnsignedInteger:port] forKey:(id)kSecAttrPort];
    }
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
    
    return query;
}
@end

@implementation MHKeychain (InternetPassword)

+ (BOOL)addInternetPasswordWithProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password
{
    NSDictionary *query;
    OSErr status = noErr;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account service:nil description:nil password:password];
    status = SecItemAdd((CFDictionaryRef)query, NULL);
    if (status != noErr) {
        NSLog(@"Error adding internet password: %d for %@ %@ %@\n", (int)status, host, account, account);
    }
    
    return status == noErr;
}

+ (BOOL)updateInternetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password
{
    NSDictionary *update;
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account service:nil description:nil password:nil];
    update = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account service:nil description:nil password:password];
    status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)update);
    if (status != noErr) {
        NSLog(@"Error updating internet password: %d for %@ %@ %@\n", (int)status, host, account, account);
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
    } else {
        // the password already exists, and is the same. No need to update
        result = YES;
    }
    return result;
}

+ (NSString *)internetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account
{
    NSMutableDictionary *query;
    CFTypeRef result;
    OSErr status;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account service:nil description:nil password:nil];
    [query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status != errSecItemNotFound) {
        return nil;
    } else if (status != noErr) {
        NSLog(@"Error searching internet password: %d for %@ %@ %@\n", (int)status, host, account, account);
        return nil;
    } else {
        return [[[NSString alloc] initWithUTF8String:[(NSData *)result bytes]] autorelease];
    }
}

+ (BOOL)deleteInternetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassInternetPassword label:nil protocol:protocol host:host port:port account:account service:nil description:nil password:nil];
    
    status = SecItemDelete((CFDictionaryRef)query);
    if (status != noErr) {
        NSLog(@"Error deleting internet password: %d for %@ %@ %@\n", (int)status, host, account, account);
    }
    
    return status == noErr;
}

@end

@implementation MHKeychain (GenericPassword)

+ (BOOL)addItemWithLabel:(NSString *)label account:(NSString *)account service:(NSString *)service description:(NSString *)description password:(NSString *)password
{
    NSMutableDictionary *query;
    OSErr status = noErr;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:nil host:nil port:0 account:account service:service description:description password:password];
    status = SecItemAdd((CFDictionaryRef)query, NULL);
    if (status != noErr) {
        NSLog(@"Error adding item: %d for %@ %@ %@\n", (int)status, label, account, description);
    }
    
    return status == noErr;
}

+ (BOOL)updateItemWithLabel:(NSString *)label account:(NSString *)account service:(NSString *)service description:(NSString *)description password:(NSString *)password
{
    NSDictionary *update;
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:nil host:nil port:0 account:account service:service description:description password:nil];
    update = [self queryForClass:kSecClassGenericPassword label:label protocol:nil host:nil port:0 account:account service:service description:description password:password];
    status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)update);
    if (status != noErr) {
        NSLog(@"Error updating item: %d for %@ %@ %@\n", (int)status, label, account, description);
    }
    
    return status == noErr;
}

+ (BOOL)addOrUpdateItemWithLabel:(NSString *)label account:(NSString *)account service:(NSString *)service description:(NSString *)description password:(NSString *)password
{
    BOOL result;
    NSString *oldPassword;
    
    oldPassword = [self passwordWithLabel:label account:account service:service description:description];
    if (oldPassword == nil) {
        result = [self addItemWithLabel:label account:account service:service description:description password:password];
    } else if (![oldPassword isEqualToString:password]){
        result = [self updateItemWithLabel:label account:account service:service description:description password:password];
    } else {
        // the password already exists, and is the same. No need to update
        result = YES;
    }
    return result;
}

+ (NSString *)passwordWithLabel:(NSString *)label account:(NSString *)account service:(NSString *)service description:(NSString *)description
{
    NSMutableDictionary *query;
    CFTypeRef result;
    OSErr status;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:nil host:nil port:0 account:account service:service description:description password:nil];
    [query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
	status = SecItemCopyMatching((CFDictionaryRef)query, &result);
    if (status == errSecItemNotFound) {
        return nil;
    } else if (status != noErr) {
        NSLog(@"Error searching item: %d for %@ %@ %@\n", (int)status, label, account, description);
        return nil;
    } else {
        return [[[NSString alloc] initWithUTF8String:[(NSData *)result bytes]] autorelease];
    }
}

+ (BOOL)deleteItemWithLabel:(NSString *)label account:(NSString *)account service:(NSString *)service description:(NSString *)description
{
    NSDictionary *query;
    OSErr status;
    
    query = [self queryForClass:kSecClassGenericPassword label:label protocol:nil host:nil port:0 account:account service:service description:description password:nil];
    
    status = SecItemDelete((CFDictionaryRef)query);
    if (status != noErr) {
        NSLog(@"Error deleting item: %d for %@ %@ %@\n", (int)status, label, account, description);
    }
    
    return status == noErr;
}

@end
