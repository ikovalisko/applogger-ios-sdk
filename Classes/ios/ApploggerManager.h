//
//  ApploggerManager.h
//  io.applogger.applogger-examples
//
//  Created by Mirko Olsiewicz on 13.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "ApploggerLogMessage.h"
#import "ApploggerDDASLLogger.h"

#define LogLineVersion @"02"

typedef void (^ALManagerInitiateCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALSocketConnectionCompletionHandler)(BOOL successfull, NSError *error);

@interface ApploggerManager : NSObject

/*
 * Indicator whether applogger is started
 */
@property (readonly) BOOL loggingIsStarted;

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
@end
