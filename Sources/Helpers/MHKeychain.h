//
//  MHKeychain.h
//  MongoHub
//
//  Created by Jérôme Lebel on 25/10/2013.
//  Copyright (c) 2013 ThePeppersStudio.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHKeychain : NSObject
    
+ (BOOL)addItemWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port password:(NSString *)password;
+ (NSString *)passwordWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port name:(NSString *)name;
+ (BOOL)updateItemWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port name:(NSString *)name password:(NSString *)password;
+ (NSString *)deleteItemWithHost:(NSString *)host account:(NSString *)account protocol:(NSString *)protocol port:(NSUInteger)port name:(NSString *)name;

@end
