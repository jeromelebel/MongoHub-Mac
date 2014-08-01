//
//  MHKeychain.h
//  MongoHub
//
//  Created by Jérôme Lebel on 25/10/2013.
//  Copyright (c) 2013 ThePeppersStudio.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHKeychain : NSObject

@end

@interface MHKeychain (InternetPassword)
+ (BOOL)addInternetPasswordWithProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password;
+ (BOOL)updateInternetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password;
+ (BOOL)addOrUpdateInternetPasswordWithProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account password:(NSString *)password;
+ (NSString *)internetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account;
+ (BOOL)deleteInternetPasswordProtocol:(CFTypeRef)protocol host:(NSString *)host port:(NSUInteger)port account:(NSString *)account;

@end

@interface MHKeychain (GenericPassword)
+ (BOOL)addItemWithLabel:(NSString *)label account:(NSString *)account description:(NSString *)description password:(NSString *)password;
+ (BOOL)updateItemWithLabel:(NSString *)label account:(NSString *)account description:(NSString *)description password:(NSString *)password;
+ (BOOL)addOrUpdateItemWithLabel:(NSString *)label account:(NSString *)account description:(NSString *)description password:(NSString *)password;
+ (NSString *)passwordWithLabel:(NSString *)label account:(NSString *)account description:(NSString *)description;
+ (BOOL)deleteItemWithLabel:(NSString *)label account:(NSString *)account description:(NSString *)description;

@end