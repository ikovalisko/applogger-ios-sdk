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
        [[ApploggerManager sharedApploggerManager] stopSessionWithCompletion:^(BOOL successfull, NSError *error) {
 
            if (successfull) {
                [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:@"Applogger connection closed"];
            }else{
                [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:[NSString stringWithFormat:@"Applogger connection could not be closed : %@", error.localizedDescription]];
                [_startStopButton setSelected:YES];
            }

        }];
    
    else
        [[ApploggerManager sharedApploggerManager] startSessionWithCompletion:^(BOOL successfull, NSError *error) {
        //[[ApploggerManager sharedApploggerManager] startApploggerManagerWithCompletion:^(BOOL successfull, NSError *error){
            
            if (successfull) {
                [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:@"Applogger connection established"];
            }else{
                [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:[NSString stringWithFormat:@"Applogger connection failed : %@", error.localizedDescription]];
                [_startStopButton setSelected:NO];
            }
            
        }];
    
    [_startStopButton setSelected:!_startStopButton.isSelected];
}

- (IBAction)requestSessionButtonTapped:(id)sender {
    [[ApploggerManager sharedApploggerManager] requestSupportSession:^(NSString *watcherIdentifier, NSError *error) {
        if (error)
            [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:@"Failed to request"];
        else
            [(ioAppDelegate*)[UIApplication sharedApplication].delegate showMessage:@"Watcher arrived"];
    }];
}

@end
