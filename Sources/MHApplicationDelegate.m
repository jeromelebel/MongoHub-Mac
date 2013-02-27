//
//  MHApplicationDelegate.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright MusicPeace.ORG 2010 . All rights reserved.
//

#import "Configure.h"
#import "MHApplicationDelegate.h"
#import "MHConnectionWindowController.h"
#import "ConnectionsArrayController.h"
#import "ConnectionsCollectionView.h"
#import "MHConnectionEditorWindowController.h"
#import "MHConnectionStore.h"
#import <Sparkle/Sparkle.h>

#define YOUR_EXTERNAL_RECORD_EXTENSION @"mgo"
#define YOUR_STORE_TYPE NSXMLStoreType

@implementation MHApplicationDelegate

@synthesize window = _window;
@synthesize connectionsCollectionView;
@synthesize connectionsArrayController;
@synthesize bundleVersion;

- (void)awakeFromNib
{
    _editConnectionWindowControllers = [[NSMutableArray alloc] init];
    [connectionsArrayController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"alias" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
}

- (void)dealloc
{
    [_editConnectionWindowControllers release];
    [_window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    
    [connectionsCollectionView release];
    [connectionsArrayController release];
    
    [bundleVersion release];
    
    [super dealloc];
}

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "MongoHub" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"MongoHub"];
}

/**
    Returns the external records directory for the application.
    This code uses a directory named "MongoHub" for the content, 
    either in the ~/Library/Caches/Metadata/CoreData location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)externalRecordsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Metadata/CoreData/MongoHub"];
}

/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel) {
        return managedObjectModel;
    }
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if (![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL]) {
        if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert2(NO, @"Failed to create App Support directory %@ : %@", applicationSupportDirectory, error);
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
        }
    }

    NSString *externalRecordsDirectory = [self externalRecordsDirectory];
    if (![fileManager fileExistsAtPath:externalRecordsDirectory isDirectory:NULL]) {
        if (![fileManager createDirectoryAtPath:externalRecordsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error creating external records directory at %@ : %@",externalRecordsDirectory,error);
            NSAssert2(NO, @"Failed to create external records directory %@ : %@", externalRecordsDirectory, error);
            NSLog(@"Error creating external records directory at %@ : %@",externalRecordsDirectory,error);
            return nil;
        };
    }

    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    // set store options to enable spotlight indexing
    NSMutableDictionary *storeOptions = [NSMutableDictionary dictionary];
    [storeOptions setObject:YOUR_EXTERNAL_RECORD_EXTENSION forKey:NSExternalRecordExtensionOption];
    [storeOptions setObject:externalRecordsDirectory forKey:NSExternalRecordsDirectoryOption];
    [storeOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [storeOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:YOUR_STORE_TYPE 
                                                configuration:nil 
                                                URL:url 
                                                options:storeOptions 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (void)saveConnections
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}

/**
    Implementation of application:openFiles:, to respond to an open file request from an external record file
 */
- (void)application:(NSApplication *)theApplication openFiles:(NSArray *)files
{
    NSString *aPath = [files lastObject]; // just an example to get at one of the paths

    if (aPath && [aPath hasSuffix:YOUR_EXTERNAL_RECORD_EXTENSION]) {
        // decode URI from path
        NSURL *objectURI = [[NSPersistentStoreCoordinator elementsDerivedFromExternalRecordURL:[NSURL fileURLWithPath:aPath]] objectForKey:NSObjectURIKey];
        if (objectURI) {
            NSManagedObjectID *moid = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
            if (moid) {
                    NSManagedObject *mo = [[self managedObjectContext] objectWithID:moid];
                    NSLog(@"The record for path %@ is %@",moid,mo);
                    
                    // your code to select the object in your application's UI
            }
            
        }
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addConection:) name:kNewConnectionWindowWillClose object:nil];
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@[%@])", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
    [updater checkForUpdatesInBackground];
}

