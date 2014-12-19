//
//  MHIndexEditorController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 18/12/2014.
//
//

#import "MHIndexEditorController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>

#define POPUP_BUTTON_ASCENDING_SORTING          0
#define POPUP_BUTTON_DESCENDING_SORTING         1
#define POPUP_BUTTON_HASHED_SORTING             2


@interface MHIndexEditorController ()
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *nameTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *backgroundButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *dropDuplicatesButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *isInitializedButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *sparseButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *uniqueButton;
@property (nonatomic, readwrite, weak) IBOutlet NSTableView *keyTableView;

@property (nonatomic, readwrite, weak) IBOutlet NSButton *addKeyButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *removeKeyButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *cancelButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *okButton;

@property (nonatomic, readwrite, strong) MODSortedDictionary *editedIndex;
@property (nonatomic, readwrite, strong) NSMutableArray *indexKeys;

@end

@interface MHIndexEditorController (NSTableViewDataSource) <NSTableViewDataSource>
@end

@interface MHIndexEditorController (NSTableViewDelegate) <NSTableViewDelegate>
@end

@implementation MHIndexEditorController
@synthesize nameTextField = _nameTextField;
@synthesize backgroundButton = _backgroundButton;
@synthesize dropDuplicatesButton = _dropDuplicatesButton;
@synthesize isInitializedButton = _isInitializedButton;
@synthesize sparseButton = _sparseButton;
@synthesize uniqueButton = _uniqueButton;
@synthesize keyTableView = _keyTableView;

@synthesize addKeyButton = _addKeyButton;
@synthesize removeKeyButton = _removeKeyButton;
@synthesize cancelButton = _cancelButton;
@synthesize okButton = _okButton;

@synthesize editedIndex = _editedIndex;
@synthesize indexKeys = _indexKeys;

@synthesize delegate = _delegate;

- (id)init
{
    if (self = [super init]) {
        self.indexKeys = [NSMutableArray array];
    }
    return self;
}

- (id)initWithEditedIndex:(MODSortedDictionary *)index
{
    if (self = [self init]) {
        MODSortedDictionary *keys;
        
        self.editedIndex = index;
        keys = [index objectForKey:@"key"];
        for (NSString *keyName in keys) {
            NSNumber *value;
            
            if ([[keys objectForKey:keyName] isEqual:@"hashed"]) {
                value = @POPUP_BUTTON_HASHED_SORTING;
            } else if ([[keys objectForKey:keyName] integerValue] == 1) {
                value = @POPUP_BUTTON_ASCENDING_SORTING;
            } else {
                value = @POPUP_BUTTON_DESCENDING_SORTING;
            }
            [self.indexKeys addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:keyName, @"name", value, @"sorting", nil]];
        }
    }
    return self;
}

- (void)dealloc
{
    self.indexKeys = nil;
    self.editedIndex = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self.editedIndex) {
        if ([self.editedIndex objectForKey:@"name"]) {
            self.nameTextField.stringValue = [self.editedIndex objectForKey:@"name"];
        }
        self.backgroundButton.state = ([[self.editedIndex objectForKey:@"background"] integerValue] == 1?NSOnState:NSOffState);
        self.dropDuplicatesButton.state = ([[self.editedIndex objectForKey:@"dropDups"] integerValue] == 1?NSOnState:NSOffState);
        self.sparseButton.state = ([[self.editedIndex objectForKey:@"sparse"] integerValue] == 1?NSOnState:NSOffState);
        self.uniqueButton.state = ([[self.editedIndex objectForKey:@"unique"] integerValue] == 1?NSOnState:NSOffState);
    } else {
        self.backgroundButton.state = NSOffState;
        self.dropDuplicatesButton.state = NSOffState;
        self.isInitializedButton.state = NSOffState;
        self.sparseButton.state = NSOffState;
        self.uniqueButton.state = NSOffState;
    }
    [self updateViews];
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
    [menu itemAtIndex:0].enabled = YES;
    [menu itemAtIndex:1].enabled = YES;
    [menu itemAtIndex:2].enabled = (self.indexKeys.count == 1);
}

- (IBAction)flagButtonAction:(id)sender
{
    [self updateViews];
}

- (void)updateViews
{
    self.dropDuplicatesButton.enabled = self.uniqueButton.state == NSOnState;
    if (self.uniqueButton.state == NSOffState) {
        self.dropDuplicatesButton.state = NSOffState;
    }
    self.okButton.enabled = self.indexKeys.count > 0;
    self.removeKeyButton.enabled = self.keyTableView.numberOfSelectedRows > 0;
    self.addKeyButton.enabled = (self.indexKeys.count != 1) || ([[self.indexKeys[0] objectForKey:@"sorting"] integerValue] != 2);
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (NSString *)windowNibName
{
    return @"MHIndexEditor";
}

- (void)modalForWindow:(NSWindow *)window
{
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)addIndexKey:(id)sender
{
    [self.indexKeys addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"<index>", @"name", @0, @"sorting", nil]];
    [self.keyTableView reloadData];
    [self updateViews];
    [self.keyTableView editColumn:0 row:self.indexKeys.count - 1 withEvent:nil select:YES];
}

- (IBAction)removeIndexKey:(id)sender
{
    if (self.keyTableView.numberOfSelectedRows == 1) {
        [self.indexKeys removeObjectAtIndex:self.keyTableView.selectedRow];
        [self.keyTableView reloadData];
        [self updateViews];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [NSApp endSheet:self.window returnCode:0];
}


- (IBAction)okAction:(id)sender
{
    [NSApp endSheet:self.window returnCode:1];
}

- (void)didEndSheet:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self.window orderOut:self];
    if (returnCode == 1) {
        [self.delegate indexEditorControllerDidValidate:self];
    } else {
        [self.delegate indexEditorControllerDidCancel:self];
    }
}

- (MODIndexOpt *)indexOptions
{
    MODIndexOpt *result;
    
    result = [[[MODIndexOpt alloc] init] autorelease];
    if (self.nameTextField.stringValue.length > 0) {
        result.name = self.nameTextField.stringValue;
    }
    result.background = self.backgroundButton.state == NSOnState;
    result.dropDups = self.dropDuplicatesButton.state == NSOnState;
    result.isInitialized = self.isInitializedButton.state == NSOnState;
    result.sparse = self.sparseButton.state == NSOnState;
    result.unique = self.uniqueButton.state == NSOnState;
    return result;
}

- (MODSortedDictionary *)keys
{
    MODSortedMutableDictionary *result;
    
    result = [MODSortedMutableDictionary sortedDictionary];
    for (NSDictionary *key in self.indexKeys) {
        id value = nil;
        
        switch ([key[@"sorting"] integerValue]) {
            case POPUP_BUTTON_ASCENDING_SORTING:
                value = @1;
                break;
            case POPUP_BUTTON_HASHED_SORTING:
                value = @"hashed";
                break;
            case POPUP_BUTTON_DESCENDING_SORTING:
                value = @-1;
                break;
        }
        NSAssert(value != nil, @"weird value %@", key[@"sorting"]);
        [result setObject:value forKey:key[@"name"]];
    }
    return result;
}

@end


@implementation MHIndexEditorController (NSTableViewDataSource)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.indexKeys.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.indexKeys[row] objectForKey:tableColumn.identifier];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [self.indexKeys[row] setObject:object forKey:tableColumn.identifier];
    [self updateViews];
}

@end

@implementation MHIndexEditorController (NSTableViewDelegate)

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self updateViews];
}

@end
