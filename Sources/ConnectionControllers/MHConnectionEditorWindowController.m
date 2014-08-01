//
//  MHConnectionEditorWindowControllerDelegate.m
//  MongoHub
//
//  Created by Jérôme Lebel on 19/08/12.
//  Copyright (c) 2012 ThePeppersStudio.COM. All rights reserved.
//

#import "MHConnectionEditorWindowController.h"
#import "MHConnectionStore.h"
#import "ConnectionsArrayController.h"
#import "MHKeychain.h"
#import <mongo-objc-driver/MOD_public.h>

#define COPY_ALIAS_SUFFIX @" - Copy"

@interface MHConnectionEditorWindowController ()
@property (nonatomic, readwrite, assign) NSTextField *hostTextField;
@property (nonatomic, readwrite, assign) NSTextField *hostportTextField;
@property (nonatomic, readwrite, assign) NSButton *usereplCheckBox;
@property (nonatomic, readwrite, assign) NSTextField *serversTextField;
@property (nonatomic, readwrite, assign) NSTextField *replnameTextField;
@property (nonatomic, readwrite, assign) NSTextField *aliasTextField;
@property (nonatomic, readwrite, assign) NSTextField *adminuserTextField;
@property (nonatomic, readwrite, assign) NSSecureTextField *adminpassTextField;
@property (nonatomic, readwrite, assign) NSTextField *defaultdbTextField;
@property (nonatomic, readwrite, assign) NSButton *useSSLCheckBox;
@property (nonatomic, readwrite, assign) NSButton *usesshCheckBox;
@property (nonatomic, readwrite, assign) NSTextField *sshhostTextField;
@property (nonatomic, readwrite, assign) NSTextField *sshportTextField;
@property (nonatomic, readwrite, assign) NSTextField *sshuserTextField;
@property (nonatomic, readwrite, assign) NSSecureTextField *sshpasswordTextField;
@property (nonatomic, readwrite, assign) NSTextField *sshkeyfileTextField;
@property (nonatomic, readwrite, assign) NSButton *selectKeyFileButton;
@property (nonatomic, readwrite, assign) NSButton *addSaveButton;
@property (nonatomic, readwrite, assign) NSPopUpButton *defaultReadModePopUpButton;

@property (nonatomic, readwrite, assign, getter=isNewConnetion) BOOL newConnection;

@end

static NSInteger tagFromPreferenceReadMode(MODReadPreferencesReadMode readMode)
{
    switch (readMode) {
        case MODReadPreferencesReadPrimaryMode:
            return 0;
            break;
        case MODReadPreferencesReadSecondaryMode:
            return 1;
            break;
        case MODReadPreferencesReadPrimaryPreferredMode:
            return 2;
            break;
        case MODReadPreferencesReadSecondaryPreferredMode:
            return 3;
            break;
        case MODReadPreferencesReadNearestMode:
            return 4;
            break;
    }
    return 0;
}

static MODReadPreferencesReadMode preferenceReadModeFromTag(NSInteger tag)
{
    switch (tag) {
        default:
        case 0:
            return MODReadPreferencesReadPrimaryMode;
            break;
        case 1:
            return MODReadPreferencesReadSecondaryMode;
            break;
        case 2:
            return MODReadPreferencesReadPrimaryPreferredMode;
            break;
        case 3:
            return MODReadPreferencesReadSecondaryPreferredMode;
            break;
        case 4:
            return MODReadPreferencesReadNearestMode;
            break;
    }
}

@implementation MHConnectionEditorWindowController

@synthesize editedConnectionStore = _editedConnectionStore;
@synthesize delegate = _delegate;
@synthesize newConnection = _newConnection;
@synthesize connectionStoreDefaultValue = _connectionStoreDefaultValue;

@synthesize hostTextField = _hostTextField, hostportTextField = _hostportTextField, usereplCheckBox = _usereplCheckBox, serversTextField = _serversTextField, replnameTextField = _replnameTextField, aliasTextField = _aliasTextField, adminuserTextField = _adminuserTextField, adminpassTextField = _adminpassTextField, defaultdbTextField = _defaultdbTextField, usesshCheckBox = _usesshCheckBox, sshhostTextField = _sshhostTextField, sshportTextField = _sshportTextField, sshuserTextField = _sshuserTextField, sshpasswordTextField = _sshpasswordTextField, sshkeyfileTextField = _sshkeyfileTextField, selectKeyFileButton = _selectKeyFileButton, addSaveButton = _addSaveButton, defaultReadModePopUpButton = _defaultReadModePopUpButton, useSSLCheckBox = _useSSLCheckBox;