#pragma mark connections related method
- (IBAction)showAddConnectionPanel:(id)sender
{
    if (!_addConnectionWindowController) {
        _addConnectionWindowController = [[MHConnectionEditorWindowController alloc] init];
        _addConnectionWindowController.delegate = self;
    }
    [_addConnectionWindowController showWindow:self];
}

- (IBAction)deleteConnection:(id)sender
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete the connection?"];
    [alert setInformativeText:@"Deleted connections cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];

    NSInteger answer = [alert runModal];
    alert = nil;
    
    if (answer == NSAlertFirstButtonReturn) {
        [connectionsArrayController remove:sender];
        [self saveConnections];
    }
}

- (IBAction)showEditConnectionPanel:(id)sender
{
    if (![connectionsArrayController selectedObjects]) {
        return;
    }
    MHConnectionStore *connection = [[connectionsArrayController selectedObjects] objectAtIndex:0];
    MHConnectionEditorWindowController *editor = NULL;
    
    for (MHConnectionEditorWindowController *element in _editConnectionWindowControllers) {
        if (element.connectionStore == connection) {
            editor = element;
            break;
        }
    }
    if (!editor) {
        editor = [[MHConnectionEditorWindowController alloc] init];
        [_editConnectionWindowControllers addObject:editor];
        editor.delegate = self;
        editor.connectionStore = connection;
        [editor autorelease];
    }
    [editor showWindow:self];
}

- (IBAction)resizeConnectionItemView:(id)sender
{
    CGFloat theSize = [sender floatValue]/100.0f*360.0f;
    [connectionsCollectionView setSubviewSize:theSize];
}

- (IBAction)showConnectionWindow:(id)sender {
    if (![connectionsArrayController selectedObjects]) {
        return;
    }
    [self doubleClick:[[connectionsArrayController selectedObjects] objectAtIndex:0]];
}

- (void)doubleClick:(id)sender
{
    if (![sender isKindOfClass:[MHConnectionStore class]]) {
        sender = [[connectionsArrayController selectedObjects] objectAtIndex:0];
    }
    if ([self isOpenedConnection:sender]) {
        return;
    }
    MHConnectionWindowController *connectionWindowController = [[MHConnectionWindowController alloc] init];
    connectionWindowController.connectionStore = sender;
    [connectionWindowController showWindow:sender];
}

- (BOOL)isOpenedConnection:(MHConnectionStore *)aConnection
{
    NSWindow *aWindow;
    for (aWindow in [[NSApplication sharedApplication] windows])
    {
        id aDelegate = [aWindow delegate];
        if ([aDelegate isKindOfClass:[MHConnectionWindowController class]] && [aDelegate connectionStore] == aConnection) {
            [aWindow makeKeyAndOrderFront:nil];
            return YES;
        }
    }
    return NO;
}

- (void)openSupportPanel:(id)sender
{
    [NSApp beginSheet:supportPanel modalForWindow:_window modalDelegate:self didEndSelector:@selector(supportPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)supportPanelDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet close];
}

- (IBAction)closeSupportPanel:(id)sender
{
    [NSApp endSheet:supportPanel];
}

- (IBAction)openFeatureRequestBugReport:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/fotonauts/MongoHub-Mac/issues"]];
}

@end

@implementation MHApplicationDelegate(MHConnectionEditorWindowControllerDelegate)

- (void)connectionWindowControllerDidCancel:(MHConnectionEditorWindowController *)controller
{
    [_editConnectionWindowControllers removeObject:controller];
    if (_addConnectionWindowController == controller) {
        [_addConnectionWindowController release];
        _addConnectionWindowController = NULL;
    }
}

- (void)connectionWindowControllerDidValidate:(MHConnectionEditorWindowController *)controller
{
    [_editConnectionWindowControllers removeObject:controller];
    [self saveConnections];
    if (_addConnectionWindowController == controller) {
        [_addConnectionWindowController release];
        _addConnectionWindowController = NULL;
    }
}

@end
