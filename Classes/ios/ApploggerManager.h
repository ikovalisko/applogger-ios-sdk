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
#import "ApploggerLogMessage.h"
#import "ApploggerDDASLLogger.h"

typedef void (^ALManagerInitiateCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALSocketConnectionCompletionHandler)(BOOL successfull, NSError *error);

typedef void (^ALSupportSessionRequestCompletionHandler)(NSError *error);

@interface ApploggerManager : NSObject<ApploggerWatcherDelegate>

/*
 * Use this delegate to become notified when a new user is watching the stream
 */
@property (nonatomic, strong) id<ApploggerWatcherDelegate> watcherDelegate;

/*
 * Indicator whether applogger is started
 */
@property (readonly) BOOL loggingIsStarted;

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
 * add MEssage to Log stream on server
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

@end
