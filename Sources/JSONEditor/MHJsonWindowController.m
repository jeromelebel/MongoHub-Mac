//
//  MHJsonWindowController.m
//  MongoHub
//
//  Created by Syd on 10-12-27.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHJsonWindowController.h"
#import "Configure.h"
#import "NSProgressIndicator+Extras.h"
#import "DatabasesArrayController.h"
#import "NSString+Extras.h"
#import <mongo-objc-driver/MOD_public.h>

@implementation MHJsonWindowController
@synthesize databasesArrayController;
@synthesize mongoServer;
@synthesize mongoCollection;
@synthesize dbname;
@synthesize collectionname;
@synthesize jsonDict;
@synthesize myTextView;

- (id)init
{
    self = [super initWithWindowNibName:@"MHJsonWindow"];
    return self;
}

- (void)dealloc
{
    [databasesArrayController release];
    [mongoServer release];
    [mongoCollection release];
    [dbname release];
    [collectionname release];
    [jsonDict release];
    [syntaxColoringController setDelegate: nil];
    [syntaxColoringController release];
    syntaxColoringController = nil;
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
    title = [[NSString alloc] initWithFormat:@"%@ _id:%@", self.mongoCollection.absoluteName, [jsonDict objectForKey:@"value"]];
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
    // Show your progress indicator.
    [progress startAnimation: self];
    [progress display];
}


- (void)textViewControllerDidFinishSyntaxRecoloring: (UKSyntaxColoredTextViewController*)sender
{
    // Hide your progress indicator.
    [progress stopAnimation: self];
    [progress display];
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

-(IBAction) save:(id)sender
{
    [status setStringValue: @"Saving..."];
    [status display];
    [progress startAnimation: self];
    [progress display];
    [self.mongoCollection saveWithDocument:[myTextView string] callback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", @"%@", @"OK", nil, nil, [mongoQuery.error localizedDescription]);
        }
        [progress stopAnimation: self];
        [progress display];
        [status setStringValue: @"Saved"];
        [status display];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJsonWindowSaved object:nil];
    }];
}

- (void)mongoQueryDidFinish:(MODQuery *)mongoQuery
{
    
}

@end
