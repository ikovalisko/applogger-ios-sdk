//
//  ioBeaverHelper.m
//  Pods
//
//  Created by Mirko Olsiewicz on 18.03.14.
//
//

#import "ioApploggerHelper.h"
#import "ApploggerManager.h"
#import <sys/utsname.h>
#import "UICKeyChainStore.h"

@implementation ioBeaverHelper

+ (NSString*)getPlatform{
    
    // get system info
    struct utsname systemInfo;
    uname(&systemInfo);

    // return system platform
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+(NSString *)createBase64String:(NSData *)data WithLength:(unsigned long)length {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    SEL base64EncodingSelector = NSSelectorFromString(@"base64EncodedStringWithOptions:");
    if ([data respondsToSelector:base64EncodingSelector]) {
        return [data base64EncodedStringWithOptions:0];
    } else {
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [data base64Encoding];
#pragma clang diagnostic pop
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    }
#endif
}

+(NSString *)createBase64StringFromString:(NSString*)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [ioBeaverHelper createBase64String:data WithLength:[data length]];
}

+(NSString*)getUniqueDeviceIdentifier{
    // Get the key from key chain
    NSString *deviceID = [UICKeyChainStore stringForKey:@"ApploggerDeviceID" service:@"io.applogger.ios.sdk.DeviceID"];
    
    // check if it exists
    if (!deviceID) {
        //if not exists create a guid for this device
        deviceID = [[NSUUID UUID] UUIDString];
        // save the guid as key for this device
        [UICKeyChainStore setString:deviceID forKey:@"ApploggerDeviceID" service:@"io.applogger.ios.sdk.DeviceID"];
    }
    
    return deviceID;
}

void internalLog(NSString *format, ...) {
    
    if ([[ApploggerManager sharedApploggerManager] isSDKConsoleLogEnable]) {
        va_list argumentList;
        va_start(argumentList, format);
        NSMutableString * message = [[NSMutableString alloc] initWithFormat:format
                                                                  arguments:argumentList];
        NSLogv(message, argumentList);
        va_end(argumentList);
    }
    
}

@end
