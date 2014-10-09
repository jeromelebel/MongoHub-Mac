//
//  fieldMapDataObject.h
//  MongoHub
//
//  Created by Syd on 10-6-22.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FieldMapDataObject : NSObject {
    NSString *sqlKey;
    NSString *mongoKey;
}

@property (nonatomic, retain) NSString *sqlKey;
@property (nonatomic, retain) NSString *mongoKey;

- (instancetype)initWithSqlKey:(NSString *)pStr1 andMongoKey:(NSString *)pStr2;

@end
