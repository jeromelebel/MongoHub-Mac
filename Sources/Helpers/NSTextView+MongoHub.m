//
//  NSTextView+MongoHub.m
//  MongoHub
//
//  Created by Jérôme Lebel on 09/06/2014.
//
//

#import "NSTextView+MongoHub.h"

@implementation NSTextView (MongoHub)

- (void)mh_jsonSetup
{
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
