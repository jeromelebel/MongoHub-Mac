//
//  MHTabTitleView.h
//  MongoHub
//
//  Created by Jérôme Lebel on 30/11/11.
//

#import <Cocoa/Cocoa.h>

@class MHTabViewController;

@interface MHTabTitleView : NSControl
{
    MHTabViewController *_tabViewController;
    NSMutableAttributedString *_attributedTitle;
    NSMutableDictionary *_titleAttributes;
    NSCell *_titleCell;
    NSTrackingRectTag _trakingTag;
    BOOL _selected;
    BOOL _showCloseButton;
    BOOL _closeButtonHit;
    BOOL _titleHit;
}

@property(nonatomic, assign, readwrite) BOOL selected;
@property(nonatomic, assign, readwrite) MHTabViewController *tabViewController;

@end
