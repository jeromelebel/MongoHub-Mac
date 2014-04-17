//
//  MHTabItemViewController.h
//  MongoHub
//
//  Created by Jérôme Lebel on 04/12/11.
//

#import <Cocoa/Cocoa.h>

@class MHTabViewController;

@interface MHTabItemViewController : NSViewController
{
    MHTabViewController *_tabViewController;
}

@property (nonatomic, assign, readwrite) MHTabViewController *tabViewController;

- (void)select;

@end
