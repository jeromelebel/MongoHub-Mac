//
//  MHPreferenceWindowController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 23/10/2013.
//

#import "MHPreferenceWindowController.h"
#import "MHApplicationDelegate.h"
#import "MHJsonColorManager.h"

@interface MHPreferenceWindowController ()

@property (nonatomic, readwrite, weak) IBOutlet NSButton *betaSoftwareButton;
@property (nonatomic, readwrite, weak) IBOutlet NSColorWell *textBackgroundColorWell;
@property (nonatomic, readwrite, weak) IBOutlet NSTableView *jsonColorTableView;

@property (nonatomic, readwrite, strong) NSMutableArray *jsonComponents;

@end

@interface MHPreferenceWindowController (NSTableView) <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation MHPreferenceWindowController

@synthesize betaSoftwareButton = _betaSoftwareButton;
@synthesize textBackgroundColorWell = _textBackgroundColorWell;
@synthesize jsonColorTableView = _jsonColorTableView;
@synthesize jsonComponents = _jsonComponents;

+ (MHPreferenceWindowController *)preferenceWindowController
{
    MHPreferenceWindowController *result;
    result = [[[MHPreferenceWindowController alloc] initWithWindowNibName:@"MHPreferenceWindow"] autorelease];
    return result;
}

- (void)awakeFromNib
{
    NSMutableSet *componentNames = [[[NSMutableSet alloc] init] autorelease];
    
    if ([(MHApplicationDelegate *)NSApplication.sharedApplication.delegate softwareUpdateChannel] == MHSoftwareUpdateChannelBeta) {
        self.betaSoftwareButton.state = NSOnState;
    } else {
        self.betaSoftwareButton.state = NSOffState;
    }
    self.textBackgroundColorWell.color = MHJsonColorManager.sharedManager.values[@"TextField"][@"Background"][@"Color"];
    self.textBackgroundColorWell.target = self;
    self.textBackgroundColorWell.action = @selector(colorWellAction:);
    
    self.jsonComponents = [NSMutableArray array];
    for (NSDictionary *component in [MHJsonColorManager.sharedManager.values[@"Components"] allValues]) {
        if (![componentNames containsObject:component[@"Name"]]) {
            NSMutableDictionary *newComponent = [component mutableCopy];
            
            [self.jsonComponents addObject:newComponent];
            [componentNames addObject:newComponent[@"Name"]];
            [newComponent release];
        }
    }
    [self.jsonComponents sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"Name"] compare:obj2[@"Name"]];
    }];
    self.jsonColorTableView.backgroundColor = self.textBackgroundColorWell.color;
}

- (IBAction)betaSoftwareAction:(id)sender
{
    if (self.betaSoftwareButton.state == NSOffState) {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelDefault];
    } else {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelBeta];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MHPreferenceWindowControllerClosing object:self];
    [MHJsonColorManager.sharedManager save];
}

- (void)colorWellAction:(id)sender
{
    if (self.textBackgroundColorWell == sender) {
        self.jsonColorTableView.backgroundColor = self.textBackgroundColorWell.color;
        MHJsonColorManager.sharedManager.values[@"TextField"][@"Background"][@"Color"] = self.textBackgroundColorWell.color;
        [MHJsonColorManager.sharedManager valueUpdated];
    }
}

@end

@implementation MHPreferenceWindowController (NSTableView)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.jsonComponents.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextField *result;
    
    result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    if (!result) {
        result = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)] autorelease];
        result.identifier = @"MyView";
        result.enabled = YES;
        result.editable = NO;
        result.bordered = NO;
        result.drawsBackground = NO;
    }
    result.stringValue = self.jsonComponents[row][@"Name"];
    result.textColor = self.jsonComponents[row][@"Color"];
    return result;
}

@end
