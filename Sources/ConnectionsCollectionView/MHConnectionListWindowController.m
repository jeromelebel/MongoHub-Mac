//
//  MHConnectionListWindowController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 09/04/2015.
//
//

#import "MHConnectionListWindowController.h"

#import "ConnectionsArrayController.h"
#import "MHConnectionStore.h"
#import "MHEditNameWindowController.h"
#import "MHApplicationDelegate.h"
#import "MHConnectionViewItem.h"

@interface MHConnectionListWindowController ()
@property (nonatomic, readwrite, strong) MHConnectionEditorWindowController *connectionEditorWindowController;

@property (nonatomic, readwrite, strong) IBOutlet MHConnectionCollectionView *connectionCollectionView;

@end

@interface MHConnectionListWindowController (Action)

@end

@implementation MHConnectionListWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)editConnection:(MHConnectionStore *)connection
{
    self.connectionEditorWindowController = [[[MHConnectionEditorWindowController alloc] init] autorelease];
    self.connectionEditorWindowController.delegate = self;
    self.connectionEditorWindowController.editedConnectionStore = connection;
    [self.connectionEditorWindowController modalForWindow:self.window];
}

- (void)duplicateConnection:(MHConnectionStore *)connection
{
    if (!self.connectionEditorWindowController) {
        self.connectionEditorWindowController = [[[MHConnectionEditorWindowController alloc] init] autorelease];
        self.connectionEditorWindowController.delegate = self;
        self.connectionEditorWindowController.connectionStoreDefaultValue = connection;
        [self.connectionEditorWindowController modalForWindow:self.window];
    }
}

- (void)openConnection:(MHConnectionStore *)connection
{
    [(MHApplicationDelegate *)[NSApp delegate] openConnection:connection];
}

- (void)deleteConnection:(MHConnectionStore *)connection
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Delete"];
    [alert setMessageText:[NSString stringWithFormat:@"Delete \"%@\"?", connection.alias]];
    [alert setInformativeText:@"Deleted connections cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertSecondButtonReturn) {
            [self deleteConnection:connection];
       }
    }];
}

@end

@implementation MHConnectionListWindowController (Action)

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    if (anItem.action == @selector(copy:)) {
        return self.window.isKeyWindow && self.connectionsArrayController.selectedObjects.count == 1;
    } else if (anItem.action == @selector(paste:)) {
        return self.window.isKeyWindow && [[[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString] hasPrefix:@"mongodb://"];
    } else if (anItem.action == @selector(editConnectionAction:)) {
        return self.window.isKeyWindow && self.connectionsArrayController.selectedObjects.count > 0;
    } else if (anItem.action == @selector(duplicateConnectionAction:)) {
        return self.window.isKeyWindow && self.connectionsArrayController.selectedObjects.count > 0;
    } else if (anItem.action == @selector(deleteConnectionAction:)) {
        return self.window.isKeyWindow && self.connectionsArrayController.selectedObjects.count > 0;
    } else if (anItem.action == @selector(openConnectionAction:)) {
        return self.window.isKeyWindow && self.connectionsArrayController.selectedObjects.count > 0;
    } else {
        return [self respondsToSelector:anItem.action];
    }
}

- (IBAction)copy:(id)sender
{
    if (self.connectionsArrayController.selectedObjects.count == 1 && !self.connectionEditorWindowController) {
        [self copyURLConnection:self.connectionsArrayController.selectedObjects[0]];
    }
}

