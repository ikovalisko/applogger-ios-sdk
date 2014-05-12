//
//  ioStartStopViewController.m
//  applogger-examples
//
//  Created by Mirko Olsiewicz on 12.05.14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#import "ioStartStopViewController.h"
#import "ApploggerManager.h"
#import "ioAppDelegate.h"

@interface ioStartStopViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@end

@implementation ioStartStopViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[ApploggerManager sharedApploggerManager] loggingIsStarted])
        [_startStopButton setSelected:YES];
    else
        [_startStopButton setSelected:NO];

}

- (IBAction)startStopApploggerClicked:(id)sender {
    
    if ([_startStopButton isSelected])
        [[ApploggerManager sharedApploggerManager] stopApploggerManager];
    else
        [[ApploggerManager sharedApploggerManager] startApploggerManagerWithCompletion:^(BOOL successfull, NSError *error){
            
            if (successfull) {
                [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:@"Applogger connection established"];
            }else{
                [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:[NSString stringWithFormat:@"Applogger connection failed : %@", error.localizedDescription]];
            }
            
        }];
    
    [_startStopButton setSelected:!_startStopButton.isSelected];
}


@end
