//
//  MHConnectionEditorWindowControllerDelegate.m
//  MongoHub
//
//  Created by Jérôme Lebel on 19/08/2012.
//

#import "MHConnectionEditorWindowController.h"
#import "MHConnectionStore.h"
#import "ConnectionsArrayController.h"
#import "MHKeychain.h"
#import <MongoObjCDriver/MongoObjCDriver.h>

#define COPY_ALIAS_SUFFIX @" - Copy"
#define SINGLESERVER_TAB_IDENTIER           @"singleserver"
#define REPLICASET_TAB_IDENTIER             @"replicaset"
#define SHARDEDCLUSTER_TAB_IDENTIER         @"shardedcluster"

@interface MHConnectionEditorWindowController ()
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *aliasTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *adminUserTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSSecureTextField *adminPasswordTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSPopUpButton *singleReplicaSetPopUpButton;
@property (nonatomic, readwrite, assign) IBOutlet NSTabView *singleReplicaSetTabView;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *hostTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *hostportTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *replicaSetServersTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *replicaSetNameTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *shardedClusterServersTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *defaultDatabaseTextField;

@property (nonatomic, readwrite, assign) IBOutlet NSButton *useSSLCheckbox;
@property (nonatomic, readwrite, assign) IBOutlet NSButton *weakCertificateCheckbox;

@property (nonatomic, readwrite, assign) IBOutlet NSButton *useSSHCheckBox;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *sshHostTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *sshPortTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *sshUserTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSSecureTextField *sshPasswordTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *sshKeyfileTextField;
@property (nonatomic, readwrite, assign) IBOutlet NSButton *selectKeyFileButton;
@property (nonatomic, readwrite, assign) IBOutlet NSButton *addSaveButton;
@property (nonatomic, readwrite, assign) IBOutlet NSPopUpButton *defaultReadModePopUpButton;

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

