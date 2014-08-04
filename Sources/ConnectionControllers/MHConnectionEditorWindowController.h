//
//  MHConnectionEditorWindowController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 19/08/12.
//  Copyright (c) 2012 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MHConnectionStore;
@class MHConnectionEditorWindowController;
@class ConnectionsArrayController;

@protocol MHConnectionEditorWindowControllerDelegate <NSObject>
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) ConnectionsArrayController *connectionsArrayController;
- (void)connectionWindowControllerDidCancel:(MHConnectionEditorWindowController *)controller;
- (void)connectionWindowControllerDidValidate:(MHConnectionEditorWindowController *)controller;
@end

@interface MHConnectionEditorWindowController : NSWindowController
{
    NSTextField                         *_hostTextField;
    NSTextField                         *_hostportTextField;
    NSButton                            *_usereplCheckBox;
    NSTextField                         *_serversTextField;
    NSPopUpButton                       *_singleReplicaSetPopUpButton;
    NSTabView                           *_singleReplicaSetTabView;
    NSTextField                         *_replnameTextField;
    NSTextField                         *_aliasTextField;
    NSTextField                         *_adminuserTextField;
    NSSecureTextField                   *_adminpassTextField;
    NSTextField                         *_defaultdbTextField;
    NSButton                            *_useSSLCheckBox;
    NSButton                            *_usesshCheckBox;
    NSTextField                         *_sshhostTextField;
    NSTextField                         *_sshportTextField;
    NSTextField                         *_sshuserTextField;
    NSSecureTextField                   *_sshpasswordTextField;
    NSTextField                         *_sshkeyfileTextField;
    NSButton                            *_selectKeyFileButton;
    NSButton                            *_addSaveButton;
    NSPopUpButton                       *_defaultReadModePopUpButton;
    
    MHConnectionStore                   *_editedConnectionStore;
    MHConnectionStore                   *_connectionStoreDefaultValue;
    BOOL                                _newConnection;
    id<MHConnectionEditorWindowControllerDelegate> _delegate;
}
@property (nonatomic, retain, readwrite) MHConnectionStore *editedConnectionStore;
@property (nonatomic, retain, readwrite) MHConnectionStore *connectionStoreDefaultValue;
@property (nonatomic, assign, readwrite) id<MHConnectionEditorWindowControllerDelegate> delegate;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign, readonly, getter=isNewConnetion) BOOL newConnection;

@property (nonatomic, readonly, assign) IBOutlet NSTextField *aliasTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *adminuserTextField;
@property (nonatomic, readonly, assign) IBOutlet NSSecureTextField *adminpassTextField;
@property (nonatomic, readonly, assign) IBOutlet NSPopUpButton *singleReplicaSetPopUpButton;
@property (nonatomic, readonly, assign) IBOutlet NSTabView *singleReplicaSetTabView;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *hostTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *hostportTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *serversTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *replnameTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *defaultdbTextField;
@property (nonatomic, readonly, assign) IBOutlet NSButton *useSSLCheckBox;
@property (nonatomic, readonly, assign) IBOutlet NSButton *usesshCheckBox;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *sshhostTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *sshportTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *sshuserTextField;
@property (nonatomic, readonly, assign) IBOutlet NSSecureTextField *sshpasswordTextField;
@property (nonatomic, readonly, assign) IBOutlet NSTextField *sshkeyfileTextField;
@property (nonatomic, readonly, assign) IBOutlet NSButton *selectKeyFileButton;
@property (nonatomic, readonly, assign) IBOutlet NSButton *addSaveButton;
@property (nonatomic, readonly, assign) IBOutlet NSPopUpButton *defaultReadModePopUpButton;
@property (nonatomic, readonly, assign) IBOutlet ConnectionsArrayController *connectionsArrayController;

- (IBAction)cancelAction:(id)sender;
- (IBAction)addSaveAction:(id)sender;
- (IBAction)chooseKeyPathAction:(id)sender;
- (void)modalForWindow:(NSWindow *)window;

@end