- (id)init
{
    self = [super initWithWindowNibName:@"MHConnectionEditorWindowController"];
    return self;
}

- (void)dealloc
{
    self.connectionStoreDefaultValue = nil;
    self.editedConnectionStore = nil;
    [super dealloc];
}

- (void)windowDidLoad
{
    MHConnectionStore *defaultValue = (self.editedConnectionStore == nil)?self.connectionStoreDefaultValue:self.editedConnectionStore;
    
    [self.hostportTextField.cell setPlaceholderString:[NSString stringWithFormat:@"%d", MODClient.defaultPort]];
    [self.sshuserTextField.cell setPlaceholderString:[NSProcessInfo.processInfo.environment objectForKey:@"USER"]];
    if (self.editedConnectionStore) {
        self.addSaveButton.title = NSLocalizedString(@"Save", @"Save connection (after updating)");
        self.newConnection = NO;
    } else {
        self.newConnection = YES;
        self.addSaveButton.title = NSLocalizedString(@"Add", @"Add connection");
    }
    if (defaultValue) {
        if (self.newConnection) {
            NSCharacterSet *numberOrWhiteSpace = [NSCharacterSet characterSetWithCharactersInString:@"1234567890 "];
            NSString *baseAlias = defaultValue.alias;
            NSString *alias;
            NSUInteger index = 1;
            
            while ([numberOrWhiteSpace characterIsMember:[baseAlias characterAtIndex:baseAlias.length - 1]]) {
                baseAlias = [baseAlias substringToIndex:baseAlias.length - 1];
            }
            if ([baseAlias hasSuffix:COPY_ALIAS_SUFFIX]) {
                baseAlias = [baseAlias substringToIndex:baseAlias.length - COPY_ALIAS_SUFFIX.length];
                alias = [NSString stringWithFormat:@"%@%@ %lu", baseAlias, COPY_ALIAS_SUFFIX, (unsigned long)index];
                index++;
            } else {
                baseAlias = defaultValue.alias;
                alias = [NSString stringWithFormat:@"%@%@", defaultValue.alias, COPY_ALIAS_SUFFIX];
            }
            while ([self connectionStoreWithAlias:alias] != nil) {
                alias = [NSString stringWithFormat:@"%@%@ %lu", baseAlias, COPY_ALIAS_SUFFIX, (unsigned long)index];
                index++;
            }
            self.aliasTextField.stringValue = alias;
        } else {
            self.aliasTextField.stringValue = defaultValue.alias;
        }
        self.window.title = self.aliasTextField.stringValue;
        self.hostTextField.stringValue = defaultValue.host;
        if (defaultValue.hostport.stringValue.longLongValue == 0) {
            self.hostportTextField.stringValue = @"";
        } else {
            self.hostportTextField.stringValue = defaultValue.hostport.stringValue;
        }
        if (defaultValue.servers) self.serversTextField.stringValue = defaultValue.servers;
        if (defaultValue.repl_name) self.replnameTextField.stringValue = defaultValue.repl_name;
        self.usereplCheckBox.state = defaultValue.userepl.boolValue?NSOnState:NSOffState;
        if (defaultValue.adminuser) self.adminuserTextField.stringValue = defaultValue.adminuser;
        if (defaultValue.adminpass) self.adminpassTextField.stringValue = defaultValue.adminpass;
        if (defaultValue.defaultdb) self.defaultdbTextField.stringValue = defaultValue.defaultdb;
        if (defaultValue.sshhost) self.sshhostTextField.stringValue = defaultValue.sshhost;
        if (defaultValue.sshport.stringValue.longLongValue == 0) {
            self.sshportTextField.stringValue = @"";
        } else {
            self.sshportTextField.stringValue = defaultValue.sshport.stringValue;
        }
        if (defaultValue.sshuser) self.sshuserTextField.stringValue = defaultValue.sshuser;
        if (defaultValue.usessh && defaultValue.sshpassword) self.sshpasswordTextField.stringValue = defaultValue.sshpassword;
        if (defaultValue.sshkeyfile) self.sshkeyfileTextField.stringValue = defaultValue.sshkeyfile;
        self.usesshCheckBox.state = defaultValue.usessh.boolValue?NSOnState:NSOffState;
        [self.defaultReadModePopUpButton selectItemWithTag:tagFromPreferenceReadMode(defaultValue.defaultReadMode)];
        self.useSSLCheckBox.state = defaultValue.usessl.boolValue;
    } else {
        self.window.title = NSLocalizedString(@"New Connection", @"New Connection");
        self.hostTextField.stringValue = @"";
        self.hostportTextField.stringValue = @"";
        self.serversTextField.stringValue = @"";
        self.replnameTextField.stringValue = @"";
        self.usereplCheckBox.state = NSOffState;
        self.aliasTextField.stringValue = @"";
        self.adminuserTextField.stringValue = @"";
        self.adminpassTextField.stringValue = @"";
        self.defaultdbTextField.stringValue = @"";
        self.sshhostTextField.stringValue = @"";
        self.sshportTextField.stringValue = @"";
        self.sshuserTextField.stringValue = @"";
        self.sshpasswordTextField.stringValue = @"";
        self.sshkeyfileTextField.stringValue = @"";
        self.useSSLCheckBox.state = NSOffState;
        self.usesshCheckBox.state = NSOffState;
        [self.defaultReadModePopUpButton selectItemWithTag:0];
    }
    self.sshhostTextField.enabled = self.usereplCheckBox.state == NSOnState;
    self.sshuserTextField.enabled = self.usereplCheckBox.state == NSOnState;
    self.sshportTextField.enabled = self.usereplCheckBox.state == NSOnState;
    self.sshpasswordTextField.enabled = self.usereplCheckBox.state == NSOnState;
    self.sshkeyfileTextField.enabled = self.usereplCheckBox.state == NSOnState;
    self.selectKeyFileButton.enabled = self.usereplCheckBox.state == NSOnState;
    self.serversTextField.enabled = self.usereplCheckBox.state == NSOnState;
    self.replnameTextField.enabled = self.usereplCheckBox.state == NSOnState;
    [self _updateSSHFields];
    [self _updateReplFields];
    [super windowDidLoad];
}

