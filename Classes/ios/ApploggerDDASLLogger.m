//
//  ApploggerDDASLLogger.m
//  Pods
//
//  Created by Mirko Olsiewicz on 08.04.14.
//
//

#import "ApploggerDDASLLogger.h"
#import "ApploggerManager.h"

@implementation ApploggerDDASLLogger

static ApploggerDDASLLogger *sharedInstance;

/**
 * The runtime sends initialize to each class in a program exactly one time just before the class,
 * or any class that inherits from it, is sent its first message from within the program. (Thus the
 * method may never be invoked if the class is not used.) The runtime sends the initialize message to
 * classes in a thread-safe manner. Superclasses receive this message before their subclasses.
 *
 * This method may also be called directly (assumably by accident), hence the safety mechanism.
 **/
+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        
        sharedInstance = [[[self class] alloc] init];
    }
}

+ (instancetype)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    if (sharedInstance != nil)
    {
        return nil;
    }
    
    if ((self = [super init]))
    {
        // A default asl client is provided for the main thread,
        // but background threads need to create their own client.
        
        client = asl_open(NULL, "com.apple.console", 0);
    }
    return self;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    // Log to applogger in the www
    dispatch_sync(dispatch_get_main_queue(), ^{
        AppLoggerLogMessage *message = [[AppLoggerLogMessage alloc] init];
        message.message = logMessage->logMsg;
        message.methodName = [NSString stringWithFormat:@"%s", logMessage->function];
        [[ApploggerManager sharedApploggerManager] addLogMessage:message];
        
    });
    
}
@end
