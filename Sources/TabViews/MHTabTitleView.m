//
//  MHTabTitleView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 30/11/2011.
//

#import "MHTabTitleView.h"
#import "MHTabViewController.h"

#define CLOSE_BUTTON_MARGIN 20.0

static NSMutableDictionary *_drawingObjects = nil;

static void initializeImages(void)
{
    if (!_drawingObjects) {
        _drawingObjects = [[NSMutableDictionary alloc] init];
        [_drawingObjects setObject:[NSArray arrayWithObjects:[NSImage imageNamed:@"background_blue_left"], [NSImage imageNamed:@"background_blue_center"], [NSImage imageNamed:@"background_blue_right"], nil] forKey:@"selected_tab"];
        [_drawingObjects setObject:[NSImage imageNamed:@"unselected-tab-background"] forKey:@"unselected-tab-background"];
        [_drawingObjects setObject:[NSImage imageNamed:@"unselected-tab-border"] forKey:@"unselected-tab-border"];
        [_drawingObjects setObject:[NSImage imageNamed:@"background_blue_arrow"] forKey:@"selected_tab_arrow"];
        [_drawingObjects setObject:[NSImage imageNamed:@"close_button"] forKey:@"close_button"];
        [_drawingObjects setObject:[NSImage imageNamed:@"overlay_close_button"] forKey:@"overlay_close_button"];
        [_drawingObjects setObject:[NSImage imageNamed:@"grip_button"] forKey:@"grip_button"];
    }
}

@implementation MHTabTitleView

@synthesize selected = _selected, tabViewController = _tabViewController;

- (id)initWithFrame:(NSRect)frame
{
    initializeImages();
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableParagraphStyle *mutParaStyle = [[NSMutableParagraphStyle alloc] init];
        
        [mutParaStyle setAlignment:NSCenterTextAlignment];
        [mutParaStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
        _titleAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:mutParaStyle, NSParagraphStyleAttributeName, nil];
        [_titleAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        _attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Loading…" attributes:_titleAttributes];
        _titleCell = [[NSCell alloc] init];
        _titleCell.attributedStringValue = _attributedTitle;

        [mutParaStyle release];
}
    
    return self;
}

- (void)dealloc
{
    [_titleAttributes release];
    [_attributedTitle release];
    [_titleCell release];
    [super dealloc];
}

- (NSRect)_closeButtonRect
{
    NSRect result;
    
    result = self.bounds;
    result.origin.x += 5.0;
    result.origin.y = ceil(result.size.height - [[_drawingObjects objectForKey:@"unselected-tab-background"] size].height + (([[_drawingObjects objectForKey:@"unselected-tab-background"] size].height - [[_drawingObjects objectForKey:@"close_button"] size].height) / 2.0) - (([[_drawingObjects objectForKey:@"close_button"] size].height - [[_drawingObjects objectForKey:@"close_button"] size].height) / 2.0));
    result.size.width = result.size.height = [[_drawingObjects objectForKey:@"close_button"] size].height;
    return result;
}

- (NSRect)_gripButtonRect
{
    NSRect result;
    
    result = self.bounds;
    result.origin.x = result.size.width - 5.0 - [[_drawingObjects objectForKey:@"grip_button"] size].width;
    result.origin.y = ceil(result.size.height - [[_drawingObjects objectForKey:@"unselected-tab-background"] size].height + (([[_drawingObjects objectForKey:@"unselected-tab-background"] size].height - [[_drawingObjects objectForKey:@"grip_button"] size].height) / 2.0) - (([[_drawingObjects objectForKey:@"grip_button"] size].height - [[_drawingObjects objectForKey:@"grip_button"] size].height) / 2.0));
    result.size.width = result.size.height = [[_drawingObjects objectForKey:@"grip_button"] size].height;
    return result;
}

