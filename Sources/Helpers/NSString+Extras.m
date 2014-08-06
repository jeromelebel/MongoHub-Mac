//
//  NSString+Extras.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "NSString+Extras.h"


@implementation NSString (Extras)

- (NSString*)stringByPercentEscapingCharacters:(NSString*)characters
{
    return [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)characters, kCFStringEncodingUTF8) autorelease];
}

- (NSString*)stringByEscapingURL
{
    return [self stringByPercentEscapingCharacters:@";/?:@&=+$%,"];
}

- (NSString *)stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString*)UUIDString
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}


@end
