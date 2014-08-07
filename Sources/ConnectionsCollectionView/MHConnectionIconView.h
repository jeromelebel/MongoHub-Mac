//
//  MHConnectionIconView.h
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import <Cocoa/Cocoa.h>

@class MHConnectionIconView;

@protocol MHConnectionIconViewDelegate <NSObject>
@property (nonatomic, readwrite, assign, getter = isSelected) BOOL selected;

- (void)connectionIconViewDoubleClick:(MHConnectionIconView *)connectionIconView;
- (void)connectionIconViewOpenContextualMenu:(MHConnectionIconView *)connectionIconView withEvent:(NSEvent *)event;

@end

@interface MHConnectionIconView : NSView
{
    BOOL                                _selected;
    id<MHConnectionIconViewDelegate>    _delegate;
}
@property (nonatomic, readwrite, assign, getter = isSelected) BOOL selected;
@property (nonatomic, readwrite, weak) id<MHConnectionIconViewDelegate> delegate;

@end
