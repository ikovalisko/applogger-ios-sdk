//
//  ApploggerManager.m
//  io.applogger.applogger-examples
//
//  Created by Mirko Olsiewicz on 13.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import "ApploggerManager.h"
#import "ApploggerManagementService.h"
#import "ApploggerWebSocketConnection.h"
#import "ioApploggerHelper.h"
#import <AdSupport/ASIdentifierManager.h>

@interface ApploggerManager(){
    NSString *_apiURL;
    NSString *_applicationsPath;
    NSString *_streamPath;
    NSString *_devicePath;
    NSString *_applicationIdentifier;
    NSString* _initializequeueName;
    NSDictionary *_lbLogStream;
    NSString *_applicationSecret;
    
    BOOL _isCurrentlyEstablishingAConnection;
    
    NSOperationQueue *_logQueue;
    
    NSString* _deviceName;
}

@property (nonatomic, strong)   AppLoggerWebSocketConnection* webSocketConnection;
@property (atomic)              BOOL loggingIsStarted;
@property (nonatomic, copy)     ALSupportSessionRequestCompletionHandler delayedSupportSessionCompletion;
@end

@implementation ApploggerManager

+ (ApploggerManager *)sharedApploggerManager {
    static ApploggerManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [ApploggerManager alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

-(id)init{
    self = [super init];
    
    if (self) {
        // set the service uri
        _apiURL = @"https://applogger.io:443/api";
        
        // set path to applications directory on server
        _applicationsPath = @"harvester/applications/";
        
        // set path to stream directory on server
        _streamPath = @"stream";

        // set path to stream directory on server
        _devicePath = @"devices";

        // set queue name for inizialize thread
        _initializequeueName = @"io.Beaver.InitializeQueue";
        
        _isCurrentlyEstablishingAConnection = NO;
        
        //Initialize Log Queue
        _logQueue = [[NSOperationQueue alloc] init];
        [_logQueue setMaxConcurrentOperationCount:5];
        [_logQueue setName:@"ioBeaverLogQueue"];
        
        // no watchers at beginning
        _currentWatchers = [[NSArray alloc] init];
    }
    
    return self;
}

-(void)setServiceUri:(NSString*)serviceUri {
    _apiURL = serviceUri;
}

-(void)setApplicationIdentifier:(NSString *)identifier AndSecret:(NSString*) secret{
    _applicationIdentifier = identifier;
    _applicationSecret = secret;
}

-(void) setDeviceName:(NSString*)name {
    _deviceName = name;
}

-(NSString*)getAssignDeviceLink{
    return [[[NSString
             stringWithFormat:@"%@/%@%@/%@/new?identifier=%@&name=%@&hwtype=%@&ostype=%@", _apiURL, _applicationsPath,
             _applicationIdentifier, _devicePath, [ioBeaverHelper getUniqueDeviceIdentifier], [[UIDevice currentDevice] name], [ioBeaverHelper getPlatform], [[UIDevice currentDevice] systemVersion]] stringByReplacingOccurrencesOfString:@"harvester/" withString:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void)startApploggerManagerWithCompletion:(ALManagerInitiateCompletionHandler)completion{
    
    [self startSessionWithCompletion:^(BOOL successfull, NSError *error) {
        
        if (completion)
            completion(successfull, error);
        
    }];

    
}

-(void)checkInDeviceWithCompletion:(ALManagerRegisterDeviceCompletionHandler)completion{
    
    // only check in device when application id is available
    if (_applicationIdentifier) {

        dispatch_async(dispatch_queue_create([_initializequeueName cStringUsingEncoding:NSASCIIStringEncoding], NULL), ^{
            
            // At first we just announce the device as self. At this point the system knows about the device
            // but nobody can do anything with that. This call is also used to update meta information about the device.
            AppLoggerManagementService* mgntService = [AppLoggerManagementService service:_applicationIdentifier withSecret:_applicationSecret andServiceUri:_apiURL];
            [mgntService announceDeviceWithName:_deviceName completion:^(NSError *error) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    if (error != nil) {
                        
                            if (completion) {
                                completion(NO, [NSError errorWithDomain:@"AppLoggerManagerError" code:-1 userInfo:@{@"Message": [NSString stringWithFormat:@"Couldn't register device. (%@)", error.localizedDescription]}]);
                            }
                        
                    }else{
                        
                        if (completion) {
                            completion(YES, nil);
                        }

                    }
                    
                });
                
            }];
            
        });
        
    }else{
        // Create error that app identifier not set and call completion
        NSError *error = [NSError errorWithDomain:@"AppLoggerManagerError" code:-1 userInfo:@{@"Message": @"ApplicationIdentifier is not set"}];
        
        if (completion)
            completion(NO, error);
    }
    
}

-(void)startSessionWithCompletion:(ALManagerSessionCompletionHandler)completion{
    
    // only connect if not already started
    @synchronized(self) {
        if (!_loggingIsStarted) {
            
            if (_applicationIdentifier) {
                
                _loggingIsStarted = YES;
                
                [self connectWebSocketWithCompletion:^(BOOL successfull, NSError *error){
                    
                    if (completion)
                        completion((error ? NO : YES), error);
                    
                }];
                
            }else{
            
                // Create error that app identifier not set and call completion
                NSError *error = [NSError errorWithDomain:@"AppLoggerManagerError" code:-1 userInfo:@{@"Message": @"ApplicationIdentifier is not set"}];
                if (completion)
                    completion(NO, error);
            }
            
        } else {
            // if we are running just finish the call so multiple calls are allowed
            completion(NO, nil);
        }
    }
}

-(void)stopSessionWithCompletion:(ALManagerSessionCompletionHandler)completion{
    
    // stop the logger
    _loggingIsStarted = NO;
    
    // disconnect
    if ( _webSocketConnection != nil)
        [_webSocketConnection disconnect];
    
    // reset the watchers state
    _currentWatchers = [[NSArray alloc] init];
    
    if (completion)
        completion(YES, nil);
}

-(void)stopApploggerManager {
    [self stopSessionWithCompletion:^(BOOL successfull, NSError *error) {}];
}


-(void)addLogMessage:(AppLoggerLogMessage*)message{

    if (_loggingIsStarted){
        
        @try {
            if (![_webSocketConnection hasValidConnection]){
                
                if (![_logQueue isSuspended]) {
                    [_logQueue setSuspended:YES];
                    [self connectWebSocketWithCompletion:^(BOOL successfull, NSError *error){
                        [_logQueue setSuspended:NO];
                    }];
                }
                
            }
            
            @try {
                
                // add log line Version
                message.logLineVersion = LogLineVersion;
                
                if ([_webSocketConnection hasValidListener]) {
                    
                    [_logQueue addOperationWithBlock:^{
                            @try {
                                // send log when connection is available
                                if (_webSocketConnection){
                                    [_webSocketConnection log:message];
                                }
                            }
                            @catch (NSException *exception) {
                            }
                    }];
                    
                }
                
            }
            @catch (NSException *exception) {
            }
        }
        @catch (NSException *exception) {
        }
    
    }

}

-(void)connectWebSocketWithCompletion:(ALSocketConnectionCompletionHandler)completion{
    
    NSError* __block neterror = nil;
    
    _isCurrentlyEstablishingAConnection = YES;
    
    dispatch_async(dispatch_queue_create([_initializequeueName cStringUsingEncoding:NSASCIIStringEncoding], NULL), ^{
        
        // At first we just announce the device as self. At this point the system knows about the device but nobody can do anything with that. This call
        // is also used to update meta information about the device.
        AppLoggerManagementService* mgntService = [AppLoggerManagementService service:_applicationIdentifier withSecret:_applicationSecret andServiceUri:_apiURL];
        [mgntService announceDeviceWithName:_deviceName completion:^(NSError *error) {
            
            if (error != nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    if (completion) {
                        completion(NO, [NSError errorWithDomain:@"AppLoggerManagerError" code:-1 userInfo:@{@"Message": @"Couldn't register device"}]);
                    }
                    return;
                });

            }
            
            [mgntService requestDataStreamConfiguration:^(AppLoggerLogStreamConfiguration *configuration, NSError *error) {
                
                if (error != nil)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{

                        if (completion) {
                            completion(NO, [NSError errorWithDomain:@"AppLoggerManagerError" code:-1 userInfo:@{@"Message": @"Couldn't get stream information"}]);
                        }
                        return;

                    });
                    
                }
                
                // call completion and create socket connection in main thread
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    @try
                    {
                        _webSocketConnection = [AppLoggerWebSocketConnection connect:configuration.serverAddress withPort:[configuration.serverPort intValue] andProtocol:configuration.networkProtocol onApp:_applicationIdentifier withSecret:_applicationSecret forDevice:[mgntService deviceIdentifier] andObserver:self completion:^(AppLoggerWebSocketConnection *connection, NSError *error) {
                            
                            if (error)
                            {
                                [_webSocketConnection disconnect];
                                _webSocketConnection = nil;
                            }

                        }];
                        
                    }
                    @catch (NSException *exception) {
                        neterror = [NSError errorWithDomain:@"exception during connection" code:-1 userInfo:nil];
                    }
                    @finally
                    {
                        
                        if (completion) {
                            completion((neterror ? NO : YES), neterror);
                        }

                    }
                        
                });
                
            }];
            
        }];
        
    });
    
}

