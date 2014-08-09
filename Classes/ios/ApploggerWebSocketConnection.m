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
#import "SocketIOPacket.h"

@interface AppLoggerWebSocketConnection() {
    AppLoggerWebSockerConnectionOpenHandler _webSocketOpenCompletionHandler;
    NSArray *listeningUsers;
}
@property (nonatomic, strong) SocketIO* webSocket;
@end

@implementation AppLoggerWebSocketConnection

+ (AppLoggerWebSocketConnection*) connect:(NSString*)host withPort:(NSInteger)port andProtocol:(NSString*)protocol
                                    onApp:(NSString*)appId withSecret:(NSString*)appSecret
                                forDevice:(NSString*)deviceId
                               completion:(AppLoggerWebSockerConnectionOpenHandler)completion;
{
    AppLoggerWebSocketConnection* connection = [[AppLoggerWebSocketConnection alloc] init];
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
        // store the completion handler
        _webSocketOpenCompletionHandler = completion;
    
        // client=harvester&app=052B56E9-DC0B-49AB-A029-98F3217696CC&device=e6c1ba54-5502-4b46-9055-dd77246b94d0&signature=NOTVALID"];
        // establish the socket connection
        _webSocket = [[SocketIO alloc] initWithDelegate:self];
    
        if ([protocol compare:@"http"] == NSOrderedSame)
            [_webSocket setUseSecure:NO];
        else
            [_webSocket setUseSecure:YES];
    
        // generate the signature
        NSString *signature = [ioBeaverHelper createBase64StringFromString:appSecret];

        [_webSocket connectToHost:host onPort:port withParams:[NSDictionary dictionaryWithObjectsAndKeys:@"harvester", @"client", appId, @"app", deviceId, @"device", signature, @"signature", nil]];
    }
}

- (void) disconnect {
    @synchronized(self)
    {
        [_webSocket disconnectForced];
        _webSocket = nil;
    }
}

-(BOOL)hasValidConnection{
    
    @synchronized(self)
    {
        if (!_webSocket)
            return NO;
        else if ([_webSocket isConnected] || [_webSocket isConnecting])
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
        if (!_webSocket)
            return;
        
        // create the timestamp string
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        NSDate *now = [NSDate date];
        NSString *timeStamp = [dateFormatter stringFromDate:now];
    
        // create log Message
        NSData *messageData = [[NSString stringWithFormat:@"%@ - %@ -- [%@] : %@", message.logLineVersion, timeStamp, message.methodName, message.message] dataUsingEncoding:NSUTF8StringEncoding];
    
        // encode base64
        NSString *logMessage = [ioBeaverHelper createBase64String:messageData WithLength:[messageData length]];
    
        // send
        [_webSocket sendEvent:@"harvester.log" withData:@{ @"data" : logMessage }];
    }
}


#pragma mark WebSocket Callback

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    @synchronized(self)
    {
        if ([packet.name compare:@"connection.established"] == NSOrderedSame && _webSocketOpenCompletionHandler)
            _webSocketOpenCompletionHandler(self, nil);
        // User listening event
        else if ([packet.name compare:@"harvester.users"] == NSOrderedSame){
            //Check whether a user is listening or not.
            
            // Savety check to be sure that the data exists
            if ([packet.args isKindOfClass:[NSArray class]] && [packet.args count] > 0) {
                // Data example : <__NSCFArray 0x947e760>({users =     ();})
                NSDictionary *usersDict = [packet.args objectAtIndex:0];
                
                // set listening users if exists
                if ([[usersDict allKeys] containsObject:@"users"]) {
                    listeningUsers = [usersDict objectForKey:@"users"];
                }
                
            }

        }

    }
    
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    @synchronized(self)
    {
        if (_webSocketOpenCompletionHandler)
            _webSocketOpenCompletionHandler(self, error);
    }
}

@end
