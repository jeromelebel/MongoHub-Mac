//
//  MHActivityMonitorViewController.m
//  MongoHub
//
//  Created by Jérôme Lebel on 20/10/2014.
//
//

#import "MHActivityMonitorViewController.h"
#import <MongoObjcDriver/MongoObjcDriver.h>

@interface MHActivityMonitorViewController ()
@property (nonatomic, readwrite, strong) MODClient *client;
@property (nonatomic, readwrite, strong) NSTimer *timer;
@property (nonatomic, readwrite, strong) NSMutableArray *data;
@property (nonatomic, readwrite, strong) MODQuery *query;

@property (nonatomic, readwrite, weak) IBOutlet NSTableView *tableView;

@end

@implementation MHActivityMonitorViewController

@synthesize client = _client;
@synthesize timer = _timer;
@synthesize data = _data;
@synthesize query = _query;

@synthesize tableView = _tableView;

- (id)initWithClient:(MODClient *)client
{
    if (self = [self init]) {
        self.client = client;
        self.data = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.client = nil;
    self.timer = nil;
    self.data = nil;
    self.query =  nil;
    [super dealloc];
}

- (NSString *)nibName
{
    return @"MHActivityMonitorTab";
}

- (void)awakeFromNib
{
    [self fetchServerStatusDelta];
    self.title = @"Activity Monitor";
}

- (void)willRemoveFromTabViewController
{
    [self.query cancel];
    [self.timer invalidate];
    self.timer = nil;
}

static int percentage(NSNumber *previousValue, NSNumber *previousOutOfValue, NSNumber *value, NSNumber *outOfValue)
{
    double valueDiff = [value doubleValue] - [previousValue doubleValue];
    double outOfValueDiff = [outOfValue doubleValue] - [previousOutOfValue doubleValue];
    return (outOfValueDiff == 0) ? 0.0 : (valueDiff * 100.0 / outOfValueDiff);
}

static void addObjectForKeyWithDefault(NSMutableDictionary *dictionary, id value, NSString *key, id defaultValue)
{
    if (value) {
        dictionary[key] = value;
    } else {
        dictionary[key] = defaultValue;
    }
}

- (void)fetchServerStatusDelta
{
    self.query = [self.client serverStatusWithReadPreferences:nil callback:^(MODSortedMutableDictionary *serverStatus, MODQuery *mongoQuery) {
        NSMutableDictionary *diff = [[NSMutableDictionary alloc] init];
        
        if (_previousServerStatusForDelta) {
            NSNumber *number;
            NSDate *date;
            
            for (NSString *key in [[serverStatus objectForKey:@"opcounters"] allKeys]) {
                number = [[NSNumber alloc] initWithInteger:[[[serverStatus objectForKey:@"opcounters"] objectForKey:key] integerValue] - [[[_previousServerStatusForDelta objectForKey:@"opcounters"] objectForKey:key] integerValue]];
                [diff setObject:number forKey:key];
                [number release];
            }
            if ([[serverStatus objectForKey:@"mem"] objectForKey:@"mapped"]) {
                [diff setObject:[[serverStatus objectForKey:@"mem"] objectForKey:@"mapped"] forKey:@"mapped"];
            }
            addObjectForKeyWithDefault(diff, [[serverStatus objectForKey:@"mem"] objectForKey:@"virtual"], @"vsize", @"-");
            addObjectForKeyWithDefault(diff, [[serverStatus objectForKey:@"mem"] objectForKey:@"resident"], @"res", @"-");
            number = [[NSNumber alloc] initWithInteger:[[[serverStatus objectForKey:@"extra_info"] objectForKey:@"page_faults"] integerValue] - [[[_previousServerStatusForDelta objectForKey:@"extra_info"] objectForKey:@"page_faults"] integerValue]];
            [diff setObject:number forKey:@"faults"];
            [number release];
            number = [[NSNumber alloc] initWithInteger:percentage([[_previousServerStatusForDelta objectForKey:@"globalLock"] objectForKey:@"lockTime"],
                                                                  [[_previousServerStatusForDelta objectForKey:@"globalLock"] objectForKey:@"totalTime"],
                                                                  [[serverStatus objectForKey:@"globalLock"] objectForKey:@"lockTime"],
                                                                  [[serverStatus objectForKey:@"globalLock"] objectForKey:@"totalTime"])];
            [diff setObject:number forKey:@"locked"];
            [number release];
            number = [[NSNumber alloc] initWithInteger:percentage([[[_previousServerStatusForDelta objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"misses"],
                                                                  [[[_previousServerStatusForDelta objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"accesses"],
                                                                  [[[serverStatus objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"misses"],
                                                                  [[[serverStatus objectForKey:@"indexCounters"] objectForKey:@"btree"] objectForKey:@"accesses"])];
            [diff setObject:number forKey:@"misses"];
            [number release];
            date = [[NSDate alloc] init];
            addObjectForKeyWithDefault(diff, [[serverStatus objectForKey:@"connections"] objectForKey:@"current"], @"conn", @"-");
            [diff setObject:date forKey:@"time"];
            [date release];
            [self.data addObject:diff];
            [self.tableView reloadData];
            [self.tableView scrollRowToVisible:self.data.count - 1];
        }
        if (_previousServerStatusForDelta) {
            [_previousServerStatusForDelta release];
        }
        _previousServerStatusForDelta = [serverStatus retain];
        [diff release];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fetchServerStatusDelta) userInfo:nil repeats:NO];
    }];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.data.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)index {
    NSDictionary *row = self.data[index];
    
    return row[tableColumn.identifier];
    
}

@end
