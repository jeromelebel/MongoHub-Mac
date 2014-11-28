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
@property (nonatomic, readwrite, weak) IBOutlet NSTextView *jsonTextView;
@property (nonatomic, readwrite, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *status;

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

- (instancetype)init
{
    self = [super initWithWindowNibName:@"MHJsonWindow"];
    return self;
}

- (void)dealloc
{
    self.collection = nil;
    self.windowControllerId = nil;
    self.jsonDocument = nil;
    self.bsonData = nil;
    self.syntaxColoringController.delegate = nil;
    self.syntaxColoringController = nil;
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJsonWindowWillClose object:self];
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

- (void)textViewControllerWillStartSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender
{
    [self.progressIndicator startAnimation:self];
}


- (void)textViewControllerDidFinishSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender
{
    [self.progressIndicator stopAnimation: self];
}

- (void)selectionInTextViewController: (UKSyntaxColoredTextViewController*)sender                        // Update any selection status display.
              changedToStartCharacter: (NSUInteger)startCharInLine endCharacter: (NSUInteger)endCharInLine
                               inLine: (NSUInteger)lineInDoc startCharacterInDocument: (NSUInteger)startCharInDoc
               endCharacterInDocument: (NSUInteger)endCharInDoc;
{
    NSString *statusMsg = nil;
    
    if( startCharInDoc < endCharInDoc ) {
        statusMsg = NSLocalizedString(@"character %lu to %lu of line %lu (%lu to %lu in document).",@"selection description in syntax colored text documents.");
        statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, endCharInLine +1, lineInDoc +1, startCharInDoc +1, endCharInDoc +1];
    } else {
        statusMsg = NSLocalizedString(@"character %lu of line %lu (%lu in document).",@"insertion mark description in syntax colored text documents.");
        statusMsg = [NSString stringWithFormat: statusMsg, startCharInLine +1, lineInDoc +1, startCharInDoc +1];
    }
    
    [self.status setStringValue: statusMsg];
    [self.status display];
}

- (IBAction)save:(id)sender
{
    MODSortedMutableDictionary *document;
    NSError *error;
    
    self.status.stringValue = @"Saving...";
    [self.progressIndicator startAnimation: self];
    document = [MODRagelJsonParser objectsFromJson:self.jsonTextView.string withError:&error];
    if (error) {
        NSRunAlertPanel(@"Error", @"%@", @"OK", nil, nil, error.localizedDescription);
        [self.progressIndicator stopAnimation: self];
        self.status.stringValue = error.localizedDescription;
    } else {
        [self.collection saveWithDocument:document callback:^(MODQuery *mongoQuery) {
            [self.progressIndicator stopAnimation:self];
            if (mongoQuery.error) {
                NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, nil, nil, nil, nil, @"%@", mongoQuery.error.localizedDescription);
                self.status.stringValue = mongoQuery.error.localizedDescription;
            } else {
                self.status.stringValue = @"Saved";
                [NSNotificationCenter.defaultCenter postNotificationName:kJsonWindowSaved object:nil];
            }
        }];
    }
}

- (void)mongoQueryDidFinish:(MODQuery *)mongoQuery
{
    
}

@end
