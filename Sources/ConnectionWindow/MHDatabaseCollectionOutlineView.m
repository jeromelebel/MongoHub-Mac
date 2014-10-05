//
//  MHDatabaseCollectionOutlineView.m
//  MongoHub
//
//  Created by Jérôme Lebel on 04/10/2014.
//
//

#import "MHDatabaseCollectionOutlineView.h"

@implementation MHDatabaseCollectionOutlineView

- (void)openContextualMenuWithEvent:(NSEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(databaseCollectionOutlineView:contextualMenuWithEvent:)]) {
        NSMenu *menu;
        NSInteger index;
        
        index = [self rowAtPoint:[self convertPoint:event.locationInWindow fromView:nil]];
        if (index != -1) {
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        } else {
            [self selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        }
        menu = [(id<MHDatabaseCollectionOutlineViewDelegate>)self.delegate databaseCollectionOutlineView:self contextualMenuWithEvent:event];
        [NSMenu popUpContextMenu:menu withEvent:event forView:self];
    }
}

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    if ((event.modifierFlags & NSControlKeyMask) == NSControlKeyMask) {
        [self openContextualMenuWithEvent:event];
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    [self openContextualMenuWithEvent:event];
}

@end
