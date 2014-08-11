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
#import "ApploggerNSLogger.h"

#define LogLineVersion @"02"

typedef void (^ALManagerInitiateCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALManagerRegisterDeviceCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALManagerSessionCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALSocketConnectionCompletionHandler)(BOOL successfull, NSError *error);

typedef void (^ALSupportSessionRequestCompletionHandler)(NSString* watcherIdentifier, NSError *error);
typedef void (^ALSupportSessionCancelCompletionHandler)(NSError *error);
typedef void (^ALRequestWatchersProfileCompletionHandler)(ApploggerWatcher* watcher, NSError *error);

@class GCDAsyncSocket;

@interface ApploggerManager : NSObject<ApploggerWatcherDelegate>

/*
 * Use this delegate to become notified when a new user is watching the stream
 */
@property (readonly) BOOL loggingIsStarted;
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
-(void)startApploggerManagerWithCompletion:(ALManagerInitiateCompletionHandler)completion __attribute__((deprecated("Please use the chekInDevice and startSessionWithCompletion method instead")));

/*!
 * to check in the device to apploggerr
 */
-(void)checkInDeviceWithCompletion:(ALManagerRegisterDeviceCompletionHandler)completion;

/*!
 * open socket stream session with applogger
 */
-(void)startSessionWithCompletion:(ALManagerSessionCompletionHandler)completion;

/*!
 * close socket stream session with applogger
 */
-(void)stopSessionWithCompletion:(ALManagerSessionCompletionHandler)completion;

/*
 * stop the Applogger
 * disconnect from server
 */
-(void)stopApploggerManager
    __attribute__((deprecated("Please use the stopSessionWithCompletion method instead")));;

/*
 * add Message to Log stream on server
 */
-(void)addLogMessage:(AppLoggerLogMessage*)message;

/*
 * Temporarily Method to get assign link from app
 */
-(NSString*)getAssignDeviceLink;

/*!
 * Add NSLogger connection for applogger
 */
-(void)registerNSLoggerConnectionWithDelegate:(id<ApploggerNSLoggerDelegate>) delegate;

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
