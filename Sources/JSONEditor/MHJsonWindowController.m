//
//  MHJsonWindowController.m
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHJsonWindowController.h"
#import <mongo-objc-driver/MOD_public.h>

@interface MHJsonWindowController ()
@property (nonatomic, readwrite, strong) NSProgressIndicator *progressIndicator;

@end

@implementation MHJsonWindowController
@synthesize collection = _collection;
@synthesize jsonDict;
@synthesize myTextView;
@synthesize progressIndicator = _progressIndicator;

- (id)init
{
    self = [super initWithWindowNibName:@"MHJsonWindow"];
    return self;
}

- (void)dealloc
{
    self.collection = nil;
    [jsonDict release];
    [syntaxColoringController setDelegate: nil];
    [syntaxColoringController release];
    syntaxColoringController = nil;
    self.progressIndicator = nil;
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJsonWindowWillClose object:self];
}

- (void)windowDidLoad
{
    NSDictionary *info = nil;
    NSString *title;
    
    [super windowDidLoad];
    title = [[NSString alloc] initWithFormat:@"%@ _id:%@", self.collection.absoluteName, [jsonDict objectForKey:@"value"]];
    [self.window setTitle:title];
    [title release];
    [myTextView setString:[jsonDict objectForKey:@"beautified"]];
    syntaxColoringController = [[UKSyntaxColoredTextViewController alloc] init];
    [syntaxColoringController setDelegate: self];
    [syntaxColoringController setView: myTextView];
    
    if ([jsonDict objectForKey:@"bsondata"]) {
        if (![MODClient isEqualWithJson:[jsonDict objectForKey:@"beautified"] toBsonData:[jsonDict objectForKey:@"bsondata"] info:&info]) {
            NSLog(@"%@", info);
            NSLog(@"%@", [jsonDict objectForKey:@"bsondata"]);
            NSLog(@"%@", [jsonDict objectForKey:@"beautified"]);
            NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, self, nil, nil, nil, @"There is a problem to generate the json. If you save the current json, those values might modified:\n%@\n\nPlease open an issue at https://github.com/fotonauts/mongohub-mac/issues", [[info objectForKey:@"differences"] componentsJoinedByString:@"\n"]);
        }
    } else if (![MODClient isEqualWithJson:[jsonDict objectForKey:@"beautified"] toDocument:[jsonDict objectForKey:@"objectvalue"] info:nil]) {
        NSLog(@"%@", info);
        NSLog(@"%@", [jsonDict objectForKey:@"beautified"]);
        NSLog(@"%@", [jsonDict objectForKey:@"objectvalue"]);
        NSBeginAlertSheet(@"Error", @"OK", nil, nil, self.window, self, nil, nil, nil, @"There is a problem to generate the json. If you save the current json, those values might modified:\n%@\n\nPlease open an issue at https://github.com/fotonauts/mongohub-mac/issues", [[info objectForKey:@"differences"] componentsJoinedByString:@"\n"]);
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

-(NSString *)syntaxDefinitionFilenameForTextViewController: (UKSyntaxColoredTextViewController*)sender
{
    return @"JSON";
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
    
    [status setStringValue: statusMsg];
    [status display];
}

/* -----------------------------------------------------------------------------
 recolorCompleteFile:
 IBAction to do a complete recolor of the whole friggin' document.
 -------------------------------------------------------------------------- */

- (IBAction)recolorCompleteFile: (id)sender
{
    [syntaxColoringController recolorCompleteFile: sender];
}

- (IBAction)save:(id)sender
{
    MODSortedMutableDictionary *document;
    NSError *error;
    
    status.stringValue = @"Saving...";
    [self.progressIndicator startAnimation: self];
    document = [MODRagelJsonParser objectsFromJson:myTextView.string withError:&error];
    if (error) {
        NSRunAlertPanel(@"Error", @"%@", @"OK", nil, nil, error.localizedDescription);
        [self.progressIndicator stopAnimation: self];
        status.stringValue = error.localizedDescription;
    } else {
        [self.collection saveWithDocument:document callback:^(MODQuery *mongoQuery) {
            [self.progressIndicator stopAnimation:self];
            if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", @"%@", @"OK", nil, nil, mongoQuery.error.localizedDescription);
                status.stringValue = error.localizedDescription;
            } else {
                status.stringValue = @"Saved";
                [NSNotificationCenter.defaultCenter postNotificationName:kJsonWindowSaved object:nil];
            }
        }];
    }
}

- (void)mongoQueryDidFinish:(MODQuery *)mongoQuery
{
    
}

@end