- (IBAction)paste:(id)sender
{
    NSString *stringURL;
    
    stringURL = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (![stringURL hasPrefix:@"mongodb://"]) {
        
        NSAlert* alert = [NSAlert init];
        [alert setMessageText:@"No URL found"];
        [alert setInformativeText:@""];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        
    } else {
        NSEntityDescription *entity;
        MHConnectionStore *connectionStore;
        NSString *errorMessage;
        
        entity = [NSEntityDescription entityForName:@"Connection" inManagedObjectContext:self.managedObjectContext];
        connectionStore = [[[MHConnectionStore alloc] initWithEntity:entity insertIntoManagedObjectContext:nil] autorelease];
        if (![connectionStore setValuesFromStringURL:stringURL errorMessage:&errorMessage]) {
       
            NSAlert* alert = [NSAlert init];
            [alert setMessageText:@"No URL found"];
            [alert setInformativeText:[NSString stringWithFormat:@"%@", stringURL]];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
            
            return;
        }
        self.connectionEditorWindowController = [[[MHConnectionEditorWindowController alloc] init] autorelease];
        self.connectionEditorWindowController.delegate = self;
        self.connectionEditorWindowController.connectionStoreDefaultValue = connectionStore;
        [self.connectionEditorWindowController modalForWindow:self.window];
    }
}

- (IBAction)addNewConnectionAction:(id)sender
{
    if (!self.connectionEditorWindowController) {
        self.connectionEditorWindowController = [[[MHConnectionEditorWindowController alloc] init] autorelease];
        self.connectionEditorWindowController.delegate = self;
        [self.connectionEditorWindowController modalForWindow:self.window];
    }
}

- (IBAction)addNewConnectionWithURLAction:(id)sender
{
    if (!self.connectionEditorWindowController) {
        MHEditNameWindowController *editNameWindowController = nil;
        
        editNameWindowController = [[MHEditNameWindowController alloc] initWithLabel:@"New Connection With URL:" editedValue:nil placeHolder:@"MongoDB URL"];
        editNameWindowController.callback = ^(MHEditNameWindowController *controller) {
            MHConnectionStore *connectionStore;
            NSEntityDescription *entity;
            NSString *errorMessage = nil;
            NSString *stringURL = controller.editedValue;
            
            entity = [NSEntityDescription entityForName:@"Connection" inManagedObjectContext:self.managedObjectContext];
            connectionStore = [[[MHConnectionStore alloc] initWithEntity:entity insertIntoManagedObjectContext:nil] autorelease];
            if (![connectionStore setValuesFromStringURL:stringURL errorMessage:&errorMessage]) {
               
                NSAlert* alert = [NSAlert init];
                [alert setMessageText:errorMessage];
                [alert setInformativeText:[NSString stringWithFormat:@"%@", stringURL]];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert addButtonWithTitle:@"Ok"];
                [alert runModal];
                return;
            }
            
            self.connectionEditorWindowController = [[[MHConnectionEditorWindowController alloc] init] autorelease];
            self.connectionEditorWindowController.delegate = self;
            self.connectionEditorWindowController.connectionStoreDefaultValue = connectionStore;
            self.connectionEditorWindowController.window.title = stringURL;
            [self.connectionEditorWindowController modalForWindow:self.window];
            [controller release];
        };
        editNameWindowController.validateValueCallback = ^(MHEditNameWindowController *controller) {
            MHConnectionStore *connectionStore;
            NSString *stringURL = controller.editedValue;
            NSString *errorMessage = nil;
            NSEntityDescription *entity;
            
            entity = [NSEntityDescription entityForName:@"Connection" inManagedObjectContext:self.managedObjectContext];
            connectionStore = [[[MHConnectionStore alloc] initWithEntity:entity insertIntoManagedObjectContext:nil] autorelease];
            if ([connectionStore setValuesFromStringURL:stringURL errorMessage:&errorMessage]) {
                return YES;
            } else {
                
                NSAlert* alert = [NSAlert init];
                [alert setMessageText:errorMessage];
                [alert setInformativeText:[NSString stringWithFormat:@"%@", stringURL]];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert addButtonWithTitle:@"Ok"];
                [alert runModal];
                
                return NO;
            }
        };
        [editNameWindowController modalForWindow:self.window];
    }
}

- (void)deleteConnectionAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertSecondButtonReturn) {
        [(MHApplicationDelegate *)[NSApp delegate] deleteConnection:contextInfo];
    }
}

