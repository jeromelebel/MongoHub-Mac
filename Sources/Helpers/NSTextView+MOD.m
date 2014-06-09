//
//  NSTextView+MOD.m
//  MongoHub
//
//  Created by Jérôme Lebel on 09/06/2014.
//
//

#import "NSTextView+MOD.h"

@implementation NSTextView (MOD)

- (void)mod_jsonSetup
{
    // Using a fixed-width font is a little easier on the eyes when dealing with JavaScript objects.
    [self setFont:[NSFont fontWithName:@"Menlo" size:12]];

    // Disable spell checking and substitutions.
    // When dealing with JavaScript objects, switching regular double quotes into smart quotes isn't helpful.
    [self setAutomaticDashSubstitutionEnabled:NO];
    [self setAutomaticDataDetectionEnabled:NO];
    [self setAutomaticLinkDetectionEnabled:NO];
    [self setAutomaticQuoteSubstitutionEnabled:NO];
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setAutomaticTextReplacementEnabled:NO];
}

@end
