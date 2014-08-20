//
//  NSString+MongoHub.h
//  MongoHub
//
//  Created by Jerome on 07/08/2014.
//

#import "NSString+MongoHub.h"


@implementation NSString (MongoHub)

- (NSString*)mh_stringByEscapingURL
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

- (NSString *)mh_stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

@end
