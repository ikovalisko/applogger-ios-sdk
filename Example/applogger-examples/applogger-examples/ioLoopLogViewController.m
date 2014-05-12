//
//  ioLoopLogViewController.m
//  ioApploggerExamples
//
//  Created by Mirko Olsiewicz on 15.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import "ioLoopLogViewController.h"

@interface ioLoopLogViewController ()

@end

@implementation ioLoopLogViewController

- (IBAction)sendLoopLogClickHandler:(id)sender {
    
    [_stopButton setHidden:NO];
    loggingCanceled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        int i = 0;

        while (!loggingCanceled) {
            
            i++;
            
            
                dispatch_sync(dispatch_get_main_queue(), ^{

                    // Use cocoalumberjack
                    DDLogVerbose(@"Loop Log Message %d", i);

                    // Use Applogger Logging
                    //ApploggerLogMessage *message = [[ApploggerLogMessage alloc] init];
                    //message.message = [NSString stringWithFormat:@"Loop Log Message %d", i];
                    //message.methodName = @"sendLoopLogClickHandler:";
                    //[[ApploggerManager sharedApploggerManager] addLogMessage:message];
                    //message = nil;
                    [_logCountLabel setText:[NSString stringWithFormat:@"%d", i]];
                });
            
                sleep(1.0);
            
            
        }
        
    });
        
}

- (IBAction)cancelClicked:(id)sender{
    loggingCanceled = YES;
    [(UIButton*)sender setHidden:YES];
}

@end
