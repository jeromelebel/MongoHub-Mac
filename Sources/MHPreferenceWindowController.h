//
//  MHPreferenceWindowController
//  MongoHub
//
//  Created by Jérôme Lebel on 23/10/2013.
//

#import <Cocoa/Cocoa.h>

#define MHPreferenceWindowControllerClosing           @"MHPreferenceWindowControllerClosing"

@interface MHPreferenceWindowController : NSWindowController
{
    IBOutlet NSButton                   *_betaSoftwareButton;
}

+ (instancetype)preferenceWindowController;

- (IBAction)openWindow:(id)sender;
- (IBAction)betaSoftwareAction:(id)sender;
@end
