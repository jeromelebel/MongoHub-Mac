//
//  NSTextView+MongoHub.h
//  MongoHub
//
//  Created by Jérôme Lebel on 09/06/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (MongoHub)

// this method setup the text view to have a good font and not automatic correction
- (void)mh_jsonSetup;

@end
