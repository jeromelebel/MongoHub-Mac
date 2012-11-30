//
//  MHQueryWindowController.m
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "Configure.h"
#import "NSProgressIndicator+Extras.h"
#import "MHQueryWindowController.h"
#import "DatabasesArrayController.h"
#import "MHResultsOutlineViewController.h"
#import "NSString+Extras.h"
#import "MHJsonWindowController.h"
#import "MOD_public.h"
#import "MODHelper.h"
#import "MODJsonParser.h"
#import "MHConnectionStore.h"
#import "NSViewHelpers.h"

@implementation MHQueryWindowController

@synthesize databasesArrayController;
@synthesize findResultsViewController;
@synthesize mongoCollection = _mongoCollection;
@synthesize connectionStore = _connectionStore;

@synthesize fieldsTextField = _fieldsTextField;
@synthesize skipTextField = _skipTextField;
@synthesize limitTextField = _limitTextField;
@synthesize totalResultsTextField;
@synthesize findQueryTextField;
@synthesize findResultsOutlineView;
@synthesize findQueryLoaderIndicator;

@synthesize updateCriticalTextField;
@synthesize updateSetTextField;
@synthesize upsetCheckBox;
@synthesize multiCheckBox;
@synthesize updateResultsTextField;
@synthesize updateQueryTextField;
@synthesize updateQueryLoaderIndicator;

@synthesize removeCriticalTextField;
@synthesize removeResultsTextField;
@synthesize removeQueryTextField;
@synthesize removeQueryLoaderIndicator;

@synthesize insertDataTextView;
@synthesize insertResultsTextField;
@synthesize insertLoaderIndicator;

@synthesize indexTextField;
@synthesize indexesOutlineViewController;
@synthesize indexLoaderIndicator;

@synthesize mapFunctionTextView;
@synthesize reduceFunctionTextView;
@synthesize mrcriticalTextField;
@synthesize mroutputTextField;
@synthesize mrOutlineViewController;
@synthesize mrLoaderIndicator;

@synthesize expCriticalTextField;
@synthesize expFieldsTextField;
@synthesize expSkipTextField;
@synthesize expLimitTextField;
@synthesize expSortTextField;
@synthesize expResultsTextField;
@synthesize expPathTextField;
@synthesize expTypePopUpButton;
@synthesize expQueryTextField;
@synthesize expJsonArrayCheckBox;
@synthesize expProgressIndicator;

@synthesize impIgnoreBlanksCheckBox;
@synthesize impDropCheckBox;
@synthesize impHeaderlineCheckBox;
@synthesize impFieldsTextField;
@synthesize impResultsTextField;
@synthesize impPathTextField;
@synthesize impTypePopUpButton;
@synthesize impJsonArrayCheckBox;
@synthesize impStopOnErrorCheckBox;
@synthesize impProgressIndicator;


+ (id)loadQueryController
{
    return [[[MHQueryWindowController alloc] initWithNibName:@"QueryWindow" bundle:nil] autorelease];
}