@synthesize hostTextField = _hostTextField;
@synthesize hostportTextField = _hostportTextField;
@synthesize replicaSetServersTextField = _replicaSetServersTextField;
@synthesize replicaSetNameTextField = _replicaSetNameTextField;
@synthesize shardedClusterServersTextField = _shardedClusterServersTextField;
@synthesize aliasTextField = _aliasTextField;
@synthesize adminUserTextField = _adminUserTextField;
@synthesize adminPasswordTextField = _adminPasswordTextField;
@synthesize defaultDatabaseTextField = _defaultDatabaseTextField;
@synthesize useSSLCheckbox = _useSSLCheckbox;
@synthesize weakCertificateCheckbox = _weakCertificateCheckbox;
@synthesize useSSHCheckBox = _useSSHCheckBox;
@synthesize sshHostTextField = _sshHostTextField;
@synthesize sshPortTextField = _sshPortTextField;
@synthesize sshUserTextField = _sshUserTextField;
@synthesize sshPasswordTextField = _sshPasswordTextField;
@synthesize sshKeyfileTextField = _sshKeyfileTextField;
@synthesize selectKeyFileButton = _selectKeyFileButton;
@synthesize addSaveButton = _addSaveButton;
@synthesize defaultReadModePopUpButton = _defaultReadModePopUpButton;
@synthesize singleReplicaSetPopUpButton = _singleReplicaSetPopUpButton;
@synthesize singleReplicaSetTabView = _singleReplicaSetTabView;

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
    [self.sshUserTextField.cell setPlaceholderString:[NSProcessInfo.processInfo.environment objectForKey:@"USER"]];
    if (self.editedConnectionStore) {
        self.addSaveButton.title = NSLocalizedString(@"Save", @"Save connection (after updating)");
        self.newConnection = NO;
    } else {
        self.newConnection = YES;
        self.addSaveButton.title = NSLocalizedString(@"Add", @"Add connection");
    }
    if (defaultValue) {
        if (self.newConnection && defaultValue.alias.length > 0) {
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
        } else if (defaultValue.alias) {
            self.aliasTextField.stringValue = defaultValue.alias;
        }
        self.window.title = self.aliasTextField.stringValue;
        if (defaultValue.replicaSetName.length > 0) {
            [self.singleReplicaSetPopUpButton selectItemAtIndex:1];
            [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:REPLICASET_TAB_IDENTIER];
            if (defaultValue.servers) self.replicaSetServersTextField.stringValue = defaultValue.servers;
            if (defaultValue.replicaSetName) self.replicaSetNameTextField.stringValue = defaultValue.replicaSetName;
        } else if ([MHConnectionStore  splitServers:defaultValue.servers].count > 1) {
            [self.singleReplicaSetPopUpButton selectItemAtIndex:2];
            [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:SHARDEDCLUSTER_TAB_IDENTIER];
            self.shardedClusterServersTextField.stringValue = defaultValue.servers;
        } else {
            NSInteger port;
            
            [self.singleReplicaSetPopUpButton selectItemAtIndex:0];
            [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:SINGLESERVER_TAB_IDENTIER];
            self.hostTextField.stringValue = [MHConnectionStore hostnameFromServer:defaultValue.servers WithPort:&port];
            if (port != 0) {
                self.hostportTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)port];
            }
        }
        if (defaultValue.adminUser) self.adminUserTextField.stringValue = defaultValue.adminUser;
        if (defaultValue.adminPassword) self.adminPasswordTextField.stringValue = defaultValue.adminPassword;
        if (defaultValue.defaultDatabase) self.defaultDatabaseTextField.stringValue = defaultValue.defaultDatabase;
        if (defaultValue.sshHost) self.sshHostTextField.stringValue = defaultValue.sshHost;
        if (defaultValue.sshPort.stringValue.longLongValue == 0) {
            self.sshPortTextField.stringValue = @"";
        } else {
            self.sshPortTextField.stringValue = defaultValue.sshPort.stringValue;
        }
        if (defaultValue.sshUser) self.sshUserTextField.stringValue = defaultValue.sshUser;
        if (defaultValue.useSSH.boolValue && defaultValue.sshPassword) {
            // there is no need to fetch for the ssh password if ssh is turned off
            // let's fetch for it, when the user will turn on ssh
            // (we keep the ssh settings even if it is turned off)
            self.sshPasswordTextField.stringValue = defaultValue.sshPassword;
        }
        if (defaultValue.sshKeyFileName) self.sshKeyfileTextField.stringValue = defaultValue.sshKeyFileName;
        self.useSSHCheckBox.state = defaultValue.useSSH.boolValue?NSOnState:NSOffState;
        [self.defaultReadModePopUpButton selectItemWithTag:tagFromPreferenceReadMode(defaultValue.defaultReadMode)];
        self.useSSLCheckbox.state = defaultValue.useSSL.boolValue?NSOnState:NSOffState;
        self.weakCertificateCheckbox.state = defaultValue.weakCertificate.boolValue?NSOnState:NSOffState;
    } else {
        self.window.title = NSLocalizedString(@"New Connection", @"New Connection");
        self.hostTextField.stringValue = @"";
        self.hostportTextField.stringValue = @"";
        self.replicaSetServersTextField.stringValue = @"";
        self.replicaSetNameTextField.stringValue = @"";
        self.aliasTextField.stringValue = @"";
        self.adminUserTextField.stringValue = @"";
        self.adminPasswordTextField.stringValue = @"";
        self.defaultDatabaseTextField.stringValue = @"";
        self.sshHostTextField.stringValue = @"";
        self.sshPortTextField.stringValue = @"";
        self.sshUserTextField.stringValue = @"";
        self.sshPasswordTextField.stringValue = @"";
        self.sshKeyfileTextField.stringValue = @"";
        self.useSSLCheckbox.state = NSOffState;
        self.weakCertificateCheckbox.state = NSOffState;
        self.useSSHCheckBox.state = NSOffState;
        [self.defaultReadModePopUpButton selectItemWithTag:0];
        [self.singleReplicaSetPopUpButton selectItemAtIndex:0];
        [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:SINGLESERVER_TAB_IDENTIER];
    }
    [self _updateSSLFields];
    [self _updateSSHFields];
    [self _updateServerFields];
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

- (IBAction)singleServerReplicaSetChoiceAction:(id)sender
{
    if ([self.singleReplicaSetTabView.selectedTabViewItem.identifier isEqualTo:SHARDEDCLUSTER_TAB_IDENTIER]
        && self.shardedClusterServersTextField.stringValue) {
        self.replicaSetServersTextField.stringValue = self.shardedClusterServersTextField.stringValue;
    } else if ([self.singleReplicaSetTabView.selectedTabViewItem.identifier isEqualTo:REPLICASET_TAB_IDENTIER]
        && self.replicaSetServersTextField.stringValue) {
        self.shardedClusterServersTextField.stringValue = self.replicaSetServersTextField.stringValue;
    }
    if (self.singleReplicaSetPopUpButton.selectedTag == 0) {
        [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:SINGLESERVER_TAB_IDENTIER];
    } else if (self.singleReplicaSetPopUpButton.selectedTag == 1) {
        [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:REPLICASET_TAB_IDENTIER];
    } else if (self.singleReplicaSetPopUpButton.selectedTag == 2) {
        [self.singleReplicaSetTabView selectTabViewItemWithIdentifier:SHARDEDCLUSTER_TAB_IDENTIER];
    } else {
        NSAssert(NO, @"unknown value %ld", (long)self.singleReplicaSetPopUpButton.selectedTag);
    }
    [self _updateServerFields];
}

