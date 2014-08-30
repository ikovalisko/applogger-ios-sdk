//
//  AppLoggerManagementService.h
//  Pods
//
//  Created by Dirk Eisenberg on 21/04/14.
//
//

#import <Foundation/Foundation.h>
#import "ApploggerLogStreamConfiguration.h"
#import "ApploggerWatcher.h"

typedef void (^ALMSAnnounceDeviceCompletionHandler)(NSError *error);
typedef void (^ALMSRequestDataStreamConfigurationCompletionHandler)(AppLoggerLogStreamConfiguration* configuration, NSError *error);
typedef void (^ALMSRequestWatchersProfileCompletionHandler)(ApploggerWatcher* watcher, NSError *error);
typedef void (^ALMSRequestSupportSessionCompletionHandler)(NSError *error);

@interface AppLoggerManagementService : NSObject

+ (id) service:(NSString*)applicationIdentifier withSecret:(NSString*)applicationSecret andServiceUri:(NSString*)serviceUri;

- (NSString*) deviceIdentifier;

- (void) announceDeviceWithName:(NSString*)name completion:(ALMSAnnounceDeviceCompletionHandler)completion;

- (void) requestDataStreamConfiguration:(ALMSRequestDataStreamConfigurationCompletionHandler)completion;

- (void) requestWatchersProfile:(NSString*)userIndentifier completion:(ALMSRequestWatchersProfileCompletionHandler)completion;

@end
