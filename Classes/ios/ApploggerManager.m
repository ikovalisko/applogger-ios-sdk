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
    AsyncSocket __block *_clientSocket;
    NSString* _initializequeueName;
    NSDictionary *_lbLogStream;
    NSString *_applicationSecret;
    
    BOOL _isCurrentlyEstablishingAConnection;
    
    NSOperationQueue *_logQueue;
    
    NSString* _deviceName;
}

@property (nonatomic, strong) AppLoggerWebSocketConnection* webSocketConnection;
@property (readonly) BOOL loggingIsStarted;

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

        // create client socket for TCP connection and set delegate to this class
        _clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [_clientSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

        // set queue name for inizialize thread
        _initializequeueName = @"io.Beaver.InitializeQueue";
        
        _isCurrentlyEstablishingAConnection = NO;
        
        //Initialize Log Queue
        _logQueue = [[NSOperationQueue alloc] init];
        [_logQueue setMaxConcurrentOperationCount:5];
        [_logQueue setName:@"ioBeaverLogQueue"];        
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
             _applicationIdentifier, _devicePath, [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString], [[UIDevice currentDevice] name], [ioBeaverHelper getPlatform], [[UIDevice currentDevice] systemVersion]] stringByReplacingOccurrencesOfString:@"harvester/" withString:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void)startApploggerManagerWithCompletion:(ALManagerInitiateCompletionHandler)completion{
    
    // only connect if not already started
    if (!_loggingIsStarted) {
        
        if (_applicationIdentifier) {
            
            _loggingIsStarted = YES;

            NSError __block * error = nil;

            // check whether the client socket is alread connected
            if (![_clientSocket isConnected])
            {

                [self connectWebSocketWithCompletion:^(BOOL successfull, NSError *error){

                    if (completion)
                        completion((error ? NO : YES), error);
        
                }];
                
                return;
            }else{
                // Create error that could not get stream information
                error = [NSError errorWithDomain:@"AppLoggerManagerError" code:-1 userInfo:@{@"Message": @"Couldn't establish a connection to server"}];

                // log connection is established
            }
            
            if (completion)
                completion(NO, error);

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

-(void)stopApploggerManager{
    _loggingIsStarted = NO;
    [_clientSocket disconnect];

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
                
                if ([_webSocketConnection hasValidListener]) {
                    
                    [_logQueue addOperationWithBlock:^{
                            @try {
                                // send log when connection is available
                                if (_webSocketConnection)
                                    [_webSocketConnection log:message];
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
    [self startApploggerManagerWithCompletion:^(BOOL successfull, NSError *error) {
        
        // if we got an error stop here
        if (!successfull || error) {
            completion(nil, error);
            return;
        }
        
        // Now send the support request to the system
        AppLoggerManagementService* mgntService = [AppLoggerManagementService service:_applicationIdentifier withSecret:_applicationSecret andServiceUri:_apiURL];
        [mgntService requestSupportSession:^(NSError *error) {
                    completion(nil, error);
        }];
    }];
}

- (void)cancelRequestedSupportSession:(ALSupportSessionCancelCompletionHandler)completion {
    completion(nil);
}

@end
