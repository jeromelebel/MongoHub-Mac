//
//  MHAddCollectionController.h
//  MongoHub
//
//  Created by Syd on 10-4-28.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MHAddCollectionController : NSWindowController
{
    IBOutlet NSTextField *collectionname;
    NSMutableString *dbname;
}

@property (nonatomic, retain) NSTextField *collectionname;
@property (nonatomic, retain) NSString *dbname;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)modalForWindow:(NSWindow *)window;

@end