- (void)dealloc
{
    [_jsonWindowControllers release];
    [databasesArrayController release];
    [findResultsViewController release];
    [_mongoCollection release];
    [_connectionStore release];
    
    [totalResultsTextField release];
    [findQueryTextField release];
    [findResultsOutlineView release];
    [findQueryLoaderIndicator release];
    
    [updateCriticalTextField release];
    [updateSetTextField release];
    [upsetCheckBox release];
    [multiCheckBox release];
    [updateResultsTextField release];
    [updateQueryTextField release];
    [updateQueryLoaderIndicator release];
    
    [removeCriticalTextField release];
    [removeResultsTextField release];
    [removeQueryTextField release];
    [removeQueryLoaderIndicator release];
    
    [insertDataTextView release];
    [insertResultsTextField release];
    [insertLoaderIndicator release];
    
    [indexTextField release];
    [indexesOutlineViewController release];
    [indexLoaderIndicator release];
    
    [mapFunctionTextView release];
    [reduceFunctionTextView release];
    [mrcriticalTextField release];
    [mroutputTextField release];
    [mrOutlineViewController release];
    [mrLoaderIndicator release];
    
    [expCriticalTextField release];
    [expFieldsTextField release];
    [expSkipTextField release];
    [expLimitTextField release];
    [expSortTextField release];
    [expResultsTextField release];
    [expPathTextField release];
    [expTypePopUpButton release];
    [expQueryTextField release];
    [expJsonArrayCheckBox release];
    [expProgressIndicator release];
    
    [impIgnoreBlanksCheckBox release];
    [impDropCheckBox release];
    [impHeaderlineCheckBox release];
    [impFieldsTextField release];
    [impResultsTextField release];
    [impPathTextField release];
    [impTypePopUpButton release];
    [impJsonArrayCheckBox release];
    [impStopOnErrorCheckBox release];
    [impProgressIndicator release];
    
    [super dealloc];
}

- (NSString *)formatedQuerySort
{
    NSString *result;
    
    result = [[_sortTextField stringValue] stringByTrimmingWhitespace];
    if ([result length] == 0) {
        result = @"{ \"_id\": 1}";
    }
    return result;
}

