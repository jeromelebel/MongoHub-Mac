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

@interface MHTabTitleView ()

@property (nonatomic, readwrite, assign) BOOL showCloseButton;
@property (nonatomic, readwrite, assign) BOOL closeButtonHit;
@property (nonatomic, readwrite, assign) BOOL titleHit;
@property (nonatomic, readwrite, assign) NSTrackingRectTag trakingTag;

@property (nonatomic, readwrite, strong) NSMutableAttributedString *attributedTitle;
@property (nonatomic, readwrite, strong) NSMutableDictionary *titleAttributes;
@property (nonatomic, readwrite, strong) NSCell *titleCell;

@end

@implementation MHTabTitleView

- (instancetype)initWithFrame:(NSRect)frame
{
    initializeImages();
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableParagraphStyle *mutParaStyle = [[NSMutableParagraphStyle alloc] init];
        
        [mutParaStyle setAlignment:NSCenterTextAlignment];
        [mutParaStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
        self.titleAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:mutParaStyle, NSParagraphStyleAttributeName, nil];
        [self.titleAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        self.attributedTitle = [[[NSMutableAttributedString alloc] initWithString:@"Loading…" attributes:self.titleAttributes] autorelease];
        self.titleCell = [[[NSCell alloc] init] autorelease];
        self.titleCell.attributedStringValue = self.attributedTitle;

        [mutParaStyle release];
}
    
    return self;
}

- (void)dealloc
{
    self.titleAttributes = nil;
    self.titleCell = nil;
    self.attributedTitle = nil;
    self.tabViewController = nil;
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
    self.trakingTag = [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    [super viewDidMoveToSuperview];
}

- (void)removeFromSuperview
{
    [self removeTrackingRect:self.trakingTag];
    [super removeFromSuperview];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.showCloseButton = YES;
    [self setNeedsDisplayInRect:[self _closeButtonRect]];
    [self setNeedsDisplayInRect:[self _gripButtonRect]];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.showCloseButton = NO;
    [self setNeedsDisplayInRect:[self _closeButtonRect]];
    [self setNeedsDisplayInRect:[self _gripButtonRect]];
}

- (void)setFrame:(NSRect)frameRect
{
    [self removeTrackingRect:self.trakingTag];
    [super setFrame:frameRect];
    self.trakingTag = [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    self.showCloseButton = [self mouse:[self convertPoint:[self convertPoint:[NSEvent mouseLocation] fromView:nil] fromView:nil] inRect:self.bounds];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect titleRect = self.bounds;
    NSRect imageDisplayRect;
    NSRect mainRect;
    NSImage *image;
    
    if (_selected || self.titleHit) {
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
        [self.titleAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    } else {
        image = [_drawingObjects objectForKey:@"unselected-tab-background"];
        [image drawInRect:NSMakeRect(0, self.bounds.size.height - image.size.height, self.bounds.size.width, image.size.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
        
        image = [_drawingObjects objectForKey:@"unselected-tab-border"];
        [image drawInRect:NSMakeRect(0, self.bounds.size.height - image.size.height, 1, image.size.height) fromRect:NSMakeRect(1, 0, 1, image.size.height) operation:NSCompositeCopy fraction:1.0];
        [image drawInRect:NSMakeRect(self.bounds.size.width - 1, self.bounds.size.height - image.size.height, 1, image.size.height) fromRect:NSMakeRect(0, 0, 1, image.size.height) operation:NSCompositeCopy fraction:1.0];

        [self.titleAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];

    }
    [self.attributedTitle setAttributes:self.titleAttributes range:NSMakeRange(0, self.attributedTitle.length)];
    self.titleCell.attributedStringValue = self.attributedTitle;
    
    titleRect.size.height -= 7;
    titleRect.origin.x += CLOSE_BUTTON_MARGIN;
    titleRect.size.width -= CLOSE_BUTTON_MARGIN * 2.0;
    [self.titleCell drawInteriorWithFrame:titleRect inView:self];
    imageDisplayRect = [self _closeButtonRect];
    if (self.showCloseButton && NSIntersectsRect(dirtyRect, imageDisplayRect)) {
        if (self.closeButtonHit) {
            image = [_drawingObjects objectForKey:@"overlay_close_button"];
        } else {
            image = [_drawingObjects objectForKey:@"close_button"];
        }
        
        [image drawInRect:imageDisplayRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0];
    }
    
    imageDisplayRect = [self _gripButtonRect];
    if (self.showCloseButton && NSIntersectsRect(dirtyRect, imageDisplayRect)) {
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
        
        if (closeButtonHit != self.closeButtonHit || (titleHit || startToDrag) != self.titleHit) {
            self.closeButtonHit = closeButtonHit;
            self.titleHit = titleHit || startToDrag;
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
                        [self.tabViewController moveTabItemFromIndex:self.tag toIndex:self.tag - 1];
                        originalFrame = self.frame;
                    } else if (locationInSuperview.x > originalFrame.origin.x + originalFrame.size.width && self.tag < self.tabViewController.tabCount - 1) {
                        [self.tabViewController moveTabItemFromIndex:self.tag toIndex:self.tag + 1];
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
                self.showCloseButton = NO;
                if (closeButtonHit) {
                    [self.tabViewController removeTabItemViewController:[self.tabViewController tabItemViewControlletAtIndex:self.tag]];
                } else if (titleHit) {
                    self.tabViewController.selectedTabIndex = self.tag;
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
    self.titleHit = NO;
}

- (void)setStringValue:(NSString *)aString
{
    if (aString) {
        [self.attributedTitle.mutableString setString:aString];
        self.titleCell.attributedStringValue = self.attributedTitle;
        [self setNeedsDisplay];
    }
}

- (NSString *)stringValue
{
    return self.titleCell.attributedStringValue.string;
}

@end
