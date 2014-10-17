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
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *)mh_stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

@end
