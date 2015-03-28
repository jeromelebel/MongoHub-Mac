//
//  MHJsonWindowController.m
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHJsonWindowController.h"
#import <MongoObjCDriver/MongoObjCDriver.h>

@interface MHJsonWindowController ()
@property (nonatomic, readwrite, strong) UKSyntaxColoredTextViewController *syntaxColoringController;
@property (nonatomic, readwrite, assign) IBOutlet NSTextView *jsonTextView;
@property (nonatomic, readwrite, assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, readwrite, assign) IBOutlet NSTextField *status;
@property (nonatomic, readwrite, assign) IBOutlet NSButton *saveButton;
@property (nonatomic, readwrite, assign) IBOutlet NSButton *cancelButton;

@end

@implementation MHJsonWindowController
@synthesize collection = _collection;
@synthesize windowControllerId = _windowControllerId;
@synthesize jsonDocument = _jsonDocument;
@synthesize bsonData = _bsonData;

@synthesize jsonTextView = _jsonTextView;
@synthesize progressIndicator = _progressIndicator;
@synthesize syntaxColoringController = _syntaxColoringController;
@synthesize status = _status;

- (void)dealloc
{
    [self.syntaxColoringController removeObserver:self forKeyPath:@"unsaved"];
    self.collection = nil;
    self.windowControllerId = nil;
    self.jsonDocument = nil;
    self.bsonData = nil;
    self.syntaxColoringController.delegate = nil;
    self.syntaxColoringController = nil;
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"MHJsonWindow";
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJsonWindowWillClose object:self];
}

- (BOOL)windowShouldClose:(id)sender
{
    if (!self.window.isDocumentEdited) {
        return YES;
    } else {
        NSBeginAlertSheet(@"Unsaved Document", @"Save", @"Don't Save", @"Cancel", self.window, self, @selector(sheetDidEnd:returnCode:contextInfo:), @selector(sheetDidDismiss:returnCode:contextInfo:), nil, @"Do you want to save the current document?");
        return NO;
    }
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    switch (returnCode) {
        case 0:
            [self.window close];
            break;
            
        case -1:
            break;
        
        case 1:
            self.jsonTextView.editable = NO;
            self.saveButton.enabled = NO;
            self.cancelButton.enabled = NO;
            [self.progressIndicator startAnimation:self];
            [self saveWithCallback:^(NSError *error) {
                self.jsonTextView.editable = YES;
                self.saveButton.enabled = YES;
                self.cancelButton.enabled = YES;
                if (error == nil) {
                    [self.window close];
                }
            }];
            break;
        
        default:
            break;
    }
}


- (NSString *)jsonDocumentIdString
{
    id value;
    
    value = [self.jsonDocument objectForKey:@"_id"];
    if (!value) {
        value = [self.jsonDocument objectForKey:@"name"];
    }
    return nil;
}

- (void)windowDidLoad
{
    NSDictionary *info = nil;
    NSString *jsonString;
    NSString *jsonDocumentIdString = self.jsonDocumentIdString;
    
    [super windowDidLoad];
    jsonString = [MODClient convertObjectToJson:self.jsonDocument pretty:YES strictJson:NO jsonKeySortOrder:MODJsonKeySortOrderDocument];
    if (jsonDocumentIdString) {
        self.window.title = [NSString stringWithFormat:@"%@ _id:%@", self.collection.absoluteName, jsonDocumentIdString];
    } else {
        self.window.title = self.collection.absoluteName;
    }
    self.jsonTextView.string = jsonString;
    self.syntaxColoringController = [[[UKSyntaxColoredTextViewController alloc] init] autorelease];
    self.syntaxColoringController.delegate = self;
    self.syntaxColoringController.view = self.jsonTextView;
    [self.syntaxColoringController addObserver:self forKeyPath:@"unsaved" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.bsonData) {
        if (![MODClient isEqualWithJson:jsonString toBsonData:self.bsonData info:&info]) {
            NSLog(@"%@", info);
            NSLog(@"%@", self.bsonData);
            NSLog(@"%@", jsonString);
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, self, nil, nil, nil, @"There is a problem to generate the json. If you save the current json, those values might modified:\n%@\n\nPlease open an issue at https://github.com/jeromelebel/mongohub-mac/issues", [[info objectForKey:@"differences"] componentsJoinedByString:@"\n"]);
        }
    } else if (![MODClient isEqualWithJson:jsonString toDocument:self.jsonDocument info:nil]) {
        NSLog(@"%@", info);
        NSLog(@"%@", jsonString);
        NSLog(@"%@", self.jsonDocument);
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, self, nil, nil, nil, @"There is a problem to generate the json. If you save the current json, those values might modified:\n%@\n\nPlease open an issue at https://github.com/jeromelebel/mongohub-mac/issues", [[info objectForKey:@"differences"] componentsJoinedByString:@"\n"]);
    }
}

- (void)textViewControllerWillStartSyntaxRecoloring:(UKSyntaxColoredTextViewController *)sender
{
    [self.progressIndicator startAnimation:self];
}


- (void)textViewControllerDidFinishSyntaxRecoloring:(UKSyntaxColoredTextViewController *)sender
{
    [self.progressIndicator stopAnimation: self];
}

- (void)selectionInTextViewController:(UKSyntaxColoredTextViewController *)sender                        // Update any selection status display.
              changedToStartCharacter:(NSUInteger)startCharInLine endCharacter:(NSUInteger)endCharInLine
                               inLine:(NSUInteger)lineInDoc startCharacterInDocument:(NSUInteger)startCharInDoc
               endCharacterInDocument:(NSUInteger)endCharInDoc;
{
    NSString *statusMsg = nil;
    
    if( startCharInDoc < endCharInDoc ) {
        statusMsg = NSLocalizedString(@"character %lu to %lu of line %lu (%lu to %lu in document).",@"selection description in syntax colored text documents.");
        statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, endCharInLine +1, lineInDoc +1, startCharInDoc +1, endCharInDoc +1];
    } else {
        statusMsg = NSLocalizedString(@"character %lu of line %lu (%lu in document).",@"insertion mark description in syntax colored text documents.");
        statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, lineInDoc +1, startCharInDoc +1];
    }
    statusMsg = @"";
    [self.status setStringValue:statusMsg];
    [self.status display];
}

- (IBAction)save:(id)sender
{
    [self saveWithCallback:nil];
}

- (void)saveWithCallback:(void (^)(NSError *error))callback
{
    MODSortedDictionary *document;
    NSError *error;
    
    self.status.stringValue = @"Saving...";
    [self.progressIndicator startAnimation: self];
    document = [MODRagelJsonParser objectsFromJson:self.jsonTextView.string withError:&error];
    if (error) {
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", error.localizedDescription);
        [self.progressIndicator stopAnimation: self];
        self.status.stringValue = [error.localizedDescription stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        if (callback) callback(error);
    } else {
        callback = [callback copy];
        [self.collection saveWithDocument:document callback:^(MODQuery *mongoQuery) {
            [self.progressIndicator stopAnimation:self];
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
                self.status.stringValue = mongoQuery.error.localizedDescription;
            } else {
                self.syntaxColoringController.originalString = self.jsonTextView.string;
                self.status.stringValue = @"Saved";
                [NSNotificationCenter.defaultCenter postNotificationName:kJsonWindowSaved object:nil];
            }
            if (callback) callback(mongoQuery.error);
            [callback release];
        }];
    }
}

- (void)mongoQueryDidFinish:(MODQuery *)mongoQuery
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"unsaved"]) {
        [self.window setDocumentEdited:self.syntaxColoringController.unsaved];
    }
}

@end