- (void)viewDidMoveToSuperview
{
    _trakingTag = [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    [super viewDidMoveToSuperview];
}

- (void)removeFromSuperview
{
    [self removeTrackingRect:_trakingTag];
    [super removeFromSuperview];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    _showCloseButton = YES;
    [self setNeedsDisplayInRect:[self _closeButtonRect]];
    [self setNeedsDisplayInRect:[self _gripButtonRect]];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    _showCloseButton = NO;
    [self setNeedsDisplayInRect:[self _closeButtonRect]];
    [self setNeedsDisplayInRect:[self _gripButtonRect]];
}

- (void)setFrame:(NSRect)frameRect
{
    [self removeTrackingRect:_trakingTag];
    [super setFrame:frameRect];
    _trakingTag = [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    _showCloseButton = [self mouse:[self convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil] inRect:self.bounds];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect titleRect = self.bounds;
    NSRect imageDisplayRect;
    NSRect mainRect;
    NSImage *image;
    
    if (_selected || _titleHit) {
        NSArray *images = [_drawingObjects objectForKey:@"selected_tab"];
        
        image = [images objectAtIndex:1];
        mainRect = self.bounds;
        mainRect.origin.y = mainRect.size.height - image.size.height;
        mainRect.size.height = image.size.height;
        [image drawInRect:mainRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
        
        image = [images objectAtIndex:0];
        [image drawAtPoint:NSMakePoint(0, self.bounds.size.height - image.size.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
        mainRect.origin.x = image.size.width;
        mainRect.origin.y = self.bounds.size.height - image.size.height;
        mainRect.size.height = image.size.height;
        
        image = [images objectAtIndex:2];
        [image drawAtPoint:NSMakePoint(self.bounds.size.width - image.size.width, self.bounds.size.height - image.size.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
        mainRect.size.width = self.bounds.size.width - mainRect.origin.x - image.size.width;
        
        if (_selected) {
            image = [_drawingObjects objectForKey:@"selected_tab_arrow"];
            [image drawAtPoint:NSMakePoint(round((self.bounds.size.width / 2.0) + (image.size.width / 2.0)), 0) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0];
        }
        [_titleAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    } else {
        image = [_drawingObjects objectForKey:@"unselected-tab-border"];
        NSRect rect1, rect2;
        
        rect1 = NSMakeRect(1, self.bounds.size.height - image.size.height, self.bounds.size.width - 2, image.size.height);
        rect2 = NSMakeRect(1, 0, 1, image.size.height);
        
        image = [_drawingObjects objectForKey:@"unselected-tab-background"];
        [image drawInRect:NSMakeRect(0, self.bounds.size.height - image.size.height, self.bounds.size.width, image.size.height) fromRect:NSMakeRect(0, 0, 1, image.size.height) operation:NSCompositeCopy fraction:1.0];
        [image drawInRect:NSMakeRect(0, self.bounds.size.height - image.size.height, 1, image.size.height) fromRect:NSMakeRect(0, 0, 1, image.size.height) operation:NSCompositeCopy fraction:1.0];
        [image drawInRect:NSMakeRect(self.bounds.size.width - 1, self.bounds.size.height - image.size.height, 1, image.size.height) fromRect:NSMakeRect(1, 0, 1, image.size.height) operation:NSCompositeCopy fraction:1.0];
        [_titleAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    }
    [_attributedTitle setAttributes:_titleAttributes range:NSMakeRange(0, _attributedTitle.length)];
    _titleCell.attributedStringValue = _attributedTitle;
    
    titleRect.size.height -= 7;
    titleRect.origin.x += CLOSE_BUTTON_MARGIN;
    titleRect.size.width -= CLOSE_BUTTON_MARGIN * 2.0;
    [_titleCell drawInteriorWithFrame:titleRect inView:self];
    imageDisplayRect = [self _closeButtonRect];
    if (_showCloseButton && NSIntersectsRect(dirtyRect, imageDisplayRect)) {
        if (_closeButtonHit) {
            image = [_drawingObjects objectForKey:@"overlay_close_button"];
        } else {
            image = [_drawingObjects objectForKey:@"close_button"];
        }
        
        [image drawInRect:imageDisplayRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0];
    }
    
    imageDisplayRect = [self _gripButtonRect];
    if (_showCloseButton && NSIntersectsRect(dirtyRect, imageDisplayRect)) {
        image = [_drawingObjects objectForKey:@"grip_button"];
        [image drawInRect:imageDisplayRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0];
    }
}

static NSComparisonResult orderFromView(id view1, id view2, void *current)
{
    if (view1 == current) {
        return NSOrderedDescending;
    } else if (view2 == current) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL keepOn = YES;
    BOOL titleHit = YES;
    BOOL closeButtonHit;
    NSPoint locationInView;
    NSPoint locationInWindow;
    NSPoint firstLocationInView;
    NSRect closeButtonRect = [self _closeButtonRect];
    BOOL startToDrag = NO;
    BOOL firstClickInCloseButton;
    NSRect originalFrame = self.frame;
    
    [self.superview sortSubviewsUsingFunction:orderFromView context:self];
    locationInWindow = [theEvent locationInWindow];
    firstLocationInView = locationInView = [self convertPoint:locationInWindow fromView:nil];
    firstClickInCloseButton = [self mouse:firstLocationInView inRect:closeButtonRect];
    while (keepOn) {
        locationInWindow = [theEvent locationInWindow];
        if (!startToDrag && !firstClickInCloseButton && pow(firstLocationInView.x - locationInView.x, 2) >= 100) {
            startToDrag = YES;
            self.alphaValue = 0.8;
        }
        locationInView = [self convertPoint:locationInWindow fromView:nil];
        titleHit = [self mouse:locationInView inRect:self.bounds];
        closeButtonHit = !startToDrag && [self mouse:locationInView inRect:closeButtonRect];
        
        if (closeButtonHit != _closeButtonHit || (titleHit || startToDrag) != _titleHit) {
            _closeButtonHit = closeButtonHit;
            _titleHit = titleHit || startToDrag;
            [self setNeedsDisplay];
        }
        switch ([theEvent type]) {
            case NSLeftMouseDragged:
                if (startToDrag) {
                    NSRect newFrame;
                    NSPoint locationInSuperview;
                    
                    newFrame = self.frame;
                    newFrame.origin.x += locationInView.x - firstLocationInView.x;
                    locationInSuperview = [self.superview convertPoint:locationInWindow fromView:nil];
                    if (locationInSuperview.x < originalFrame.origin.x && self.tag > 0) {
                        [_tabViewController moveTabItemFromIndex:self.tag toIndex:self.tag - 1];
                        originalFrame = self.frame;
                    } else if (locationInSuperview.x > originalFrame.origin.x + originalFrame.size.width && self.tag < _tabViewController.tabCount - 1) {
                        [_tabViewController moveTabItemFromIndex:self.tag toIndex:self.tag + 1];
                        originalFrame = self.frame;
                    }
                    if (newFrame.origin.x < 0) {
                        newFrame.origin.x = 0;
                    } else if (newFrame.origin.x + newFrame.size.width > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
                        newFrame.origin.x = self.superview.bounds.origin.x + self.superview.bounds.size.width - newFrame.size.width;
                    }
                    self.frame = newFrame;
                }
                break;
            case NSLeftMouseUp:
                _showCloseButton = NO;
                if (closeButtonHit) {
                    [_tabViewController removeTabItemViewController:[_tabViewController tabItemViewControlletAtIndex:self.tag]];
                } else if (titleHit) {
                    _tabViewController.selectedTabIndex = self.tag;
                    [self setNeedsDisplay];
                } else {
                    [self setNeedsDisplay];
                }
                keepOn = NO;
                break;
            default:
                /* Ignore any other kind of event. */
                break;
        }
        if (keepOn) {
            theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        }
    };
    if (startToDrag) {
        self.alphaValue = 1.0;
    }
    self.frame = originalFrame;
    _titleHit = NO;
}

- (void)setStringValue:(NSString *)aString
{
    if (aString) {
        [_attributedTitle.mutableString setString:aString];
        _titleCell.attributedStringValue = _attributedTitle;
        [self setNeedsDisplay];
    }
}

- (NSString *)stringValue
{
    return _titleCell.attributedStringValue.string;
}

@end
