//
//  AppLoggerLogMessage.h
//  io.applogger.applogger-examples
//
//  Created by Mirko Olsiewicz on 13.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppLoggerLogMessage : NSObject

@property (nonatomic) NSString *message;
@property (nonatomic) NSString *methodName;
@property (nonatomic) NSString *className;
@property (nonatomic) NSString *logLineVersion;

@end