- (NSString *)formatedQueryWithReplace:(BOOL)replace
{
    NSString *query = @"";
    NSString *value;
    
    value = [[_criteriaComboBox stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([value length] == 24 && [[value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefABCDEF"]] length] == 0) {
        // 24 char length and only hex char... it must be an objectid
        query = [NSString stringWithFormat:@"{\"_id\": { \"$oid\": \"%@\" }}",value];
    } else if ([value length] > 0) {
        if ([value hasPrefix:@"{"]) {
            NSString *innerValue;
            
            innerValue = [[value substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([innerValue hasPrefix:@"\"$oid\""] || [innerValue hasPrefix:@"'$iod'"]) {
                query = [NSString stringWithFormat:@"{\"_id\": %@ }",value];
            } else {
                query = value;
            }
        } else if ([value hasPrefix:@"\"$oid\""] || [value hasPrefix:@"'$iod'"]) {
            query = [NSString stringWithFormat:@"{\"_id\": {%@}}",value];
        } else {
            query = [NSString stringWithFormat:@"{\"_id\": %@}",value];
        }
    }
    if (replace) {
        [_criteriaComboBox setStringValue:query];
        [_criteriaComboBox selectText:nil];
    }
    return query;
}

- (void)awakeFromNib
{
    self.title = _mongoCollection.absoluteCollectionName;
    _jsonWindowControllers = [[NSMutableDictionary alloc] init];
    [self findQueryComposer:nil];
    [self updateQueryComposer:nil];
    [self removeQueryComposer:nil];
    [self exportQueryComposer:nil];
}

- (IBAction)findQuery:(id)sender
{
    int limit = [_limitTextField intValue];
    NSMutableArray *fields;
    NSString *criteria;
    NSString *sort = [self formatedQuerySort];
    NSString *queryTitle = [[_criteriaComboBox stringValue] retain];
    
    [self findQueryComposer:nil];
    if (limit <= 0) {
        limit = 30;
    }
    criteria = [self formatedQueryWithReplace:YES];
    fields = [[NSMutableArray alloc] init];
    for (NSString *field in [[_fieldsTextField stringValue] componentsSeparatedByString:@","]) {
        field = [field stringByTrimmingWhitespace];
        if ([field length] > 0) {
            [fields addObject:field];
        }
    }
    [findQueryLoaderIndicator start];
    [_mongoCollection findWithCriteria:criteria fields:fields skip:[_skipTextField intValue] limit:limit sort:sort callback:^(NSArray *documents, MODQuery *mongoQuery) {
        NSColor *currentColor;
        
        if (mongoQuery.error) {
            [findQueryLoaderIndicator stop];
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        } else {
            if ([queryTitle length] > 0) {
                [_connectionStore addNewQuery:[NSDictionary dictionaryWithObjectsAndKeys:queryTitle, @"title", [_sortTextField stringValue], @"sort", [_fieldsTextField stringValue], @"fields", [_limitTextField stringValue], @"limit", [_skipTextField stringValue], @"skip", nil] withDatabaseName:_mongoCollection.databaseName collectionName:_mongoCollection.collectionName];
            }
            findResultsViewController.results = [MODHelper convertForOutlineWithObjects:documents];
            [_mongoCollection countWithCriteria:criteria callback:^(int64_t count, MODQuery *mongoQuery) {
                [findQueryLoaderIndicator stop];
                [totalResultsTextField setStringValue:[NSString stringWithFormat:@"Total Results: %lld (%0.2fs)", count, [[mongoQuery.userInfo objectForKey:@"timequery"] duration]]];
            }];
        }
        [NSViewHelpers cancelColorForTarget:totalResultsTextField selector:@selector(setTextColor:)];
        currentColor = totalResultsTextField.textColor;
        totalResultsTextField.textColor = [NSColor greenColor];
        [NSViewHelpers setColor:currentColor fromColor:[NSColor greenColor] toTarget:totalResultsTextField withSelector:@selector(setTextColor:) delay:1];
        [findQueryLoaderIndicator stopAnimation:self];

        
    }];
    [fields release];
    [queryTitle release];
}

- (IBAction)expandFindResults:(id)sender
{
    [findResultsOutlineView expandItem:nil expandChildren:YES];
}

- (IBAction)collapseFindResults:(id)sender
{
    [findResultsOutlineView collapseItem:nil collapseChildren:YES];
}

- (IBAction)updateQuery:(id)sender
{
    NSString *criteria = [updateCriticalTextField stringValue];
    
    [updateQueryLoaderIndicator start];
    [_mongoCollection countWithCriteria:criteria callback:^(int64_t count, MODQuery *mongoQuery) {
        if ([multiCheckBox state] == 0 && count > 0) {
            count = 1;
        }
        NSColor *currentColor;
        
        [updateResultsTextField setStringValue:[NSString stringWithFormat:@"Affected Rows: %lld", count]];
        [NSViewHelpers cancelColorForTarget:updateResultsTextField selector:@selector(setTextColor:)];
        currentColor = updateResultsTextField.textColor;
        updateResultsTextField.textColor = [NSColor greenColor];
        [NSViewHelpers setColor:currentColor fromColor:[NSColor greenColor] toTarget:updateResultsTextField withSelector:@selector(setTextColor:) delay:1];
    }];
    [_mongoCollection updateWithCriteria:criteria update:[updateSetTextField stringValue] upsert:[upsetCheckBox state] multiUpdate:[multiCheckBox state] callback:^(MODQuery *mongoQuery) {
        [updateQueryLoaderIndicator stop];
    }];
}

- (void)_removeQuery
{
    [removeQueryLoaderIndicator start];
    NSString *criteria = [removeCriticalTextField stringValue];
    
    [_mongoCollection countWithCriteria:criteria callback:^(int64_t count, MODQuery *mongoQuery) {
        NSColor *currentColor;
        
        [removeResultsTextField setStringValue:[NSString stringWithFormat:@"Affected Rows: %lld", count]];
        [NSViewHelpers cancelColorForTarget:removeResultsTextField selector:@selector(setTextColor:)];
        currentColor = removeResultsTextField.textColor;
        removeResultsTextField.textColor = [NSColor redColor];
        [NSViewHelpers setColor:currentColor fromColor:[NSColor redColor] toTarget:removeResultsTextField withSelector:@selector(setTextColor:) delay:1];
    }];
    [_mongoCollection removeWithCriteria:criteria callback:^(MODQuery *mongoQuery) {
        [removeQueryLoaderIndicator stop];
    }];
}

- (IBAction)removeQuery:(id)sender
{
    id objects;
    
    objects = [MODJsonToObjectParser objectsFromJson:[removeCriticalTextField stringValue] error:NULL];
    if ((([[removeCriticalTextField stringValue] stringByTrimmingWhitespace].length == 0) || (objects && [objects count] == 0))
        && ((self.view.window.currentEvent.modifierFlags & NSCommandKeyMask) != NSCommandKeyMask)) {
        NSAlert *alert;
        
        alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to remove all documents in %@", _mongoCollection.absoluteCollectionName] defaultButton:@"Cancel" alternateButton:@"Remove All" otherButton:nil informativeTextWithFormat:@"This action cannot be undone"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(removeAllDocumentsPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
    } else {
        [self _removeQuery];
    }
}

- (void)removeAllDocumentsPanelDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    switch (returnCode) {
        case NSAlertAlternateReturn:
            [self _removeQuery];
            break;
            
        default:
            break;
    }
}

- (IBAction)insertQuery:(id)sender
{
    id objects;
    NSError *error;
    
    [insertLoaderIndicator start];
    objects = [MODJsonToObjectParser objectsFromJson:[insertDataTextView string] error:&error];
    if (error) {
        NSColor *currentColor;
        
        [insertLoaderIndicator stop];
        NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
        insertResultsTextField.stringValue = @"Parsing error";
        [NSViewHelpers cancelColorForTarget:insertResultsTextField selector:@selector(setTextColor:)];
        currentColor = insertResultsTextField.textColor;
        insertResultsTextField.textColor = [NSColor greenColor];
        [NSViewHelpers setColor:currentColor fromColor:[NSColor greenColor] toTarget:insertResultsTextField withSelector:@selector(setTextColor:) delay:1];
    } else {
        if ([objects isKindOfClass:[MODSortedMutableDictionary class]]) {
            objects = [NSArray arrayWithObject:objects];
        }
        [_mongoCollection insertWithDocuments:objects callback:^(MODQuery *mongoQuery) {
            NSColor *currentColor;
            
            [insertLoaderIndicator stop];
            if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
                [insertResultsTextField setStringValue:@"Error!"];
            } else {
                [insertResultsTextField setStringValue:@"Completed!"];
            }
            [NSViewHelpers cancelColorForTarget:insertResultsTextField selector:@selector(setTextColor:)];
            currentColor = insertResultsTextField.textColor;
            insertResultsTextField.textColor = [NSColor greenColor];
            [NSViewHelpers setColor:currentColor fromColor:[NSColor greenColor] toTarget:insertResultsTextField withSelector:@selector(setTextColor:) delay:1];
        }];
    }
}

- (IBAction) indexQuery:(id)sender
{
    [_mongoCollection indexListWithcallback:^(NSArray *indexes, MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        }
        indexesOutlineViewController.results = [MODHelper convertForOutlineWithObjects:indexes];
    }];
}

- (IBAction) ensureIndex:(id)sender
{
    [indexLoaderIndicator start];
    [_mongoCollection createIndex:[indexTextField stringValue] name:nil options:0 callback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        } else {
            [indexTextField setStringValue:@""];
        }
        [indexLoaderIndicator stop];
        [self indexQuery:nil];
    }];
}


- (IBAction) reIndex:(id)sender
{
    [indexLoaderIndicator start];
    [_mongoCollection reIndexWithCallback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        } else {
            [indexTextField setStringValue:@""];
        }
        [indexLoaderIndicator stop];
    }];
}

