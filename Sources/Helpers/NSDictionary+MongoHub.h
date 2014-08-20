//
//  NSDictionary+MongoHub.h
//  MongoHub
//
//  Created by Jérôme Lebel on 20/08/2014.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MongoHub)

+ (instancetype)mh_dictionaryFromURLParameters:(NSString *)parameters;

@end
