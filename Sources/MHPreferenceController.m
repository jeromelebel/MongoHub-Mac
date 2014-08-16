//
//  MHPreferenceController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 23/10/2013.
//

#import "MHPreferenceController.h"
#import "MHApplicationDelegate.h"

@implementation MHPreferenceController

@synthesize window = _window;

+ (MHPreferenceController *)preferenceController
{
    MHPreferenceController *result;
    result = [[[MHPreferenceController alloc] initWithNibName:@"MHPreferenceController" bundle:NSBundle.mainBundle] autorelease];
    [result loadView];
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

- (void)betaSoftwareAction:(id)sender
{
    if (_betaSoftwareButton.state == NSOffState) {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelDefault];
    } else {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelBeta];
    }
}

- (IBAction)openWindow:(id)sender
{
    [_window makeKeyAndOrderFront:sender];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MHPreferenceControllerClosing object:self];
}

@end
