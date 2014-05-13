//
//  AppLoggerNSLog.h
//  Pods
//
//  Created by Mirko Olsiewicz on 01.05.14.
//
//

#import <Foundation/Foundation.h>

@interface AppLoggerNSLog : NSObject

void logMessage(const char *fileName, const char *functionName, NSString *format, ...);
@end
