//
//  MODHelper.h
//  MongoHub
//
//  Created by Jérôme Lebel on 20/09/11.
//

#import <Foundation/Foundation.h>

@class MODSortedMutableDictionary;

@interface MODHelper : NSObject

+ (NSArray *)convertForOutlineWithObjects:(NSArray *)mongoObjects bsonData:(NSArray *)allData;
+ (NSArray *)convertForOutlineWithObject:(MODSortedMutableDictionary *)mongoObject;

@end