# pragma watching the connection

- (void) apploggerWatchersUpdated:(NSArray*)watchers {

    // release a waiting support session request
    if(_delayedSupportSessionCompletion && watchers && [watchers count] > 0) {
        _delayedSupportSessionCompletion([watchers firstObject], nil);
        _delayedSupportSessionCompletion = nil;
    }
    
    // cache the new set on watchers
    _currentWatchers = [NSArray arrayWithArray:watchers];
    
    // notify the delegate
    if (_watcherDelegate)
        [_watcherDelegate apploggerWatchersUpdated:watchers];
}

- (void)requestWatchersProfile:(NSString*)userIndentifier completion:(ALRequestWatchersProfileCompletionHandler)completion {
    
    AppLoggerManagementService* mgntService = [AppLoggerManagementService service:_applicationIdentifier withSecret:_applicationSecret andServiceUri:_apiURL];
    [mgntService requestWatchersProfile:userIndentifier completion:^(ApploggerWatcher *watcher, NSError *error) {
        completion(watcher, error);
    }];
}


- (void)requestSupportSession:(ALSupportSessionRequestCompletionHandler)completion {
    
    // First ensure that the applogger connection is established
    [self startSessionWithCompletion:^(BOOL successfull, NSError *error) {
        
        // if we got an error stop here
        if (!successfull || error) {
            completion(nil, error);
            return;
        }
        
        // Now send the support request to the system
        [_webSocketConnection requestSupportSession];
        
        
        // Check if someon watching this stream
        if ([_currentWatchers count] > 0) {
            
            // Ok we have watchers so we can complete the call directly
            completion([_currentWatchers firstObject], nil);
            
        } else {
            // At this point we need to wait until the admin is starting the session, this happens when a new watcher
            // is viewing them. Because of that we just register this as a delayed completion
            _delayedSupportSessionCompletion = completion;
        }
    }];
}

- (void)cancelRequestedSupportSession:(ALSupportSessionCancelCompletionHandler)completion {
    
    // this method first checks if a support session is pending
    if (_delayedSupportSessionCompletion) {

        // reseting the state
        _delayedSupportSessionCompletion = nil;
        
        // if so we stop the connection
        [self stopSessionWithCompletion:^(BOOL successfull, NSError *error) {
           
            // session stopped
            completion(error);
        }];
    } else {
        // it's done
        completion(nil);
    }
}

@end
