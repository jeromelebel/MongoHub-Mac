//
//  MHExporterImporter.h
//  MongoHub
//
//  Created by Jérôme Lebel on 16/04/14.
//

#import <Foundation/Foundation.h>

extern NSString *MHImporterExporterStartNotification;
extern NSString *MHImporterExporterStopNotification;
extern NSString *MHImporterExporterProgressNotification;
extern NSString *MHImporterExporterNotificationProgressKey;

@protocol MHImporterExporter <NSObject>
@property (nonatomic, readonly, retain) NSError *error;

@end
