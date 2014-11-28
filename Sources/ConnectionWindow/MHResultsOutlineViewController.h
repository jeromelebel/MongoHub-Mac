//
//  MHResultsOutlineViewController.h
//  MongoHub
//
//  Created by Syd on 10-4-26.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MHResultsOutlineViewController : NSObject
{
    NSOutlineView               *_outlineView;
    NSMutableArray              *_results;
    BOOL                        _checkingSelection;
}
@property (nonatomic, readwrite, retain) NSArray *results;
@property (nonatomic, readonly, assign) NSArray *selectedDocuments;
@property (nonatomic, readonly, assign) NSInteger selectedDocumentCount;

- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView;
- (id)rootForItem:(id)item;

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard;

@end
