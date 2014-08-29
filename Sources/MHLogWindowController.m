//
//  MHLogWindowController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 28/08/2014.
//
//

#import "MHLogWindowController.h"

@interface MHLogWindowController ()
@property (nonatomic, strong, readwrite) NSMutableArray *logs;
@property (nonatomic, assign, readwrite) IBOutlet NSTableView *logTableView;

@end

@implementation MHLogWindowController

@synthesize delegate = _delegate;
@synthesize logs = _logs;
@synthesize logTableView = _logTableView;

+ (instancetype)logWindowController
{
    return [[[MHLogWindowController alloc] initWithWindowNibName:@"MHLogWindow"] autorelease];
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.logs = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.logs = nil;
    [super dealloc];
}

- (void)addLogLine:(NSString *)line domain:(NSString *)domain level:(NSString *)level
{
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLogLine:line domain:domain level:level];
        });
    } else {
        if (!domain) {
            domain = @"";
        }
        if (!level) {
            level = @"";
        }
        [self willChangeValueForKey:@"logs"];
        [self.logs addObject:@{ @"log": line, @"domain": domain, @"level": level, @"date": [NSDate date] }];
        [self didChangeValueForKey:@"logs"];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.delegate logWindowControllerWillClose:self];
}

- (void)copy:(id)sender
{
    NSIndexSet *selectedRowIndexes = [self.logTableView selectedRowIndexes];
    NSMutableString *result;
    
    result = [NSMutableString string];
    [selectedRowIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        for (NSUInteger index = range.location; index < range.location + range.length; index++) {
            NSDictionary *log = self.logs[index];
            [result appendFormat:@"%@ %@ %@ %@\n", log[@"date"], log[@"domain"], log[@"level"], log[@"log"]];
        }
    }];
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    
    [pasteboard declareTypes:@[ NSStringPboardType ] owner:nil];
    [pasteboard setString:result forType:NSStringPboardType];
}

@end
