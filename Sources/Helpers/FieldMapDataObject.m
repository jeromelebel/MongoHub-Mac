//
//  fieldMapDataObject.m
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "FieldMapDataObject.h"


@implementation FieldMapDataObject

@synthesize sqlKey;
@synthesize mongoKey;

- (instancetype)initWithSqlKey:(NSString *)pStr1 andMongoKey:(NSString *)pStr2 {
    if (! (self = [super init])) {
        NSLog(@"MyDataObject **** ERROR : [super init] failed ***");
        return self;
    } // end if
    
    self.sqlKey = pStr1;
    self.mongoKey = pStr2;
    
    return self;
    
}

- (void) dealloc {
    [sqlKey release];
    [mongoKey release];
    [super dealloc];
}
@end