- (IBAction) dropIndex:(id)sender
{
    NSArray *indexes;
    
    [indexLoaderIndicator start];
    indexes = indexesOutlineViewController.selectedDocuments;
    if (indexes.count == 1) {
        [_mongoCollection dropIndex:[[[indexes objectAtIndex:0] objectForKey:@"objectvalue"] objectForKey:@"key"] callback:^(MODQuery *mongoQuery) {
            if (mongoQuery.error) {
                NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
            }
            [indexLoaderIndicator stop];
            [self indexQuery:nil];
        }];
    }
}

- (IBAction) mapReduce:(id)sender
{
    [_mongoCollection mapReduceWithMapFunction:[mapFunctionTextView string] reduceFunction:[reduceFunctionTextView string] query:[mrcriticalTextField stringValue] sort:nil limit:-1 output:[mroutputTextField stringValue] keepTemp:NO finalizeFunction:nil scope:nil jsmode:NO verbose:NO callback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        }
    }];
}

- (IBAction)removeRecord:(id)sender
{
    NSMutableArray *documentIds;
    MODSortedMutableDictionary *criteria;
    MODSortedMutableDictionary *inCriteria;
    
    [removeQueryLoaderIndicator start];
    documentIds = [[NSMutableArray alloc] init];
    for (NSDictionary *document in findResultsViewController.selectedDocuments) {
        [documentIds addObject:[document objectForKey:@"objectvalueid"]];
    }
    
    inCriteria = [[MODSortedMutableDictionary alloc] initWithObjectsAndKeys:documentIds, @"$in", nil];
    criteria = [[MODSortedMutableDictionary alloc] initWithObjectsAndKeys:inCriteria, @"_id", nil];
    [_mongoCollection removeWithCriteria:criteria callback:^(MODQuery *mongoQuery) {
        if (mongoQuery.error) {
            NSRunAlertPanel(@"Error", [mongoQuery.error localizedDescription], @"OK", nil, nil);
        } else {
            
        }
        [removeQueryLoaderIndicator stop];
        [self findQuery:nil];
    }];
    [criteria release];
    [documentIds release];
    [inCriteria release];
}

