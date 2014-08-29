//
//  MHPreferenceWindowController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 23/10/2013.
//

#import "MHPreferenceWindowController.h"
#import "MHApplicationDelegate.h"

@implementation MHPreferenceWindowController

+ (MHPreferenceWindowController *)preferenceWindowController
{
    MHPreferenceWindowController *result;
    result = [[[MHPreferenceWindowController alloc] initWithWindowNibName:@"MHPreferenceWindow"] autorelease];
    return result;
}

- (void)awakeFromNib
{
    if ([(MHApplicationDelegate *)NSApplication.sharedApplication.delegate softwareUpdateChannel] == MHSoftwareUpdateChannelBeta) {
        _betaSoftwareButton.state = NSOnState;
    } else {
        _betaSoftwareButton.state = NSOffState;
    }
}

- (IBAction)betaSoftwareAction:(id)sender
{
    if (_betaSoftwareButton.state == NSOffState) {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelDefault];
    } else {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelBeta];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MHPreferenceWindowControllerClosing object:self];
}

@end
