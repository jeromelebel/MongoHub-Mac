//
//  MHConnectionIconView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import "MHConnectionIconView.h"

@interface MHConnectionIconView ()
@property (nonatomic, readonly, weak) NSTextField *connectionLabel;
@property (nonatomic, readonly, weak) NSImageView *connectionIcon;

@end

@implementation MHConnectionIconView

@synthesize delegate = _delegate;

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (self.delegate.isSelected) {
        NSRect rect = self.bounds;
        CGFloat x[3], y[3], radius;
        NSBezierPath *bezierPath;
        
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
        bezierPath = NSBezierPath.bezierPath;
        radius = rect.size.height / 10.0;
        
        x[0] = NSMinX(rect);
        x[1] = NSMidX(rect);
        x[2] = NSMaxX(rect);
        y[0] = NSMinY(rect);
        y[1] = NSMidY(rect);
        y[2] = NSMaxY(rect);
        
        [bezierPath moveToPoint:NSMakePoint(x[0], y[1])];
        [bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(x[0], y[2]) toPoint:NSMakePoint(x[1], y[2]) radius:radius];
        [bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(x[2], y[2]) toPoint:NSMakePoint(x[2], y[1]) radius:radius];
        [bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(x[2], y[0]) toPoint:NSMakePoint(x[1], y[0]) radius:radius];
        [bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(x[0], y[0]) toPoint:NSMakePoint(x[0], y[1]) radius:radius];
        [bezierPath closePath];
        [bezierPath fill];
    }
}

- (NSTextField *)connectionLabel
{
    return [self viewWithTag:1];
}

- (NSImageView *)connectionIcon
{
    return [self viewWithTag:2];
}

- (void)setFrameSize:(NSSize)newSize
{
    NSFont *font = nil;
    NSRect frame;
    NSRect selfBounds = self.bounds;
    NSTextField *connectionLabel = self.connectionLabel;
    NSImageView *connectionIcon = self.connectionIcon;
    
    [super setFrameSize:newSize];
    if (newSize.width < 90) {
        font = [NSFont systemFontOfSize:8.0];
    } else if (newSize.width < 100) {
        font = [NSFont systemFontOfSize:9.0];
    } else if (newSize.width < 110) {
        font = [NSFont systemFontOfSize:10.0];
    } else if (newSize.width < 130) {
        font = [NSFont systemFontOfSize:11.0];
    } else if (newSize.width < 150) {
        font = [NSFont systemFontOfSize:12.0];
    } else {
        font = [NSFont systemFontOfSize:13.0];
    }
    connectionLabel.font = font;
    
    [connectionLabel sizeToFit];
    frame = connectionLabel.frame;
    frame.origin.x = selfBounds.size.height / 10.0;
    frame.size.width = selfBounds.size.width - frame.origin.x * 2;
    frame.origin.y = selfBounds.size.height / 10.0;
    connectionLabel.frame = frame;
    
    frame = NSMakeRect(0, frame.origin.y + frame.size.height, selfBounds.size.width, selfBounds.size.height - frame.origin.y - frame.size.height - selfBounds.size.height / 10.0);
    connectionIcon.frame = frame;
}

- (void)mouseDown:(NSEvent *)event
{
    if (event.modifierFlags & NSControlKeyMask) {
        self.delegate.selected = YES;
        [self.delegate connectionIconViewOpenContextualMenu:self withEvent:event];
    } else if (event.clickCount == 2) {
        [self.delegate connectionIconViewDoubleClick:self];
    } else {
        [super mouseDown:event];
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    if (self.window.attachedSheet) {
        [super rightMouseDown:event];
    } else {
        self.delegate.selected = YES;
        [self.delegate connectionIconViewOpenContextualMenu:self withEvent:event];
    }
}

@end