- (void)controlTextDidChange:(NSNotification *)nd
{
    NSTextField *ed = [nd object];
    
    if (ed == _criteriaComboBox || ed == _fieldsTextField || ed == _sortTextField || ed == _skipTextField || ed == _limitTextField) {
        [self findQueryComposer:nil];
    } else if (ed == updateCriticalTextField || ed == updateSetTextField) {
        [self updateQueryComposer:nil];
    } else if (ed == removeCriticalTextField) {
        [self removeQueryComposer:nil];
    } else if (ed == expCriticalTextField || ed == expFieldsTextField || ed == expSortTextField || ed == expSkipTextField || ed == expLimitTextField) {
        [self exportQueryComposer:nil];
    }

}

- (IBAction) findQueryComposer:(id)sender
{
    NSString *criteria = [self formatedQueryWithReplace:NO];
    NSString *jsFields;
    NSString *sortValue = [self formatedQuerySort];
    NSString *sort;
    
    if ([[_fieldsTextField stringValue] length] > 0) {
        NSArray *keys = [[NSArray alloc] initWithArray:[[_fieldsTextField stringValue] componentsSeparatedByString:@","]];
        NSMutableArray *tmpstr = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        for (NSString *str in keys) {
            [tmpstr addObject:[NSString stringWithFormat:@"%@:1", str]];
        }
        jsFields = [[NSString alloc] initWithFormat:@", {%@}", [tmpstr componentsJoinedByString:@","] ];
        [keys release];
        [tmpstr release];
    }else {
        jsFields = [[NSString alloc] initWithString:@""];
    }
    
    if ([sortValue length] > 0) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)", sortValue];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", [_skipTextField intValue]];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", [_limitTextField intValue]];
    NSString *col = [NSString stringWithFormat:@"%@.%@", _mongoCollection.databaseName, _mongoCollection.collectionName];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, criteria, jsFields, sort, skip, limit];
    [jsFields release];
    [sort release];
    [skip release];
    [limit release];
    [findQueryTextField setStringValue:query];
}