- (void)modalForWindow:(NSWindow *)window
{
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self.window orderOut:self];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.delegate.managedObjectContext;
}

- (ConnectionsArrayController *)connectionsArrayController
{
    return self.delegate.connectionsArrayController;
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate connectionWindowControllerDidCancel:self];
    [NSApp endSheet:self.window];
}

- (MHConnectionStore *)connectionStoreWithAlias:(NSString *)alias
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alias=%@", alias];
    NSArray *items = [self.connectionsArrayController itemsUsingFetchPredicate:predicate];
    return (items.count == 1)?[items objectAtIndex:0]:nil;
}

- (IBAction)addSaveAction:(id)sender
{
    NSString *hostName;
    NSInteger hostPort;
    NSInteger sshPort;
    NSString *defaultdb;
    NSString *alias;
    NSString *sshHost;
    NSString *replicaServers;
    NSString *replicaName;
    BOOL useSSH;
    BOOL useReplica;
    
    hostName = [self.hostTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hostPort = self.hostportTextField.stringValue.integerValue;
    defaultdb = [self.defaultdbTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    alias = [self.aliasTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sshHost = [self.sshhostTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    useSSH = self.usesshCheckBox.state == NSOnState;
    useReplica = self.usereplCheckBox.state == NSOnState;
    replicaServers = [self.serversTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    replicaName = [self.replnameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sshPort = self.sshportTextField.stringValue.integerValue;
    
    if ([hostName isEqualToString:@"flame.mongohq.com"] && defaultdb.length == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"DB should not be empty if you are using mongohq", @""));
        return;
    }
    if (hostPort < 0 || hostPort > 65535) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Host port should be between 1 and 65535 (or empty)", @""));
        return;
    }
    if (alias.length < 1) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Name should not be less than 1 charaters", @""));
        return;
    }
    if (useSSH && sshHost.length == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Tunneling requires SSH Host!", @""));
        return;
    }
    if (useSSH && (sshPort < 0 || sshPort > 65535)) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"ssh port should be between 1 and 65535 (or empty)", @""));
        return;
    }
    if (useReplica && (replicaServers.length == 0 || replicaName.length == 0)) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Name already in use!", @""));
        return;
    }
    MHConnectionStore *sameAliasConnection = [self connectionStoreWithAlias:alias];
    if (sameAliasConnection && sameAliasConnection != self.editedConnectionStore) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Name already in use!", @""));
        return;
    }
    if (!self.editedConnectionStore) {
        self.editedConnectionStore = [[self.connectionsArrayController newObject] retain];
    }
    self.editedConnectionStore.host = hostName;
    self.editedConnectionStore.hostport = [NSNumber numberWithLongLong:hostPort];
    self.editedConnectionStore.servers = replicaServers;
    self.editedConnectionStore.repl_name = replicaName;
    self.editedConnectionStore.userepl = [NSNumber numberWithBool:useReplica];
    self.editedConnectionStore.alias = alias;
    self.editedConnectionStore.adminuser = [self.adminuserTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.editedConnectionStore.adminpass = self.adminpassTextField.stringValue;
    self.editedConnectionStore.defaultdb = defaultdb;
    self.editedConnectionStore.usessl = [NSNumber numberWithBool:self.useSSLCheckBox.state == NSOnState];
    self.editedConnectionStore.usessh = [NSNumber numberWithBool:useSSH];
    self.editedConnectionStore.sshhost = sshHost;
    self.editedConnectionStore.sshport = [NSNumber numberWithLongLong:sshPort];
    self.editedConnectionStore.sshuser = self.sshuserTextField.stringValue;
    self.editedConnectionStore.sshpassword = self.sshpasswordTextField.stringValue;
    self.editedConnectionStore.sshkeyfile = self.sshkeyfileTextField.stringValue;
    self.editedConnectionStore.defaultReadMode = preferenceReadModeFromTag(self.defaultReadModePopUpButton.selectedTag);
    if (self.newConnection) {
        [self.connectionsArrayController addObject:self.editedConnectionStore];
    }
    [self.delegate connectionWindowControllerDidValidate:self];
    [NSApp endSheet:self.window];
}

