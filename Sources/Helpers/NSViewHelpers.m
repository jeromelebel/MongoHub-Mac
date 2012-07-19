//
//  NSViewHelpers.m
//  MongoHub
//
//  Created by Jérôme Lebel on 11/07/12.
//  Copyright (c) 2012 ThePeppersStudio.COM. All rights reserved.
//

#import "NSViewHelpers.h"

#define TIME_STEP 0.1

static NSMutableDictionary *colorInfo = nil;

@implementation NSViewHelpers

static NSString *keyForTargetAndSelector(id target, NSString *selector)
{
    return [NSString stringWithFormat:@"%p%@", target, selector];
}

+ (void)updateColor:(NSMutableDictionary *)info
{
    NSColor *newColor;
    BOOL shouldContinue = NO;
    
    shouldContinue = [[info objectForKey:@"datedestination"] timeIntervalSinceNow] > 0;
    if (![[info objectForKey:@"cancel"] boolValue]) {
        if (shouldContinue) {
            NSColor *currentColor;
            
            currentColor = [info objectForKey:@"currentcolor"];
            [self performSelector:@selector(updateColor:) withObject:info afterDelay:TIME_STEP];
            
            CGFloat currentColorComponents[4];
            [currentColor getComponents:currentColorComponents];
            
            newColor = [NSColor colorWithDeviceRed:currentColorComponents[0] + [[info objectForKey:@"deltared"] floatValue] green:currentColorComponents[1] + [[info objectForKey:@"deltagreen"] floatValue] blue:currentColorComponents[2] + [[info objectForKey:@"deltablue"] floatValue] alpha:currentColorComponents[3] + [[info objectForKey:@"deltaalpha"] floatValue]];
            [info setObject:newColor forKey:@"currentcolor"];
        } else {
            newColor = [info objectForKey:@"destinationcolor"];
            [colorInfo removeObjectForKey:keyForTargetAndSelector([info objectForKey:@"target"], [info objectForKey:@"selector"])];
        }
        [[info objectForKey:@"target"] performSelector:NSSelectorFromString([info objectForKey:@"selector"]) withObject:newColor];
    }
}

+ (void)cancelColorForTarget:(id)target selector:(SEL)selector
{
    NSMutableDictionary *info;
    NSString *infoKey;
    
    infoKey = keyForTargetAndSelector(target, NSStringFromSelector(selector));
    info = [colorInfo objectForKey:infoKey];
    if (info) {
        [info setObject:[NSNumber numberWithBool:YES] forKey:@"cancel"];
        [target performSelector:selector withObject:[info objectForKey:@"destinationcolor"]];
        [colorInfo removeObjectForKey:infoKey];
    }
}

+ (void)setColor:(NSColor *)destinationColor fromColor:(NSColor *)originColor toTarget:(id)target withSelector:(SEL)selector delay:(NSInteger)delay
{
    NSDictionary *info;
    NSNumber *red, *green, *blue, *alpha;
    NSString *stringSelector;
    
    if (!colorInfo) {
        colorInfo = [[NSMutableDictionary alloc] init];
    }
    stringSelector = NSStringFromSelector(selector);
    destinationColor = [destinationColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    originColor = [originColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];

    CGFloat destComponents[4];
    CGFloat originComponents[4];
    [destinationColor getComponents:destComponents];
    [originColor getComponents:originComponents];
    
    red = [[NSNumber alloc] initWithFloat:(destComponents[0] - originComponents[0]) * TIME_STEP / delay];
    green = [[NSNumber alloc] initWithFloat:(destComponents[1] - originComponents[1]) * TIME_STEP / delay];
    blue = [[NSNumber alloc] initWithFloat:(destComponents[2] - originComponents[2]) * TIME_STEP / delay];
    alpha = [[NSNumber alloc] initWithFloat:(destComponents[3] - originComponents[3]) * TIME_STEP / delay];
    info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:destinationColor, @"destinationcolor", originColor, @"currentcolor", red, @"deltared", blue, @"deltablue", green, @"deltagreen", alpha, @"deltaalpha", target, @"target", stringSelector, @"selector", [NSDate dateWithTimeIntervalSinceNow:delay], @"datedestination", nil];
    [self performSelector:@selector(updateColor:) withObject:info afterDelay:TIME_STEP];
    [colorInfo setObject:info forKey:keyForTargetAndSelector(target, stringSelector)];
    [info release];
    [red release];
    [green release];
    [blue release];
    [alpha release];
}

@end