- (IBAction)updateQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", _mongoCollection.databaseName, _mongoCollection.collectionName];
    NSString *critical;
    if ([[updateCriticalTextField stringValue] length] > 0) {
        critical = [[NSString alloc] initWithString:[updateCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *sets;
    if ([[updateSetTextField stringValue] length] > 0) {
        //sets = [[NSString alloc] initWithFormat:@", {$set:%@}", [updateSetTextField stringValue]];
        sets = [[NSString alloc] initWithFormat:@", %@", [updateSetTextField stringValue]];
    }else {
        sets = [[NSString alloc] initWithString:@""];
    }
    NSString *upset;
    if ([upsetCheckBox state] == 1) {
        upset = [[NSString alloc] initWithString:@", true"];
    }else {
        upset = [[NSString alloc] initWithString:@", false"];
    }
    
    NSString *multi;
    if ([multiCheckBox state] == 1) {
        multi = [[NSString alloc] initWithString:@", true"];
    }else {
        multi = [[NSString alloc] initWithString:@", false"];
    }

    NSString *query = [NSString stringWithFormat:@"db.%@.update(%@%@%@%@)", col, critical, sets, upset, multi];
    [critical release];
    [sets release];
    [upset release];
    [multi release];
    [updateQueryTextField setStringValue:query];
}

- (IBAction)removeQueryComposer:(id)sender
{
    NSString *col = [NSString stringWithFormat:@"%@.%@", _mongoCollection.databaseName, _mongoCollection.collectionName];
    NSString *critical;
    if ([[removeCriticalTextField stringValue] length] > 0) {
        critical = [[NSString alloc] initWithString:[removeCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    NSString *query = [NSString stringWithFormat:@"db.%@.remove(%@)", col, critical];
    [critical release];
    [removeQueryTextField setStringValue:query];
}

- (IBAction) exportQueryComposer:(id)sender
{
    NSString *critical;
    if ([[expCriticalTextField stringValue] length] > 0) {
        critical = [[NSString alloc] initWithString:[expCriticalTextField stringValue]];
    }else {
        critical = [[NSString alloc] initWithString:@""];
    }
    
    NSString *jsFields;
    if ([[expFieldsTextField stringValue] length] > 0) {
        NSArray *keys = [[NSArray alloc] initWithArray:[[expFieldsTextField stringValue] componentsSeparatedByString:@","]];
        NSMutableArray *tmpstr = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        for (NSString *str in keys) {
            [tmpstr addObject:[NSString stringWithFormat:@"%@:1", str]];
        }
        jsFields = [[NSString alloc] initWithFormat:@", {%@}", [tmpstr componentsJoinedByString:@","] ];
        [keys release];
        [tmpstr release];
    }else {
        jsFields = [[NSString alloc] initWithString:@""];
    }
    
    NSString *sort;
    if ([[expSortTextField stringValue] length] > 0) {
        sort = [[NSString alloc] initWithFormat:@".sort(%@)", [expSortTextField stringValue]];
    }else {
        sort = [[NSString alloc] initWithString:@""];
    }
    
    NSString *skip = [[NSString alloc] initWithFormat:@".skip(%d)", [expSkipTextField intValue]];
    NSString *limit = [[NSString alloc] initWithFormat:@".limit(%d)", [expLimitTextField intValue]];
    NSString *col = [NSString stringWithFormat:@"%@.%@", _mongoCollection.databaseName, _mongoCollection.collectionName];
    
    NSString *query = [NSString stringWithFormat:@"db.%@.find(%@%@)%@%@%@", col, critical, jsFields, sort, skip, limit];
    [critical release];
    [jsFields release];
    [sort release];
    [skip release];
    [limit release];
    [expQueryTextField setStringValue:query];
}

- (void)showEditWindow:(id)sender
{
    for (NSDictionary *document in findResultsViewController.selectedDocuments) {
        id idValue;
        id jsonWindowControllerKey;
        
        MHJsonWindowController *jsonWindowController;
        
        idValue = [document objectForKey:@"objectvalueid"];
        if (idValue) {
            jsonWindowControllerKey = [MODServer convertObjectToJson:[MODSortedMutableDictionary sortedDictionaryWithObject:idValue forKey:@"_id"] pretty:NO];
        } else {
            jsonWindowControllerKey = document;
        }
        jsonWindowController = [_jsonWindowControllers objectForKey:jsonWindowControllerKey];
        if (!jsonWindowController) {
            jsonWindowController = [[MHJsonWindowController alloc] init];
            jsonWindowController.mongoCollection = _mongoCollection;
            jsonWindowController.jsonDict = document;
            [jsonWindowController showWindow:sender];
            [_jsonWindowControllers setObject:jsonWindowController forKey:jsonWindowControllerKey];
            [jsonWindowController release];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findQuery:) name:kJsonWindowSaved object:jsonWindowController];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsonWindowWillClose:) name:kJsonWindowWillClose object:jsonWindowController];
        } else {
            [jsonWindowController showWindow:self];
        }
    }
}

- (void)jsonWindowWillClose:(NSNotification *)notification
{
    MHJsonWindowController *jsonWindowController = notification.object;
    id idValue;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJsonWindowSaved object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJsonWindowWillClose object:notification.object];
    idValue = [jsonWindowController.jsonDict objectForKey:@"objectvalueid"];
    if (idValue) {
        [_jsonWindowControllers removeObjectForKey:[MODServer convertObjectToJson:[MODSortedMutableDictionary sortedDictionaryWithObject:idValue forKey:@"_id"] pretty:NO]];
    } else {
        [_jsonWindowControllers removeObjectForKey:jsonWindowController.jsonDict];
    }
}