- (NSString *)servers
{
    NSString *hostName;
    NSInteger hostPort;
    NSString *result;
    
    hostName = [self.hostTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hostPort = self.hostportTextField.stringValue.integerValue;
    if (self.singleReplicaSetPopUpButton.selectedTag == 1 || self.singleReplicaSetPopUpButton.selectedTag == 2) {
        result = [MHConnectionStore cleanupServers:self.replicaSetServersTextField.stringValue];
    } else if (hostPort == 0) {
        result = hostName;
    } else if (hostPort > 0 && hostPort <= 65535) {
        result = [NSString stringWithFormat:@"%@:%ld", hostName, (long)hostPort];
    } else {
        result = nil;
    }
    return result;
}

- (IBAction)addSaveAction:(id)sender
{
    NSString *hostName;
    NSInteger hostPort;
    NSInteger sshPort;
    NSString *defaultDatabase;
    NSString *alias;
    NSString *sshHost;
    NSString *replicaServers;
    NSString *replicaName;
    BOOL useSSH;
    BOOL useReplicaSet;
    
    hostName = [self.hostTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hostPort = self.hostportTextField.stringValue.integerValue;
    defaultDatabase = [self.defaultDatabaseTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    alias = [self.aliasTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sshHost = [self.sshHostTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    useSSH = self.useSSHCheckBox.state == NSOnState;
    useReplicaSet = self.singleReplicaSetPopUpButton.selectedTag == 1;
    replicaServers = [MHConnectionStore cleanupServers:self.replicaSetServersTextField.stringValue];
    replicaName = [self.replicaSetNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    sshPort = self.sshPortTextField.stringValue.integerValue;
    
    if (hostPort < 0 || hostPort > 65535) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Host port should be between 1 and 65535 (or empty)", @""));
        [self.hostportTextField becomeFirstResponder];
        return;
    }
    if (alias.length == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Name should not be less than 1 charaters", @""));
        [self.aliasTextField becomeFirstResponder];
        return;
    }
    if (useSSH && sshHost.length == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Tunneling requires SSH Host!", @""));
        [self.sshHostTextField becomeFirstResponder];
        return;
    }
    if (useSSH && (sshPort < 0 || sshPort > 65535)) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"ssh port should be between 1 and 65535 (or empty)", @""));
        [self.sshPortTextField becomeFirstResponder];
        return;
    }
    if (useReplicaSet && [replicaServers componentsSeparatedByString:@","].count <= 1) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"You need to set more than one server", @""));
        [self.replicaSetServersTextField becomeFirstResponder];
        return;
    }
    if (useReplicaSet && replicaName.length == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"You need to set a replica set name", @""));
        [self.replicaSetNameTextField becomeFirstResponder];
        return;
    }
    if (self.adminPasswordTextField.stringValue.length > 0 && self.adminUserTextField.stringValue == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"You need set a user name if you enter a password", @""));
        [self.adminUserTextField becomeFirstResponder];
        return;
    }
    MHConnectionStore *sameAliasConnection = [self connectionStoreWithAlias:alias];
    if (sameAliasConnection && sameAliasConnection != self.editedConnectionStore) {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), NSLocalizedString(@"OK", @"OK"), nil, nil, self.window, nil, nil, nil, nil, NSLocalizedString(@"Name already in use!", @""));
        [self.aliasTextField becomeFirstResponder];
        return;
    }
    if (!self.editedConnectionStore) {
        self.editedConnectionStore = self.connectionsArrayController.newObject;
    }
    if (useReplicaSet) {
        self.editedConnectionStore.replicaSetName = replicaName;
    } else {
        self.editedConnectionStore.replicaSetName = nil;
    }
    self.editedConnectionStore.servers = self.servers;
    self.editedConnectionStore.alias = alias;
    self.editedConnectionStore.adminUser = self.adminUserTextField.stringValue;
    self.editedConnectionStore.adminPassword = self.adminPasswordTextField.stringValue;
    self.editedConnectionStore.defaultDatabase = defaultDatabase;
    self.editedConnectionStore.useSSL = @(self.useSSLCheckbox.state == NSOnState);
    self.editedConnectionStore.weakCertificate = @(self.weakCertificateCheckbox.state == NSOnState);
    self.editedConnectionStore.useSSH = @(useSSH);
    self.editedConnectionStore.sshHost = sshHost;
    self.editedConnectionStore.sshPort = @(sshPort);
    self.editedConnectionStore.sshUser = self.sshUserTextField.stringValue;
    self.editedConnectionStore.sshPassword = self.sshPasswordTextField.stringValue;
    self.editedConnectionStore.sshKeyFileName = self.sshKeyfileTextField.stringValue;
    self.editedConnectionStore.defaultReadMode = preferenceReadModeFromTag(self.defaultReadModePopUpButton.selectedTag);
    if (self.newConnection) {
        [self.connectionsArrayController addObject:self.editedConnectionStore];
    }
    [self.delegate connectionWindowControllerDidValidate:self];
    [NSApp endSheet:self.window];
}

