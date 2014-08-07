//
//  NSString+Helpers.h
//  MongoHub
//
//  Created by Jerome on 07/08/2014.
//

#import <Cocoa/Cocoa.h>


@interface NSString (Helpers)

- (NSString *)mh_stringByEscapingURL;
- (NSString *)mh_stringByTrimmingWhitespace;

@end
