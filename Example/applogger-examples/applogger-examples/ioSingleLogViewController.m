//
//  ioFirstViewController.m
//  ioApploggerExamples
//
//  Created by Mirko Olsiewicz on 15.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import "ioSingleLogViewController.h"

@interface ioSingleLogViewController ()

@end

@implementation ioSingleLogViewController

- (IBAction)sendSingleLogClickHandler:(id)sender {
    
    // Use cocoalumberjack
    DDLogVerbose(@"CocoaLumberjack - Single Log Message");
    NSLog(@"NSLog - Single Log");
    
    // Us NSLogger
    //LogMessageCompat(@"------------ Test Log ---------------");
    LoggerApp(4, @"Hello world! Today is: %@", [NSDate date]);

    // Use Applogger Logging
    //ApploggerLogMessage *message = [[ApploggerLogMessage alloc] init];
    //message.message = @"Single Log Message";
    //message.methodName = @"sendSingleLogClickHandler:";
    //[[ApploggerManager sharedApploggerManager] addLogMessage:message];
}

@end
