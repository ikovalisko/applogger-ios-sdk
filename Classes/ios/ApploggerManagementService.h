//
//  AppLoggerManagementService.h
//  Pods
//
//  Created by Dirk Eisenberg on 21/04/14.
//
//

#import <Foundation/Foundation.h>
#import "ApploggerLogStreamConfiguration.h"

typedef void (^ALMSAnnounceDeviceCompletionHandler)(NSError *error);
typedef void (^ALMSRequestDataStreamConfigurationCompletionHandler)(AppLoggerLogStreamConfiguration* configuration, NSError *error);

@interface AppLoggerManagementService : NSObject

+ (id) service:(NSString*)applicationIdentifier withSecret:(NSString*)applicationSecret andServiceUri:(NSString*)serviceUri;

- (id) init:(NSString*)applicationIdentifier withSecret:(NSString*)applicationSecret andServiceUri:(NSString*)serviceUri;

- (NSString*) deviceIdentifier;

- (void) announceDevice:(ALMSAnnounceDeviceCompletionHandler)completion;

- (void) requestDataStreamConfiguration:(ALMSRequestDataStreamConfigurationCompletionHandler)completion;

@end
