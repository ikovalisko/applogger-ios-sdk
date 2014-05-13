//
//  AppLoggerNSLog.m
//  Pods
//
//  Created by Mirko Olsiewicz on 01.05.14.
//
//

#import "ApploggerNSLog.h"
#import "ApploggerManager.h"
#import "ApploggerDDASLLogger.h"
#include <pthread.h>

@implementation AppLoggerNSLog

void logMessage(const char *fileName, const char *functionName, NSString *format, ...)
{
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss:SSS"];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *method = @"";
    // To prevent crashes when logging not working
    @try {
    
        fprintf(stderr, "%s %s%s %s", [timeStamp UTF8String],
                [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"] UTF8String],
                [[NSString stringWithFormat:@"[%ld:%lx]", (long) getpid(), (long) pthread_mach_thread_np(pthread_self())] UTF8String],
                [body UTF8String]);

        method = [[[[[[NSString stringWithUTF8String:functionName]
                          substringFromIndex:[[NSString stringWithUTF8String:functionName] rangeOfString:@" "].location+1]
                         stringByReplacingOccurrencesOfString:@"[" withString:@""]
                        stringByReplacingOccurrencesOfString:@"-" withString:@""]
                       stringByReplacingOccurrencesOfString:@"]" withString:@""]
                      lastPathComponent];
    }
    @catch (NSException *exception) {
        
    }
    
    // Log to applogger in the www
    AppLoggerLogMessage *message = [[AppLoggerLogMessage alloc] init];
    message.message = body;
    message.methodName = [NSString stringWithFormat:@"%s", [method UTF8String]];
    [[ApploggerManager sharedApploggerManager] addLogMessage:message];
    
}
@end
