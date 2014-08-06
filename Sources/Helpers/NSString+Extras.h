//
//  NSString+Extras.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (Extras)

- (NSString*)stringByEscapingURL;
- (NSString *)stringByTrimmingWhitespace;

+ (NSString*)UUIDString;

@end
