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
    NSButton                            *_betaSoftwareButton;
    NSColorWell                         *_textBackgroundColorWell;
    NSTableView                         *_jsonColorTableView;
    NSTextField                         *_jsonTextLabelView;
    NSColorWell                         *_jsonTextColorWell;
    
    NSMutableArray                      *_jsonComponents;
    
    NSTextField                         *_connectTimeoutTextField;
    NSTextField                         *_socketTimeoutTextField;
}

+ (instancetype)preferenceWindowController;

@end
