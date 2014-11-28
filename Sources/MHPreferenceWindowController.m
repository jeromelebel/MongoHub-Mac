//
//  MHPreferenceWindowController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 23/10/2013.
//

#import "MHPreferenceWindowController.h"
#import "MHApplicationDelegate.h"
#import "MHJsonColorManager.h"

#define MHDefaultSortOrderPreferenceKey                     @"MHDefaultSortOrderPreferenceKey"
#define MODJsonKeySortOrderInSearchPreferenceKey            @"MODJsonKeySortOrderInSearchPreferenceKey"

@interface MHPreferenceWindowController ()

@property (nonatomic, weak, readwrite) IBOutlet NSButton *betaSoftwareButton;
@property (nonatomic, weak, readwrite) IBOutlet NSColorWell *textBackgroundColorWell;
@property (nonatomic, weak, readwrite) IBOutlet NSTableView *jsonColorTableView;
@property (nonatomic, weak, readwrite) IBOutlet NSTextField *jsonTextLabelView;
@property (nonatomic, weak, readwrite) IBOutlet NSColorWell *jsonTextColorWell;

@property (nonatomic, strong, readwrite) NSMutableArray *jsonComponents;

@property (nonatomic, weak, readwrite) IBOutlet NSPopUpButton *defaultSortOrder;
@property (nonatomic, weak, readwrite) IBOutlet NSPopUpButton *jsonKeySortOrderInSearch;

@property (nonatomic, weak, readwrite) IBOutlet NSTextField *connectTimeoutTextField;
@property (nonatomic, weak, readwrite) IBOutlet NSTextField *socketTimeoutTextField;

@end

@interface MHPreferenceWindowController (NSTableView) <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation MHPreferenceWindowController

@synthesize betaSoftwareButton = _betaSoftwareButton;
@synthesize textBackgroundColorWell = _textBackgroundColorWell;
@synthesize jsonColorTableView = _jsonColorTableView;
@synthesize jsonComponents = _jsonComponents;
@synthesize jsonTextLabelView = _jsonTextLabelView;
@synthesize jsonTextColorWell = _jsonTextColorWell;

@synthesize defaultSortOrder = _defaultSortOrder;
@synthesize jsonKeySortOrderInSearch = _jsonKeySortOrderInSearch;

@synthesize connectTimeoutTextField = _connectTimeoutTextField;
@synthesize socketTimeoutTextField = _socketTimeoutTextField;

+ (MHPreferenceWindowController *)preferenceWindowController
{
    MHPreferenceWindowController *result;
    result = [[[MHPreferenceWindowController alloc] initWithWindowNibName:@"MHPreferenceWindow"] autorelease];
    return result;
}

- (void)awakeFromNib
{
    NSMutableSet *componentNames = [[[NSMutableSet alloc] init] autorelease];
    uint32_t value;
    
    if ([(MHApplicationDelegate *)NSApplication.sharedApplication.delegate softwareUpdateChannel] == MHSoftwareUpdateChannelBeta) {
        self.betaSoftwareButton.state = NSOnState;
    } else {
        self.betaSoftwareButton.state = NSOffState;
    }
    self.textBackgroundColorWell.color = MHJsonColorManager.sharedManager.values[@"TextField"][@"Background"][@"Color"];
    
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
    [self updateRowSize];

    self.jsonTextLabelView.font = MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"];
    self.jsonTextLabelView.stringValue = @" ";
    [self.jsonTextLabelView sizeToFit];
    
    [self.socketTimeoutTextField.cell setPlaceholderString:[NSString stringWithFormat:@"%u", [(MHApplicationDelegate *)[NSApp delegate] defaultSocketTimeout]]];
    value = [(MHApplicationDelegate *)[NSApp delegate] socketTimeout];
    if (value != 0) {
        self.socketTimeoutTextField.stringValue = [NSString stringWithFormat:@"%u", value];
    }
    [self.connectTimeoutTextField.cell setPlaceholderString:[NSString stringWithFormat:@"%u", [(MHApplicationDelegate *)[NSApp delegate] defaultConnectTimeout]]];
    value = [(MHApplicationDelegate *)[NSApp delegate ] connectTimeout];
    if (value != 0) {
        self.connectTimeoutTextField.stringValue = [NSString stringWithFormat:@"%u", value];
    }
    [self.defaultSortOrder selectItemAtIndex:[self.class defaultSortOrder]];
    [self.jsonKeySortOrderInSearch selectItemAtIndex:[self.class jsonKeySortOrderInSearch]];
}

- (IBAction)betaSoftwareAction:(id)sender
{
    if (self.betaSoftwareButton.state == NSOffState) {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelDefault];
    } else {
        [(MHApplicationDelegate *)NSApplication.sharedApplication.delegate setSoftwareUpdateChannel:MHSoftwareUpdateChannelBeta];
    }
}

- (IBAction)openFontPanelForJsonAction:(id)sender
{
    [NSFontManager sharedFontManager].delegate = self;
    [NSFontManager sharedFontManager].action = @selector(changeJsonFont:);
    [[[NSFontManager sharedFontManager] fontPanel:YES] setPanelFont:MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"] isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:nil];
}

- (IBAction)changeDefaultSortOrderAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.defaultSortOrder.indexOfSelectedItem forKey:MHDefaultSortOrderPreferenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:MHDefaultSortOrderPreferenceChangedNotification object:self];
}

