//
//  MHConnectionIconView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 07/08/2014.
//
//

#import "MHConnectionIconView.h"

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
        radius = self.bounds.size.height / 10.0;
        
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

- (void)rightMouseDown:(NSEvent *)event
{
    if (event.clickCount == 1) {
        [self.delegate connectionIconViewOpenContextualMenu:self withEvent:event];
    } else {
        [super rightMouseDown:event];
    }
}

- (void)mouseDown:(NSEvent *)event
{
    if (event.modifierFlags & NSControlKeyMask) {
        [self.delegate connectionIconViewOpenContextualMenu:self withEvent:event];
    } else if (event.clickCount == 2) {
        [self.delegate connectionIconViewDoubleClick:self];
    } else {
        [super mouseDown:event];
    }
}

@end
