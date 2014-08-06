//
//  NSString+Extras.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "NSString+Extras.h"


@implementation NSString (Extras)

- (NSString*)stringByEscapingURL
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@";/?:@&=+$%,"]];
}

- (NSString *)stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
