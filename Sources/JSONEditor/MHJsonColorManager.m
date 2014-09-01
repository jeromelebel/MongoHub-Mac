//
//  MHJsonColorManager.m
//  MongoHub
//
//  Created by Jérôme Lebel on 29/08/2014.
//
//

#import "MHJsonColorManager.h"

#define MHJsonColorManagerUserDefaultKey @"MHJsonColorManagerUserDefaultKey"
static MHJsonColorManager *jsonColorManager = nil;

@interface MHJsonColorManager ()
@property (nonatomic, readwrite, strong) NSMutableDictionary *values;
@end

@interface MHJsonColorManager (Convert)
+ (id)valuesFromPlistValues:(id)plistValues;
+ (id)plistValuesFromValues:(id)values;
@end

@implementation MHJsonColorManager

@synthesize values = _values;

+ (instancetype)sharedManager
{
    if (!jsonColorManager) {
        jsonColorManager = [[MHJsonColorManager alloc] init];
    }
    return jsonColorManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadPlist];
    }
    return self;
}

- (void)loadPlist
{
    NSDictionary *rowValues;
    
    rowValues = [NSDictionary dictionaryWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"SyntaxDefinition" ofType:@"plist"]];
    self.values = [self.class valuesFromPlistValues:rowValues];
    rowValues = [[NSUserDefaults standardUserDefaults] objectForKey:MHJsonColorManagerUserDefaultKey];
    if (rowValues) {
        NSDictionary *userValues;
        
        userValues = [self.class valuesFromPlistValues:rowValues];
        for (NSString *category in @[ @"Components", @"TextField"]) {
            for (NSString *key in [self.values[category] allKeys]) {
                if (userValues[category][key]) {
                    self.values[category][key] = userValues[category][key];
                }
            }
        }
    }
}

- (void)resetValues
{
    NSDictionary *rowValues;
    
    rowValues = [NSDictionary dictionaryWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"SyntaxDefinition" ofType:@"plist"]];
    self.values = [self.class valuesFromPlistValues:rowValues];
    [self valueUpdated];
}

- (void)valueUpdated
{
    NSDictionary *rowValues;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MHJsonColorManagerHasBeenUpdatedNotification object:self];
    rowValues = [self.class plistValuesFromValues:self.values];
    [[NSUserDefaults standardUserDefaults] setObject:rowValues forKey:MHJsonColorManagerUserDefaultKey];
}

- (void)save
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation MHJsonColorManager (Convert)

+ (id)valuesFromPlistValues:(id)plistValues
{
    if ([plistValues isKindOfClass:NSDictionary.class]) {
        return [self dictionaryValueFromPlistValue:plistValues];
    } else if ([plistValues isKindOfClass:NSArray.class]) {
        return [self arrayValueFromPlistValue:plistValues];
    } else {
        return plistValues;
    }
}

+ (NSMutableDictionary *)dictionaryValueFromPlistValue:(NSDictionary *)plistValue
{
    NSMutableDictionary *result;
    
    result = [NSMutableDictionary dictionary];
    for (NSString *key in plistValue.allKeys) {
        id value;
        
        if ([key isEqualToString:@"Color"]) {
            value = [self colorValueFromPlistValue:plistValue[key]];
        } else if ([key isEqualToString:@"Font"]) {
            value = [self fontValueFromPlistValue:plistValue[key]];
        } else {
            value = [self valuesFromPlistValues:plistValue[key]];
        }
        result[key] = value;
    }
    return result;
}

+ (NSMutableArray *)arrayValueFromPlistValue:(NSArray *)plistValue
{
    NSMutableArray *result;
    
    result = [NSMutableArray array];
    for (id value in plistValue) {
        [result addObject:[self valuesFromPlistValues:value]];
    }
    return result;
}

+ (NSColor *)colorValueFromPlistValue:(NSArray *)plistValue
{
    NSColor *result;
    CGFloat red = 0, green = 0, blue = 0, alpha = 1;
    
    if (plistValue.count >= 3) {
        red = [plistValue[0] floatValue];
        green = [plistValue[1] floatValue];
        blue = [plistValue[2] floatValue];
    } else {
        NSLog(@"problem");
    }
    if (plistValue.count >= 4) {
        alpha = [plistValue[3] floatValue];
    }
    result = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
    return result;
}

+ (NSFont *)fontValueFromPlistValue:(NSDictionary *)plistValue
{
    return [NSFont fontWithName:plistValue[@"name"] size:[plistValue[@"size"] floatValue]];
}

+ (id)plistValuesFromValues:(id)values
{
    if ([values isKindOfClass:NSDictionary.class]) {
        return [self plistDictionaryFromValue:values];
    } else if ([values isKindOfClass:NSArray.class]) {
        return [self plistArrayFromValue:values];
    } else {
        return values;
    }
}

+ (NSMutableDictionary *)plistDictionaryFromValue:(NSDictionary *)plistValue
{
    NSMutableDictionary *result;
    
    result = [NSMutableDictionary dictionary];
    for (NSString *key in plistValue.allKeys) {
        id value;
        
        if ([key isEqualToString:@"Color"]) {
            value = [self arrayValueFromColorValue:plistValue[key]];
        } else if ([key isEqualToString:@"Font"]) {
            value = [self dictionaryValueFromFontValue:plistValue[key]];
        } else {
            value = [self plistValuesFromValues:plistValue[key]];
        }
        result[key] = value;
    }
    return result;
}

+ (NSMutableArray *)plistArrayFromValue:(NSArray *)plistValue
{
    NSMutableArray *result;
    
    result = [NSMutableArray array];
    for (id value in plistValue) {
        [result addObject:[self plistValuesFromValues:value]];
    }
    return result;
}

+ (NSArray *)arrayValueFromColorValue:(NSColor *)color
{
    NSMutableArray *result;
    
    color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    result = [NSMutableArray array];
    [result addObject:[NSNumber numberWithFloat:color.redComponent]];
    [result addObject:[NSNumber numberWithFloat:color.greenComponent]];
    [result addObject:[NSNumber numberWithFloat:color.blueComponent]];
    [result addObject:[NSNumber numberWithFloat:color.alphaComponent]];
    return result;
}

+ (NSDictionary *)dictionaryValueFromFontValue:(NSFont *)font
{
    NSMutableDictionary *result;
    
    result = [NSMutableDictionary dictionary];
    [result setObject:font.fontName forKey:@"name"];
    [result setObject:[NSNumber numberWithFloat:font.pointSize] forKey:@"size"];
    return result;
}

@end