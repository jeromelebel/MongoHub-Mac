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
@property (nonatomic, retain, readwrite) NSArray *results;
@property (nonatomic, assign, readonly) NSArray *selectedDocuments;

- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView;
- (id)rootForItem:(id)item;

@end
