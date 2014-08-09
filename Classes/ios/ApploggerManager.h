//
//  ApploggerManager.h
//  io.applogger.applogger-examples
//
//  Created by Mirko Olsiewicz on 13.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "ApploggerWatcherDelegate.h"
#import "ApploggerWatcher.h"
#import "ApploggerLogMessage.h"
#import "ApploggerDDASLLogger.h"

#define LogLineVersion @"01"

typedef void (^ALManagerInitiateCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALSocketConnectionCompletionHandler)(BOOL successfull, NSError *error);

typedef void (^ALSupportSessionRequestCompletionHandler)(NSString* watcherIdentifier, NSError *error);
typedef void (^ALSupportSessionCancelCompletionHandler)(NSError *error);
typedef void (^ALRequestWatchersProfileCompletionHandler)(ApploggerWatcher* watcher, NSError *error);

@interface ApploggerManager : NSObject<ApploggerWatcherDelegate>

/*
 * Use this delegate to become notified when a new user is watching the stream
 */
@property (nonatomic, strong) id<ApploggerWatcherDelegate> watcherDelegate;

/*
 * This array contains the amount of watchers currently watching the stream 
 */
@property (nonatomic, strong) NSArray* currentWatchers;

/*
 * enable / disable TTY log for SDK
 */
@property (readwrite) BOOL isSDKConsoleLogEnable;

/*
 * create a shared instance of this class
 */
+ (ApploggerManager *)sharedApploggerManager;

/*
 * allows to set a different service uri. Calling this method is totally optional 
 * and is normally only used for debuggin against a development system when you 
 * are an SDK author
 */
-(void)setServiceUri:(NSString*)serviceUri;
    
/*
 * set application identifier
 */
-(void) setApplicationIdentifier:(NSString*)identifier AndSecret:(NSString*)secret;

/*
 * allows to override the devicename
 */
-(void) setDeviceName:(NSString*)name;

/*
 * start the Applogger
 * create stream and connect to server
 */
-(void)startApploggerManagerWithCompletion:(ALManagerInitiateCompletionHandler)completion;

/*
 * stop the Applogger
 * disconnect from server
 */
-(void)stopApploggerManager;

/*
 * add Message to Log stream on server
 */
-(void)addLogMessage:(AppLoggerLogMessage*)message;

/*
 * Temporarily Method to get assign link from app
 */
-(NSString*)getAssignDeviceLink;

/*
 * Call this method to request a support session. The support session has the state pending as long the device
 * is not disconnecting from the service.
 */
- (void)requestSupportSession:(ALSupportSessionRequestCompletionHandler)completion;

/*
 * Call this method to cancel a pending support session. When the session is established, just call stopApploggerManager
 * to disconnect from the platform 
 */
- (void)cancelRequestedSupportSession:(ALSupportSessionCancelCompletionHandler)completion;

/*
 * This request the user profile of a given watcher
 */
- (void)requestWatchersProfile:(NSString*)userIndentifier completion:(ALRequestWatchersProfileCompletionHandler)completion;

@end
