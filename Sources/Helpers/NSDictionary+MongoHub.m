//
//  NSDictionary+MongoHub.h
//  MongoHub
//
//  Created by Jérôme Lebel on 20/08/2014.
//
//

#import "NSDictionary+MongoHub.h"

@implementation NSDictionary (MongoHub)

+ (instancetype)mh_dictionaryFromURLParameters:(NSString *)parameters
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSString *keyValue in [parameters componentsSeparatedByString:@"&"]) {
        NSArray *components = [keyValue componentsSeparatedByString:@"="];
        
        if (components.count == 1) {
            [result setObject:@"" forKey:[components objectAtIndex:0]];
        } else if (components.count == 2) {
            [result setObject:[components objectAtIndex:1] forKey:[components objectAtIndex:0]];
        }
    }
    return result;
}

- (NSDictionary *)mh_setKeysToLowerCase
{
    NSMutableDictionary *result;
    
    result = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        *stop = NO;
        result[[key lowercaseString]] = obj;
    }];
    return result;
}

@end
