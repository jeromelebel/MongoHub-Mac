//
//  MHJsonColorManager.h
//  MongoHub
//
//  Created by Jérôme Lebel on 29/08/2014.
//
//

#import <AppKit/AppKit.h>

@interface MHJsonColorManager : NSObject

- (NSColor *)colorForComponentKey:(NSString *)key;
- (NSArray *)components;

@end
