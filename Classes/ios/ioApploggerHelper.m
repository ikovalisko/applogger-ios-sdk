//
//  ioBeaverHelper.m
//  Pods
//
//  Created by Mirko Olsiewicz on 18.03.14.
//
//

#import "ioApploggerHelper.h"
#import <sys/utsname.h>

@implementation ioBeaverHelper

+ (NSString*) getPlatform{
    
    // get system info
    struct utsname systemInfo;
    uname(&systemInfo);

    // return system platform
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (void) addGlobalSetting:(NSObject*) setting ForKey:(NSString*) key{
    NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] init];
    
    // if settings exists use it
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ioAppLoggerSettings"])
        settingsDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"ioAppLoggerSettings"];
    
    // set setting in dict
    [settingsDict setObject:setting forKey:key];
    
    // replace old settings dict
    [[NSUserDefaults standardUserDefaults] setObject:settingsDict forKey:@"ioAppLoggerSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    settingsDict = nil;
}

+ (NSObject *)getSettingForKey:(NSString *)key{
    
    // check if Applogger settings exists
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ioAppLoggerSettings"]){
        
        // check if setting exists
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ioAppLoggerSettings"] objectForKey:key])
            return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ioAppLoggerSettings"] objectForKey:key];
        else
            return nil;
        
    }else
        return nil;
    
}

+(void) resetSettings{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ioAppLoggerSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)createBase64String:(NSData *) data WithLength:(unsigned long) length {
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

@end
