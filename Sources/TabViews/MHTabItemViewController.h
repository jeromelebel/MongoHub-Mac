//
//  MHTabItemViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 04/12/2011.
//

#import <Cocoa/Cocoa.h>

@class MHTabViewController;

@interface MHTabItemViewController : NSViewController
{
    MHTabViewController *_tabViewController;
}

@property (nonatomic, assign, readwrite) MHTabViewController *tabViewController;

- (void)select;
- (void)willRemoveFromTabViewController;

@end
