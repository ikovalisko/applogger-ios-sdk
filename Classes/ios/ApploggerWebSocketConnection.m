//
//  AppLoggerWebSocketConnection.m
//  Pods
//
//  Created by Dirk Eisenberg on 22/04/14.
//
//

#import "ApploggerWebSocketConnection.h"
#import "ApploggerLogMessage.h"
#import "ioApploggerHelper.h"
#import "AZSocketIO.h"

@interface AppLoggerWebSocketConnection() {
    AZSocketIO* _webSocket;
    NSArray *listeningUsers;
}

@end

@implementation AppLoggerWebSocketConnection

+ (AppLoggerWebSocketConnection*) connect:(NSString*)host withPort:(NSInteger)port andProtocol:(NSString*)protocol
                                    onApp:(NSString*)appId withSecret:(NSString*)appSecret
                                forDevice:(NSString*)deviceId
                              andObserver:(id<ApploggerWatcherDelegate>)observer
                               completion:(AppLoggerWebSockerConnectionOpenHandler)completion;
{
    AppLoggerWebSocketConnection* connection = [[AppLoggerWebSocketConnection alloc] init];
    [connection setWatcherDelegate:observer];
    [connection connect:host withPort:port andProtocol:protocol onApp:appId withSecret:appSecret forDevice:deviceId completion:completion];
    return connection;
}

- (void) connect:(NSString*)host withPort:(NSInteger)port andProtocol:(NSString*)protocol
           onApp:(NSString*)appId withSecret:(NSString*)appSecret
       forDevice:(NSString*)deviceId
      completion:(AppLoggerWebSockerConnectionOpenHandler)completion
{
    @synchronized(self)
    {
        // check if we have an other socket open, if so close
        if (_webSocket)
            [self disconnect];
        
        // identify secure or not secure connection
        BOOL bSecure = true;
        if ([protocol compare:@"http"] == NSOrderedSame || [protocol compare:@"ws"] == NSOrderedSame)
            bSecure = false;
        
        // create a new socket
        _webSocket = [[AZSocketIO alloc] initWithHost:host andPort:[NSString stringWithFormat:@"%ld", (long)port] secure:bSecure];
        
        // set 30 seconds for reconnect and then stop
        [_webSocket setReconnectionLimit:30];
        
        // register the event receiver
        [_webSocket setEventReceivedBlock:^(NSString *eventName, id data) {
            [self handleEvent:eventName withData:data];
        }];
        
        // generate the signature
        NSString *signature = [ioBeaverHelper createBase64StringFromString:appSecret];
        
        // generate the query data
        NSDictionary* queryData = [NSDictionary dictionaryWithObjectsAndKeys:@"harvester", @"client", appId, @"app", deviceId, @"device", signature, @"signature", nil];
        
        // connect
        [_webSocket connectWithSuccess:^{
            completion(self, nil);
        } andFailure:^(NSError *error) {
            completion(self, error);
        } withData:queryData];
    }
}

- (void) disconnect {
    @synchronized(self)
    {
        [_webSocket disconnect];
        _webSocket = nil;
    }
}

-(BOOL)hasValidConnection{
    
    @synchronized(self)
    {
        if (!_webSocket)
            return NO;
        else if (_webSocket.state == AZSocketIOStateConnected || _webSocket.state == AZSocketIOStateConnecting)
            return YES;
        else
            return NO;
    }
    
}

-(BOOL)hasValidListener{
    
    @synchronized(self)
    {
        if (listeningUsers && [listeningUsers count] > 0)
            return YES;
        
        return NO;
    }
    
}

- (void) log:(AppLoggerLogMessage*)message {
    
    @synchronized(self)
    {
        if (![self hasValidConnection])
            return;
        
        // create the timestamp string
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        NSDate *now = [NSDate date];
        NSString *timeStamp = [dateFormatter stringFromDate:now];
    
        // create log Message
        NSData *messageData = [[NSString stringWithFormat:@"%@ - %@ -- [%@#%@] : %@", message.logLineVersion, timeStamp, message.className, message.methodName, message.message] dataUsingEncoding:NSUTF8StringEncoding];
    
        // encode base64
        NSString *logMessage = [ioBeaverHelper createBase64String:messageData WithLength:[messageData length]];
    
        // send
        NSError* error = nil;
        [_webSocket emit:@"harvester.log" args:@{ @"data" : logMessage } error:&error];
    }
}

- (void) requestSupportSession {
  
    @synchronized(self)
    {
        if (![self hasValidConnection])
            return;
        
        NSError* error = nil;
        [_webSocket emit:@"harvester.requests.support" args:@{ @"data" : @"" } error:&error];
    }
}


#pragma mark WebSocket Callback

- (void) handleEvent:(NSString*)eventName withData:(id) data {

    // ignore the connection established massge
    if ([eventName compare:@"connection.established"] == NSOrderedSame) {
        
        // NOTHING TODO BECAUSE WE HAVE BLOCK
        
    // User listening event
    } else if ([eventName compare:@"harvester.users"] == NSOrderedSame) {
        //Check whether a user is listening or not.
        
        // Savety check to be sure that the data exists
        if (data != nil && [data isKindOfClass:[NSArray class]] && [data count] > 0) {
            // Data example : <__NSCFArray 0x947e760>({users =     ();})
            NSDictionary *usersDict = [data objectAtIndex:0];
            
            // set listening users if exists
            if ([[usersDict allKeys] containsObject:@"users"]) {
                listeningUsers = [usersDict objectForKey:@"users"];
            }
        }
        
        // notify the delegate
        [self apploggerWatchersUpdated:listeningUsers];
    } else {
        internalLog(@"Unhandled event received: %@", eventName);
    }
}

#pragma mark ApploggerWatcherDelegate

- (void) apploggerWatchersUpdated:(NSArray*)watchers {
    if (_watcherDelegate)
        [_watcherDelegate apploggerWatchersUpdated:watchers];
}

@end