- (IBAction)openConnectionAction:(id)sender
{
    if (!self.connectionsArrayController.selectedObjects) {
        return;
    }
    [self openConnection:[self.connectionsArrayController.selectedObjects objectAtIndex:0]];
}

- (IBAction)editConnectionAction:(id)sender
{
    if (self.connectionsArrayController.selectedObjects.count == 1 && !self.connectionEditorWindowController) {
        [self editConnection:[self.connectionsArrayController.selectedObjects objectAtIndex:0]];
    }
}

- (IBAction)duplicateConnectionAction:(id)sender
{
    if (self.connectionsArrayController.selectedObjects.count == 1 && !self.connectionEditorWindowController) {
        [self duplicateConnection:[self.connectionsArrayController.selectedObjects objectAtIndex:0]];
    }
}

- (IBAction)deleteConnectionAction:(id)sender
{
    if (self.connectionsArrayController.selectedObjects.count == 1) {
        [self deleteConnection:[self.connectionsArrayController.selectedObjects objectAtIndex:0]];
    }
}

- (IBAction)resizeConnectionItemView:(id)sender
{
    CGFloat value = [sender floatValue]/100.0f*360.0f;
    
    self.connectionCollectionView.itemSize = NSMakeSize(value, value * 0.8);
}

- (void)copyURLConnection:(MHConnectionStore *)connection
{
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    NSString *stringURL = [connection stringURLWithSSHMapping:nil];
    
    [pasteboard declareTypes:@[ NSStringPboardType, NSURLPboardType ] owner:nil];
    [pasteboard setString:stringURL forType:NSStringPboardType];
    [pasteboard setString:stringURL forType:NSURLPboardType];
}

@end

@implementation MHConnectionListWindowController (MHConnectionEditorWindowControllerDelegate)

- (NSManagedObjectContext *)managedObjectContext
{
    return [(MHApplicationDelegate *)[NSApp delegate] managedObjectContext];
}

- (ConnectionsArrayController *)connectionsArrayController
{
    return [(MHApplicationDelegate *)[NSApp delegate] connectionsArrayController];
}

- (void)connectionWindowControllerDidCancel:(MHConnectionEditorWindowController *)controller
{
    if (self.connectionEditorWindowController == controller) {
        self.connectionEditorWindowController = nil;
    }
}

- (void)connectionWindowControllerDidValidate:(MHConnectionEditorWindowController *)controller
{
    [(MHApplicationDelegate *)[NSApp delegate] saveConnections];
    self.connectionCollectionView.needsDisplay = YES;
    if (self.connectionEditorWindowController == controller) {
        self.connectionEditorWindowController = nil;
    }
}

- (MHConnectionStore *)connectionWindowController:(MHConnectionEditorWindowController *)controller connectionStoreWithAlias:(NSString *)alias
{
    return [(MHApplicationDelegate *)[NSApp delegate] connectionStoreWithAlias:alias];
}

@end


@implementation MHConnectionListWindowController (MHConnectionViewItemDelegate)

- (void)connectionViewItemDelegateNewItem:(MHConnectionCollectionView *)connectionCollectionView
{
    [self addNewConnectionAction:nil];
}

- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView openItem:(MHConnectionViewItem *)connectionViewItem
{
    [self openConnection:connectionViewItem.representedObject];
}

- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView editItem:(MHConnectionViewItem *)connectionViewItem
{
    [self editConnection:connectionViewItem.representedObject];
}

- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView duplicateItem:(MHConnectionViewItem *)connectionViewItem
{
    [self duplicateConnection:connectionViewItem.representedObject];
}

- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView copyURLItem:(MHConnectionViewItem *)connectionViewItem
{
    [self copyURLConnection:connectionViewItem.representedObject];
}

- (void)connectionViewItemDelegate:(MHConnectionCollectionView *)connectionCollectionView deleteItem:(MHConnectionViewItem *)connectionViewItem
{
    [self deleteConnection:connectionViewItem.representedObject];
}

@end