- (IBAction)chooseExportPath:(id)sender
{
    NSSavePanel *tvarNSSavePanelObj = [NSSavePanel savePanel];
    int tvarInt = [tvarNSSavePanelObj runModal];
    if(tvarInt == NSOKButton){
        NSLog(@"doSaveAs we have an OK button");
        //NSString * tvarDirectory = [tvarNSSavePanelObj directory];
        //NSLog(@"doSaveAs directory = %@",tvarDirectory);
        NSString * tvarFilename = [[tvarNSSavePanelObj URL] path];
        NSLog(@"doSaveAs filename = %@",tvarFilename);
        [expPathTextField setStringValue:tvarFilename];
    } else if(tvarInt == NSCancelButton) {
        NSLog(@"doSaveAs we have a Cancel button");
        return;
    } else {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3d",tvarInt);
        return;
    } // end if
}

- (IBAction)chooseImportPath:(id)sender
{
    NSOpenPanel *tvarNSOpenPanelObj = [NSOpenPanel openPanel];
    NSInteger tvarNSInteger = [tvarNSOpenPanelObj runModal];
    if(tvarNSInteger == NSOKButton){
        NSLog(@"doOpen we have an OK button");
        //NSString * tvarDirectory = [tvarNSOpenPanelObj directory];
        //NSLog(@"doOpen directory = %@",tvarDirectory);
        NSString * tvarFilename = [[tvarNSOpenPanelObj URL] path];
        NSLog(@"doOpen filename = %@",tvarFilename);
        [impPathTextField setStringValue:tvarFilename];
    } else if(tvarNSInteger == NSCancelButton) {
        NSLog(@"doOpen we have a Cancel button");
        return;
    } else {
        NSLog(@"doOpen tvarInt not equal 1 or zero = %ld",(long int)tvarNSInteger);
        return;
    } // end if
}

- (IBAction)segmentedControlAction:(id)sender
{
    NSString *identifier;
    
    identifier = [[NSString alloc] initWithFormat:@"%ld", (long)[segmentedControl selectedSegment]];
    [tabView selectTabViewItemWithIdentifier:identifier];
    [identifier release];
}

@end

@implementation MHQueryWindowController(MODCollectionDelegate)

