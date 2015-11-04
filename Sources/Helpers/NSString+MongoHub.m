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
    NSMutableCharacterSet*chars=[[NSMutableCharacterSet alloc]init];
    [chars addCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    
    NSString* output = [self stringByAddingPercentEncodingWithAllowedCharacters:chars];
    
    return output;
}

- (NSString *)mh_stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

@end