- (IBAction)changeJsonKeySortOrderInSearchAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.jsonKeySortOrderInSearch.indexOfSelectedItem forKey:MODJsonKeySortOrderInSearchPreferenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeJsonFont:(NSFontManager *)fontManager
{
    MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"] = [fontManager convertFont:MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"]];
    self.jsonTextLabelView.font = MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"];
    [self.jsonTextLabelView sizeToFit];
    [MHJsonColorManager.sharedManager valueUpdated];
    [self updateRowSize];
    [self.jsonColorTableView reloadData];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MHPreferenceWindowControllerClosing object:self];
    [MHJsonColorManager.sharedManager save];
}

- (IBAction)jsonBackgroundColorWellAction:(id)sender
{
    self.jsonColorTableView.backgroundColor = self.textBackgroundColorWell.color;
    MHJsonColorManager.sharedManager.values[@"TextField"][@"Background"][@"Color"] = self.textBackgroundColorWell.color;
    [MHJsonColorManager.sharedManager valueUpdated];
}

- (IBAction)jsonTextColorWellAction:(id)sender
{
    if (self.jsonColorTableView.selectedRowIndexes.count > 0) {
        NSUInteger index;
        NSIndexSet *selectedRows;
        
        selectedRows = [self.jsonColorTableView.selectedRowIndexes mutableCopy];
        index = selectedRows.firstIndex;
        if (index == 0) {
            MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Color"] = self.jsonTextColorWell.color;
            MHJsonColorManager.sharedManager.values[@"TextField"][@"InsertPoint"][@"Color"] = self.jsonTextColorWell.color;
        } else {
            self.jsonComponents[index - 1][@"Color"] = self.jsonTextColorWell.color;
            for (NSMutableDictionary *component in [MHJsonColorManager.sharedManager.values[@"Components"] allValues]) {
                if ([component[@"Name"] isEqualToString:self.jsonComponents[index - 1][@"Name"]]) {
                    component[@"Color"] = self.jsonTextColorWell.color;
                }
            }
        }
        [MHJsonColorManager.sharedManager valueUpdated];
        [self.jsonColorTableView reloadData];
        [self.jsonColorTableView selectRowIndexes:selectedRows byExtendingSelection:NO];
        [selectedRows release];
    }
}

- (NSTextField *)jsonColorTableViewTextField
{
    NSTextField *result;
    
    result = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)] autorelease];
    result.identifier = @"MyView";
    result.font = MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"];
    result.enabled = YES;
    result.editable = NO;
    result.bordered = NO;
    result.drawsBackground = NO;
    return result;
}

- (void)updateRowSize
{
    NSTextField *textField;
    
    textField = [self jsonColorTableViewTextField];
    textField.stringValue = @"ASFWBHDfqlahbjiu";
    [textField sizeToFit];
    self.jsonColorTableView.rowHeight = textField.bounds.size.height;
}

- (IBAction)timeoutTextFieldChanged:(id)sender
{
    uint32_t value;
    
    value = (uint32_t)[sender stringValue].integerValue;
    if (value < 500 && value != 0) {
        NSBeginAlertSheet(@"Invalid Value", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"The timeout should be greater than 500");
    } else if (sender == self.connectTimeoutTextField) {
        [(MHApplicationDelegate *)[NSApp delegate] setConnectTimeout:value];
        if ([(MHApplicationDelegate *)[NSApp delegate] connectTimeout] == 0) {
            self.connectTimeoutTextField.stringValue = @"";
        }
    } else if (sender == self.socketTimeoutTextField) {
        [(MHApplicationDelegate *)[NSApp delegate] setSocketTimeout:value];
        if ([(MHApplicationDelegate *)[NSApp delegate] socketTimeout] == 0) {
            self.socketTimeoutTextField.stringValue = @"";
        }
    }
}

@end

@implementation MHPreferenceWindowController (NSTableView)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.jsonComponents.count + 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextField *result;
    
    result = [tableView makeViewWithIdentifier:@"MyView" owner:nil];
    if (!result) {
        result = [self jsonColorTableViewTextField];
    }
    result.font = MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Font"];
    if (row == 0) {
        result.stringValue = @"Regular Text";
        result.textColor = MHJsonColorManager.sharedManager.values[@"TextField"][@"Text"][@"Color"];
    } else {
        result.stringValue = self.jsonComponents[row - 1][@"Name"];
        result.textColor = self.jsonComponents[row - 1][@"Color"];
    }
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (self.jsonColorTableView.selectedRowIndexes.count > 0) {
        NSTextField *cellView;
        
        cellView = (NSTextField *)[self tableView:self.jsonColorTableView viewForTableColumn:self.jsonColorTableView.tableColumns[0] row:self.jsonColorTableView.selectedRowIndexes.firstIndex];
        self.jsonTextLabelView.stringValue = cellView.stringValue;
        self.jsonTextColorWell.color = cellView.textColor;
    } else {
        self.jsonTextLabelView.stringValue = @" ";
    }
}

@end


@implementation MHPreferenceWindowController (Preferences)

+ (MHDefaultSortOrder)defaultSortOrder
{
    return (MHDefaultSortOrder)[[NSUserDefaults standardUserDefaults] integerForKey:MHDefaultSortOrderPreferenceKey];
}

+ (MODJsonKeySortOrder)jsonKeySortOrderInSearch
{
    return (MODJsonKeySortOrder)[[NSUserDefaults standardUserDefaults] integerForKey:MODJsonKeySortOrderInSearchPreferenceKey];
}

@end
