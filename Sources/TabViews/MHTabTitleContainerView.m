//
//  MHTabTitleContainerView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 08/04/12.
//

#import "MHTabTitleContainerView.h"

static NSMutableArray *_backgroundImages = nil;

@implementation MHTabTitleContainerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_backgroundImages) {
            _backgroundImages = [[NSMutableArray alloc] init];
            [_backgroundImages addObject:[NSImage imageNamed:@"background-grey_left"]];
            [_backgroundImages addObject:[NSImage imageNamed:@"background-grey_center"]];
            [_backgroundImages addObject:[NSImage imageNamed:@"background-grey_right"]];
        }
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSImage *image;
    NSRect centerRect;
    
    image = [_backgroundImages objectAtIndex:0];
    [image drawAtPoint:NSMakePoint(0, self.bounds.size.height - image.size.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
    centerRect.origin.x = image.size.width;
    centerRect.origin.y = self.bounds.size.height - image.size.height;
    centerRect.size.height = image.size.height;
    
    image = [_backgroundImages objectAtIndex:2];
    [image drawAtPoint:NSMakePoint(self.bounds.size.width - image.size.width, self.bounds.size.height - image.size.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
    centerRect.size.width = self.bounds.size.width - centerRect.origin.x - image.size.width;
    
    image = [_backgroundImages objectAtIndex:1];
    [image drawInRect:centerRect fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeCopy fraction:1.0];
}

@end
