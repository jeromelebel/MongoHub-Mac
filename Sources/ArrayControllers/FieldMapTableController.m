//
//  fieldMapTableController.m
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "FieldMapTableController.h"


@implementation FieldMapTableController
@synthesize nsMutaryDataObj;
@synthesize idTableView;

- (void)dealloc {
    [nsMutaryDataObj release];
    [idTableView release];
    [super dealloc];
}

- (IBAction)addAtSelectedRow:(id)pId {
    if ([idTableView selectedRow] > -1) {
        NSString * zStr1 = @"Text Cell 1";
        NSString * zStr2 = @"Text Cell 2";
        FieldMapDataObject * zDataObject = [[FieldMapDataObject alloc]initWithSqlKey:zStr1 
                                                               andMongoKey:zStr2 ];
        [self.nsMutaryDataObj insertObject:zDataObject 
                                   atIndex:[idTableView selectedRow]];
        [zDataObject release];
        [idTableView reloadData];
    } // end if
    
} // end deleteSelectedRow


- (IBAction)deleteSelectedRow:(id)pId {
    if ([idTableView selectedRow] > -1) {
        [self.nsMutaryDataObj removeObjectAtIndex:[idTableView selectedRow]];
        [idTableView reloadData];
    } // end if
} // end deleteSelectedRow


- (void)addRow:(FieldMapDataObject *)pDataObj {
    [self.nsMutaryDataObj addObject:pDataObj];
    [idTableView reloadData];
} // end addRow


- (NSUInteger)numberOfRowsInTableView:(NSTableView *)pTableViewObj {
    return [self.nsMutaryDataObj count];
} // end numberOfRowsInTableView


- (id) tableView:(NSTableView *)pTableViewObj 
objectValueForTableColumn:(NSTableColumn *)pTableColumn
             row:(int)pRowIndex {
    FieldMapDataObject * zDataObject = (FieldMapDataObject *)[self.nsMutaryDataObj objectAtIndex:pRowIndex];
    if (! zDataObject) {
        NSLog(@"tableView: objectAtIndex:%d = NULL",pRowIndex);
        return NULL;
    } // end if
    //NSLog(@"pTableColumn identifier = %@",[pTableColumn identifier]);
    
    if ([[pTableColumn identifier] isEqualToString:@"Col_ID1"]) {
        return [zDataObject sqlKey];
    }
    
    if ([[pTableColumn identifier] isEqualToString:@"Col_ID2"]) {
        return [zDataObject mongoKey];
    }
    
    NSLog(@"***ERROR** dropped through pTableColumn identifiers");
    return NULL;
    
} // end tableView:objectValueForTableColumn:row:


- (void)tableView:(NSTableView *)pTableViewObj 
   setObjectValue:(id)pObject 
   forTableColumn:(NSTableColumn *)pTableColumn 
              row:(int)pRowIndex {
    
    FieldMapDataObject * zDataObject   = (FieldMapDataObject *)[self.nsMutaryDataObj objectAtIndex:pRowIndex];
    
    if ([[pTableColumn identifier] isEqualToString:@"Col_ID1"]) {
        [zDataObject setSqlKey:(NSString *)pObject];
    }
    
    if ([[pTableColumn identifier] isEqualToString:@"Col_ID2"]) {
        [zDataObject setMongoKey:(NSString *)pObject];
    }
} // end tableView:setObjectValue:forTableColumn:row:

@end
