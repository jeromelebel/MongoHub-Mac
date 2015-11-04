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
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *aliasTextField;

@property (nonatomic, readwrite, weak) IBOutlet NSPopUpButton *singleReplicaSetPopUpButton;
@property (nonatomic, readwrite, weak) IBOutlet NSTabView *singleReplicaSetTabView;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField *hostTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *hostportTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *slaveOkButton;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField *replicaSetServersTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *replicaSetNameTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSPopUpButton *defaultReadModePopUpButton;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField *shardedClusterServersTextField;

@property (nonatomic, readwrite, weak) IBOutlet NSTextField *adminUserTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSSecureTextField *adminPasswordTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *defaultDatabaseTextField;

@property (nonatomic, readwrite, weak) IBOutlet NSButton *useSSLCheckbox;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *weakCertificateCheckbox;

@property (nonatomic, readwrite, weak) IBOutlet NSButton *useSSHCheckBox;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *sshHostTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *sshPortTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *sshUserTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSSecureTextField *sshPasswordTextField;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *sshKeyfileTextField;

@property (nonatomic, readwrite, weak) IBOutlet NSButton *selectKeyFileButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *addSaveButton;

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

@synthesize delegate = _delegate;

@synthesize aliasTextField = _aliasTextField;

@synthesize singleReplicaSetPopUpButton = _singleReplicaSetPopUpButton;
@synthesize singleReplicaSetTabView = _singleReplicaSetTabView;

@synthesize hostTextField = _hostTextField;
@synthesize hostportTextField = _hostportTextField;
@synthesize slaveOkButton = _slaveOkButton;

@synthesize replicaSetServersTextField = _replicaSetServersTextField;
@synthesize replicaSetNameTextField = _replicaSetNameTextField;
@synthesize defaultReadModePopUpButton = _defaultReadModePopUpButton;

@synthesize shardedClusterServersTextField = _shardedClusterServersTextField;

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

- (instancetype)init
{
    self = [super initWithWindowNibName:@"MHConnectionEditorWindow"];
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
            while ([self.delegate connectionWindowController:self connectionStoreWithAlias:alias] != nil) {
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
            self.hostTextField.stringValue = [MHConnectionStore hostnameFromServer:defaultValue.servers withPort:&port];
            if (port != 0) {
                self.hostportTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)port];
            }
        }
        self.slaveOkButton.state = defaultValue.slaveOK.boolValue?NSOnState:NSOffState;
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
        self.slaveOkButton.state = NSOffState;
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
    [self.window beginSheet:self.window completionHandler:^(NSModalResponse returnCode) {
            [self.window orderOut:self];
    }];
    
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
    if (self.window.isSheet) {
        [NSApp endSheet:self.window];
    } else {
        [self.window close];
    }
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
    NSInteger hostPort;
    NSInteger sshPort;
    NSString *defaultDatabase;
    NSString *alias;
    NSString *sshHost;
    NSString *replicaServers;
    NSString *replicaName;
    BOOL useSSH;
    BOOL useReplicaSet;
    
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
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"Host port should be between 1 and 65535 (or empty)", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
        [self.hostportTextField becomeFirstResponder];
        return;
    }
    if (alias.length == 0) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"Name should not be less than 1 charaters", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.aliasTextField becomeFirstResponder];
        return;
    }
    if (useSSH && sshHost.length == 0) {
       
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"Tunneling requires SSH Host!", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.sshHostTextField becomeFirstResponder];
        return;
    }
    if (useSSH && (sshPort < 0 || sshPort > 65535)) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"ssh port should be between 1 and 65535 (or empty)", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.sshPortTextField becomeFirstResponder];
        return;
    }
    if (useReplicaSet && [replicaServers componentsSeparatedByString:@","].count <= 1) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"You need to set more than one server", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.replicaSetServersTextField becomeFirstResponder];
        return;
    }
    if (useReplicaSet && replicaName.length == 0) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"You need to set a replica set name", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.replicaSetNameTextField becomeFirstResponder];
        return;
    }
    if (self.adminPasswordTextField.stringValue.length > 0 && self.adminUserTextField.stringValue == 0) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"You need set a user name if you enter a password", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.adminUserTextField becomeFirstResponder];
        return;
    }
    MHConnectionStore *sameAliasConnection = [self.delegate connectionWindowController:self connectionStoreWithAlias:alias];
    if (sameAliasConnection && sameAliasConnection != self.editedConnectionStore) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:NSLocalizedString(@"Name already in use!", @"")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        [self.aliasTextField becomeFirstResponder];
        return;
    }
    if (!self.editedConnectionStore) {
        self.editedConnectionStore = [self.connectionsArrayController.newObject autorelease];
    }
    if (useReplicaSet) {
        self.editedConnectionStore.replicaSetName = replicaName;
    } else {
        self.editedConnectionStore.replicaSetName = nil;
    }
    self.editedConnectionStore.alias = alias;
    self.editedConnectionStore.servers = self.servers;
    self.editedConnectionStore.slaveOK = (self.slaveOkButton.state == NSOnState)?@YES:@NO;
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
    
    NSString *urlString;
    MODClient *client;
    urlString = [self.editedConnectionStore stringURLWithSSHMapping:nil];
    client = [MODClient clientWihtURLString:urlString];
    if (client == nil) {
       
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:NSLocalizedString(@"Error", @"Error")];
        [alert setInformativeText:[NSString stringWithFormat:@"Invalid URL %@", urlString]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
        return;
    }
    
    if (self.newConnection) {
        [self.connectionsArrayController addObject:self.editedConnectionStore];
    }
    [self.delegate connectionWindowControllerDidValidate:self];
    if (self.window.isSheet) {
        [NSApp endSheet:self.window];
    } else {
        [self.window close];
    }
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
    
    if (openPanel.runModal == NSModalResponseOK) {
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
        self.defaultReadModePopUpButton.nextKeyView = self.adminUserTextField;
    } else if (self.singleReplicaSetPopUpButton.selectedTag == 0) {
        self.singleReplicaSetPopUpButton.nextKeyView = self.hostTextField;
        self.slaveOkButton.nextKeyView = self.adminUserTextField;
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
    } else if (control == self.replicaSetServersTextField) {
        if ([self.replicaSetServersTextField.stringValue hasPrefix:MONGODB_SCHEME]) {
            self.replicaSetServersTextField.stringValue = [self.replicaSetServersTextField.stringValue substringFromIndex:MONGODB_SCHEME.length];
        }
    } else if (control == self.shardedClusterServersTextField) {
        if ([self.shardedClusterServersTextField.stringValue hasPrefix:MONGODB_SCHEME]) {
            self.shardedClusterServersTextField.stringValue = [self.shardedClusterServersTextField.stringValue substringFromIndex:MONGODB_SCHEME.length];
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
