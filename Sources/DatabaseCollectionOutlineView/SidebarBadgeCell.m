//
//  TSBadgeCell.m
//  Tahsis
//
//  Created by Matteo Bertozzi on 11/29/08.
//  Copyright 2008 Matteo Bertozzi. All rights reserved.
//

#import "SidebarBadgeCell.h"

@interface SidebarBadgeCell (Private)
- (CGFloat)drawBadge:(NSRect)cellFrame;
@end

@implementation SidebarBadgeCell

#define TSBADGECELL_BUFFER_LEFT_SMALL       2
#define TSBADGECELL_BUFFER_LEFT             4
#define TSBADGECELL_BUFFER_SIDE             3
#define TSBADGECELL_BUFFER_TOP              3
#define TSBADGECELL_PADDING                 6

#define TSBADGECELL_CIRCLE_BUFFER_RIGHT     5

#define TSBADGECELL_RADIUS_X                7
#define TSBADGECELL_RADIUS_Y                8

#define TSBADGECELL_TEXT_HEIGHT             14
#define TSBADGECELL_TEXT_MINI               8
#define TSBADGECELL_TEXT_SMALL              20

#define TSBADGECELL_ICON_SIZE               16
#define TSBADGECELL_ICON_HEIGHT_OFFSET      2

@synthesize badgeCount = _badgeCount;
@synthesize hasBadge = _hasBadge;
@synthesize icon = _icon;

- (id)copyWithZone:(NSZone*)zone
{
    SidebarBadgeCell *cell = [super copyWithZone:zone];
    cell->_icon = [_icon retain];
    return cell;
}

- (void)dealloc
{
    [_icon release];
    [super dealloc];
}

- (void)awakeFromNib
{
    _badgeCount = 0;
    _hasBadge = NO;
    _icon = nil;
}

- (void)setIcon:(NSImage *)icon
{
    if (_icon != icon) {
        [_icon release];
        _icon = [icon retain];
//        [_icon setFlipped:YES];
        [_icon setSize:NSMakeSize(TSBADGECELL_ICON_SIZE, TSBADGECELL_ICON_SIZE)];
    }
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    bool drawBadge = (_hasBadge && cellFrame.size.width > TSBADGECELL_TEXT_SMALL * 3);
    CGFloat badgeWidth = (drawBadge ? [self drawBadge:cellFrame] : 0);
    
    if (_icon != nil) {
        // Draw Icon
        NSRect iconRect = cellFrame;
        iconRect.origin.y += (cellFrame.size.height - TSBADGECELL_ICON_SIZE) / 2.0;
        iconRect.size.height = TSBADGECELL_ICON_SIZE;
        iconRect.size.width = TSBADGECELL_ICON_SIZE;
        [_icon drawInRect:iconRect fromRect:NSZeroRect
                operation:NSCompositeSourceOver fraction:1.0];
    
        // Draw Rect
        NSRect labelRect = cellFrame;
        labelRect.origin.x += TSBADGECELL_ICON_SIZE + TSBADGECELL_BUFFER_LEFT;
        labelRect.size.width -= (badgeWidth + TSBADGECELL_ICON_SIZE + TSBADGECELL_BUFFER_LEFT);
        [super drawInteriorWithFrame:labelRect inView:controlView];
    } else {
        NSRect labelRect = cellFrame;
        labelRect.size.width -= badgeWidth;
        [super drawInteriorWithFrame:labelRect inView:controlView];
    }
}

- (CGFloat)drawBadge:(NSRect)cellFrame
{
    // Setup Badge String and Size
    NSString *badge = [[NSString alloc] initWithFormat:@"%ld", (long)_badgeCount];
    NSSize badgeNumSize = [badge sizeWithAttributes:nil];
    NSFont *badgeFont = [self font];
    
    // Calculate the Badge's coordinate
    CGFloat badgeWidth = badgeNumSize.width + TSBADGECELL_BUFFER_SIDE * 2;
    if (badgeNumSize.width < TSBADGECELL_TEXT_MINI) {
        badgeWidth = TSBADGECELL_TEXT_SMALL;
    }

    CGFloat badgeY = cellFrame.origin.y + ((cellFrame.size.height - TSBADGECELL_TEXT_HEIGHT) / 2.0);
    CGFloat badgeX = cellFrame.origin.x + cellFrame.size.width - 
                     TSBADGECELL_CIRCLE_BUFFER_RIGHT - badgeWidth;
    CGFloat badgeNumX = badgeX + TSBADGECELL_BUFFER_LEFT;
    if (badgeNumSize.width < TSBADGECELL_TEXT_MINI) {
        badgeNumX += TSBADGECELL_BUFFER_LEFT_SMALL;
    }

    // Draw the badge and number
    NSRect badgeRect = NSMakeRect(badgeX, badgeY, badgeWidth, TSBADGECELL_TEXT_HEIGHT);
    NSBezierPath *badgePath = [NSBezierPath bezierPathWithRoundedRect:badgeRect
                                                                xRadius:TSBADGECELL_RADIUS_X
                                                            yRadius:TSBADGECELL_RADIUS_Y];

    BOOL isWindowFront = [[NSApp mainWindow] isVisible];
    BOOL isViewInFocus = [[[[self controlView] window] firstResponder] isEqual:[self controlView]];
    BOOL isCellHighlighted = [self isHighlighted];

    NSDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:badgeFont forKey:NSFontAttributeName];

    if (isWindowFront && isViewInFocus && isCellHighlighted) {
        [[NSColor whiteColor] set];
        [dict setValue:[NSColor alternateSelectedControlColor] forKey:NSForegroundColorAttributeName];
    } else if (isWindowFront && isViewInFocus && !isCellHighlighted) {
        [[NSColor colorWithCalibratedRed:0.53 green:0.60 blue:0.74 alpha:1.0] set];
        [dict setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    } else if (isWindowFront && isCellHighlighted) {
        [[NSColor whiteColor] set];
        [dict setValue:[NSColor colorWithCalibratedRed:0.51 green:0.58 blue:0.72 alpha:1.0] forKey:NSForegroundColorAttributeName];
    } else if (!isWindowFront && isCellHighlighted) {
        [[NSColor whiteColor] set];
        [dict setValue:[NSColor disabledControlTextColor] forKey:NSForegroundColorAttributeName];
    } else {
        [[NSColor disabledControlTextColor] set];  
        [dict setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    }
    
    [badgePath fill];
    [badge drawAtPoint:NSMakePoint(badgeNumX, badgeY) withAttributes:dict];
    
    [badge release];
    [dict release];
    return badgeWidth + TSBADGECELL_PADDING;
}

@end