- (IBAction)enableSSH:(id)sender
{
    [self _updateSSHFields];
}

- (IBAction)enableRepl:(id)sender
{
    [self _updateReplFields];
}

- (IBAction)chooseKeyPathAction:(id)sender
{
    NSOpenPanel *tvarNSOpenPanelObj = [NSOpenPanel openPanel];
    NSInteger tvarNSInteger = [tvarNSOpenPanelObj runModal];
    if (tvarNSInteger == NSOKButton) {
        NSLog(@"doOpen we have an OK button");
        //NSString * tvarDirectory = [tvarNSOpenPanelObj directory];
        //NSLog(@"doOpen directory = %@",tvarDirectory);
        NSString * tvarFilename = [[tvarNSOpenPanelObj URL] path];
        NSLog(@"doOpen filename = %@",tvarFilename);
        [self.sshkeyfileTextField setStringValue:tvarFilename];
    } else if (tvarNSInteger == NSCancelButton) {
        NSLog(@"doOpen we have a Cancel button");
        return;
    } else {
        NSLog(@"doOpen tvarInt not equal 1 or zero = %ld",(long int)tvarNSInteger);
        return;
    } // end if
}

- (void)_updateSSHFields
{
    BOOL useSSH;
    
    useSSH = self.usesshCheckBox.state == NSOnState;
    self.sshhostTextField.enabled = useSSH;
    self.sshuserTextField.enabled = useSSH;
    self.sshportTextField.enabled = useSSH;
    self.sshpasswordTextField.enabled = useSSH;
    self.sshkeyfileTextField.enabled = useSSH;
    self.selectKeyFileButton.enabled = useSSH;
}

- (void)_updateReplFields
{
    BOOL useRepl;
    
    useRepl = self.usereplCheckBox.state == NSOnState;
    self.serversTextField.enabled = useRepl;
    self.replnameTextField.enabled = useRepl;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    if (control == self.sshhostTextField || control == self.sshportTextField || control == self.sshuserTextField) {
        NSString *password = nil;
        
        if (self.sshhostTextField.stringValue.length > 0) {
            password = [MHKeychain internetPasswordProtocol:kSecAttrProtocolSSH host:self.sshhostTextField.stringValue port:self.sshportTextField.integerValue account:self.sshuserTextField.stringValue];
        }
        if (password) {
            self.sshpasswordTextField.stringValue = password;
        } else {
            self.sshpasswordTextField.stringValue = @"";
        }
    }
    return YES;
}

@end