- (IBAction)enableSSLAction:(id)sender
{
    [self _updateSSLFields];
}

- (IBAction)enableSSHAction:(id)sender
{
    [self _updateSSHFields];
}

- (IBAction)chooseKeyPathAction:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    if (openPanel.runModal == NSOKButton) {
        self.sshKeyfileTextField.stringValue = openPanel.URL.path;
    }
}

- (void)_updateServerFields
{
    if (self.singleReplicaSetPopUpButton.selectedTag == 2) {
        self.singleReplicaSetPopUpButton.nextKeyView = self.shardedClusterServersTextField;
        self.shardedClusterServersTextField.nextKeyView = self.adminUserTextField;
    } else if (self.singleReplicaSetPopUpButton.selectedTag == 1) {
        self.singleReplicaSetPopUpButton.nextKeyView = self.replicaSetNameTextField;
        self.replicaSetServersTextField.nextKeyView = self.adminUserTextField;
    } else if (self.singleReplicaSetPopUpButton.selectedTag == 0) {
        self.singleReplicaSetPopUpButton.nextKeyView = self.hostTextField;
        self.hostportTextField.nextKeyView = self.adminUserTextField;
    } else {
        NSAssert(NO, @"unknown value %ld", (long)self.singleReplicaSetPopUpButton.selectedTag);;
    }
}

- (void)_updateSSLFields
{
    self.weakCertificateCheckbox.enabled = self.useSSLCheckbox.state == NSOnState;
}

- (void)_updateSSHFields
{
    BOOL useSSH;
    
    useSSH = self.useSSHCheckBox.state == NSOnState;
    self.sshHostTextField.enabled = useSSH;
    self.sshUserTextField.enabled = useSSH;
    self.sshPortTextField.enabled = useSSH;
    self.sshPasswordTextField.enabled = useSSH;
    self.sshKeyfileTextField.enabled = useSSH;
    self.selectKeyFileButton.enabled = useSSH;
    if (useSSH && self.adminPasswordTextField.stringValue.length == 0) {
        // if we turn on ssh for the first time, let's try to search in the keychain to get a password
        // no need to do it before if the guy doesn't use ssh
        // (we keep the ssh settings even if it is disabled)
        [self updateSSHPassword];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    if (control == self.sshUserTextField) {
        [self updateSSHPassword];
    } else if (control == self.adminUserTextField) {
        NSString *password = nil;
        
        if (self.adminUserTextField.stringValue.length > 0) {
            password = [MHConnectionStore passwordForServers:self.servers username:self.adminUserTextField.stringValue];
        }
        if (password) {
            self.adminPasswordTextField.stringValue = password;
        } else {
            self.adminPasswordTextField.stringValue = @"";
        }
    }
    return YES;
}

- (void)updateSSHPassword
{
    NSString *password = nil;
    
    if (self.sshHostTextField.stringValue.length > 0) {
        password = [MHKeychain internetPasswordProtocol:kSecAttrProtocolSSH host:self.sshHostTextField.stringValue port:self.sshPortTextField.integerValue account:self.sshUserTextField.stringValue];
    }
    if (password) {
        self.sshPasswordTextField.stringValue = password;
    } else {
        self.sshPasswordTextField.stringValue = @"";
    }
}

@end
