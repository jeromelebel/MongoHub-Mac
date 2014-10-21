//
//  fieldMapTableController.h
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FieldMapDataObject.h"

@interface FieldMapTableController : NSControl {
    NSMutableArray * nsMutaryDataObj;
    IBOutlet NSTableView * idTableView;
}

@property (nonatomic, retain) NSMutableArray * nsMutaryDataObj;
@property (nonatomic, retain) NSTableView * idTableView;

- (IBAction)addAtSelectedRow:(id)pId;
- (IBAction)deleteSelectedRow:(id)pId;

- (void)addRow:(FieldMapDataObject *)pDataObj;

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)pTableViewObj;

- (id) tableView:(NSTableView *)pTableViewObj 
objectValueForTableColumn:(NSTableColumn *)pTableColumn 
             row:(int)pRowIndex;

- (void)tableView:(NSTableView *)pTableViewObj 
   setObjectValue:(id)pObject 
   forTableColumn:(NSTableColumn *)pTableColumn
              row:(int)pRowIndex;

@end
