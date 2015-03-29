//
//  MHTabTitleView.h
//  MongoHub
//
//  Created by Jérôme Lebel on 30/11/2011.
//

#import <Cocoa/Cocoa.h>

@class MHTabViewController;

@interface MHTabTitleView : NSControl
{
    MHTabViewController                 *_tabViewController;
}

@property(nonatomic, readwrite, assign) BOOL selected;
@property(nonatomic, readwrite, weak) MHTabViewController *tabViewController;

@end
