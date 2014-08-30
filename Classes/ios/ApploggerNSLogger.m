//
//  ApploggerNSLogger.m
//  Pods
//
//  Created by Mirko Olsiewicz on 28.06.14.
//
//

#import "ApploggerNSLogger.h"
#import "LoggerClient.h"
#import "GCDAsyncSocket.h"
#import "LoggerCommon.h"
#import "NSLoggerMessageObject.h"
#import "ApploggerLogMessage.h"
#import "ApploggerManager.h"
#import "LoggerCommon.h"

@interface ApploggerNSLogger ()<NSNetServiceDelegate, NSStreamDelegate>{
    Logger *newLogger;
    
    NSNetService *_netService;
    GCDAsyncSocket *_asyncSocket;
    NSMutableArray *_connectedSockets;
    id<ApploggerNSLoggerDelegate> _delegate;
}

@end

@implementation ApploggerNSLogger

-(id)initWithDelegate:(id<ApploggerNSLoggerDelegate>)classDelegte{
    self = [super init];
    
    if (self) {
        _delegate = classDelegte;
    }
    
    return self;
}

-(void)registerServer{
    // Create our socket.
	// We tell it to invoke our delegate methods on the main thread.
    
	_asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_asyncSocket setAutoDisconnectOnClosedReadStream:NO];
    
    _connectedSockets = [NSMutableArray new];
    
	NSError *err = nil;
	if ([_asyncSocket acceptOnPort:0 error:&err])
	{
		// So what port did the OS give us?
        
		UInt16 port = [_asyncSocket localPort];
        
		// Create and publish the bonjour service.
		// Obviously you will be using your own custom service type.

        // start default logger to log console to default logger
        LoggerStart(NULL);
        
        // create own logger
        newLogger = LoggerInit();
        
        // Set options for Logger. it is important because we do not use ssl
        LoggerSetOptions(newLogger, kLoggerOption_BufferLogsUntilConnection |	\
                         kLoggerOption_BrowseBonjour);
        
        // Override the default logger with our logger
        LoggerSetDefaultLogger(newLogger);
        
        //This starts the logger with a bonjour service.
        LoggerSetupBonjour(newLogger, (__bridge CFStringRef)(@"_Applogger._tcp"), (__bridge CFStringRef)(@"ApploggerViewer"));

        // create a bonjour service
		_netService = [[NSNetService alloc] initWithDomain:@"local."
                                                      type:@"_Applogger._tcp"
                                                      name:@"ApploggerViewer"
                                                      port:port];
        
        // set the delegate for bonjour service and publish it
		[_netService setDelegate:self];
		[_netService publish];
        
	}
    
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{    
    [_connectedSockets addObject:newSocket];
    
    [(NSInputStream*)newSocket.readStream setDelegate:self];
    
    // start read the content
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSMutableData *)data withTag:(long)tag
{
	//[self dumpBytes:cnx.tmpBuf length:numBytes];
	NSUInteger bufferLength = [data length];
	while (bufferLength > 4)
	{
        // check whether we have a full message
        uint32_t length;
        [data getBytes:&length length:4];
        length = ntohl(length);
		if (bufferLength < (length + 4))
			break;
        
        // get one message
        CFDataRef subset = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                                       (unsigned char *) [data bytes] + 4,
                                                       length,
                                                       kCFAllocatorNull);
        if (subset != NULL)
        {
            // get the information from NSData as a readable message
            NSLoggerMessageObject *message = [[NSLoggerMessageObject alloc] initWithData:(__bridge NSData *)subset];

            if (message.type == LOGMSG_TYPE_CLIENTINFO)
			{
				// stkim1_Apr.07,2013
				// as soon as client info is recieved and client hash is generated,
				// then new connection gets reporeted to transport manager
                // we do not use it at the moment
				//[data clientInfoReceived:message];
			}else{

                if (message.type == LOGMSG_TYPE_LOG) {
                    
                    // Log to applogger in the www
                    AppLoggerLogMessage *apploggerMessage = [[AppLoggerLogMessage alloc] init];
                    apploggerMessage.message = [NSString stringWithFormat:@"NSLogger : %@", message.message];
                    apploggerMessage.methodName = [NSString stringWithFormat:@"%s", [message.functionName UTF8String]];
                    [[ApploggerManager sharedApploggerManager] addLogMessage:apploggerMessage];
                }
                
            }
            CFRelease(subset);
            
        }
        
        [data replaceBytesInRange:NSMakeRange(0, length + 4) withBytes:NULL length:0];
		bufferLength = [data length];

    }
    // restart read the content
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	[_connectedSockets removeObject:sock];
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
	NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
          [ns domain], [ns type], [ns name], (int)[ns port]);
    
    if (_delegate && [_delegate respondsToSelector:@selector(nSLoggerConnectionEstablished)])
        [_delegate nSLoggerConnectionEstablished];
    
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
          [ns domain], [ns type], [ns name], errorDict);
    
    if (_delegate && [_delegate respondsToSelector:@selector(nSLoggerconnectionFailed:)])
        [_delegate nSLoggerconnectionFailed:errorDict];

}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
}

@end
