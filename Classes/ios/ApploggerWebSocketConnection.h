//
//  AppLoggerWebSocketConnection.h
//  Pods
//
//  Created by Dirk Eisenberg on 22/04/14.
//
//

#import <Foundation/Foundation.h>
#import "ApploggerWatcherDelegate.h"

@class AppLoggerWebSocketConnection;
@class AppLoggerLogMessage;

typedef void (^AppLoggerWebSockerConnectionOpenHandler)(AppLoggerWebSocketConnection* connection, NSError *error);

@interface AppLoggerWebSocketConnection : NSObject

@property (nonatomic, strong) id<ApploggerWatcherDelegate> watcherDelegate;

+ (AppLoggerWebSocketConnection*) connect:(NSString*)host withPort:(NSInteger)port andProtocol:(NSString*)protocol
                                    onApp:(NSString*)appId withSecret:(NSString*)appSecret
                                forDevice:(NSString*)deviceId
                              andObserver:(id<ApploggerWatcherDelegate>)observer
                               completion:(AppLoggerWebSockerConnectionOpenHandler)completion;

- (void) disconnect;

- (void) log:(AppLoggerLogMessage*)message;

- (BOOL) hasValidConnection;

- (BOOL) hasValidListener;
@end