- (void)mongoCollection:(MODCollection *)collection queryResultFetched:(NSArray *)result withMongoQuery:(MODQuery *)mongoQuery errorMessage:(NSString *)errorMessage
{
    [findQueryLoaderIndicator stop];
    if (collection == _mongoCollection) {
        if (errorMessage) {
            NSRunAlertPanel(@"Error", errorMessage, @"OK", nil, nil);
        } else {
            findResultsViewController.results = result;
        }
    }
}

- (void)mongoCollection:(MODCollection *)collection queryCountWithValue:(long long)value withMongoQuery:(MODQuery *)mongoQuery errorMessage:(NSString *)errorMessage
{
    if (collection == _mongoCollection) {
        if ([mongoQuery.userInfo objectForKey:@"title"]) {
            if ([mongoQuery.userInfo objectForKey:@"timequery"]) {
                [[mongoQuery.userInfo objectForKey:@"textfield"] setStringValue:[NSString stringWithFormat:[mongoQuery.userInfo objectForKey:@"title"], value, [[mongoQuery.userInfo objectForKey:@"timequery"] duration]]];
            } else {
                [[mongoQuery.userInfo objectForKey:@"textfield"] setStringValue:[NSString stringWithFormat:[mongoQuery.userInfo objectForKey:@"title"], value]];
            }
        }
    }
}

- (void)mongoCollection:(MODCollection *)collection updateDonwWithMongoQuery:(MODQuery *)mongoQuery errorMessage:(NSString *)errorMessage
{
    if (collection == _mongoCollection) {
        [findQueryLoaderIndicator stop];
        if (errorMessage) {
            NSRunAlertPanel(@"Error", errorMessage, @"OK", nil, nil);
        }
    }
}

@end

@implementation MHQueryWindowController(NSComboBox)

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [[_connectionStore queryHistoryWithDatabaseName:_mongoCollection.databaseName collectionName:_mongoCollection.collectionName] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [[[_connectionStore queryHistoryWithDatabaseName:_mongoCollection.databaseName collectionName:_mongoCollection.collectionName] objectAtIndex:index] objectForKey:@"title"];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSArray *queries;
    NSUInteger index;
    
    index = [_criteriaComboBox indexOfSelectedItem];
    queries = [_connectionStore queryHistoryWithDatabaseName:_mongoCollection.databaseName collectionName:_mongoCollection.collectionName];
    if (index < [queries count]) {
        NSDictionary *query;
        
        query = [queries objectAtIndex:[_criteriaComboBox indexOfSelectedItem]];
        if ([query objectForKey:@"fields"]) {
            [_fieldsTextField setStringValue:[query objectForKey:@"fields"]];
        } else {
            [_fieldsTextField setStringValue:@""];
        }
        if ([query objectForKey:@"sort"]) {
            [_sortTextField setStringValue:[query objectForKey:@"sort"]];
        } else {
            [_sortTextField setStringValue:@""];
        }
        if ([query objectForKey:@"skip"]) {
            [_skipTextField setStringValue:[query objectForKey:@"skip"]];
        } else {
            [_skipTextField setStringValue:@""];
        }
        if ([query objectForKey:@"limit"]) {
            [_limitTextField setStringValue:[query objectForKey:@"limit"]];
        } else {
            [_limitTextField setStringValue:@""];
        }
    }
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    NSUInteger result = NSNotFound;
    NSUInteger index = 0;
    
    for (NSDictionary *history in [_connectionStore queryHistoryWithDatabaseName:_mongoCollection.databaseName collectionName:_mongoCollection.collectionName]) {
        if ([[history objectForKey:@"title"] isEqualToString:string]) {
            result = index;
            [self comboBoxSelectionDidChange:nil];
            break;
        }
        index++;
    }
    return result;
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string
{
    NSString *result = nil;
    
    for (NSDictionary *history in [_connectionStore queryHistoryWithDatabaseName:_mongoCollection.databaseName collectionName:_mongoCollection.collectionName]) {
        if ([[history objectForKey:@"title"] hasPrefix:string]) {
            result = [history objectForKey:@"title"];
            break;
        }
    }
    return result;
}

@end
