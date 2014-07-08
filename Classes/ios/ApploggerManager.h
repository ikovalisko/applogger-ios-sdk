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
#import "ApploggerNSLogger.h"

@class GCDAsyncSocket;

typedef void (^ALManagerInitiateCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALManagerRegisterDeviceCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALManagerSessionCompletionHandler)(BOOL successfull, NSError *error);
typedef void (^ALSocketConnectionCompletionHandler)(BOOL successfull, NSError *error);

@interface ApploggerManager : NSObject

/*!
 * Indicator whether applogger is started
 */
@property (readonly) BOOL loggingIsStarted;

/*!
 * create a shared instance of this class
 */
+ (ApploggerManager *)sharedApploggerManager;

/*
 * allows to set a different service uri. Calling this method is totally optional 
 * and is normally only used for debuggin against a development system when you 
 * are an SDK author
 */
-(void)setServiceUri:(NSString*)serviceUri;
    
/*!
 * set application identifier
 */
-(void) setApplicationIdentifier:(NSString*)identifier AndSecret:(NSString*)secret;

/*!
 * add MEssage to Log stream on server
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

/*! Method is deprecated. Please use the chekInDevice and startSession methods instead
 */
-(void)startApploggerManagerWithCompletion:(ALManagerInitiateCompletionHandler)completion __attribute__((deprecated("Please use the chekInDevice and startSession methods instead")));

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

/*!
 * stop the Applogger
 * disconnect from server
 */
-(void)stopApploggerManager;

@end
