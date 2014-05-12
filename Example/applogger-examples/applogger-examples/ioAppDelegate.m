//
//  ioAppDelegate.m
//  applogger-examples
//
//  Created by Mirko Olsiewicz on 12.05.14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#import "ioAppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "ApploggerManager.h"
#import "ioStartStopViewController.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

@implementation ioAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Read the settings from the user defaults when the user set some
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_preference"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"port_preference"])
    {
        NSString* host = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_preference"];
        NSString* port = [[NSUserDefaults standardUserDefaults] objectForKey:@"port_preference"];
        [[ApploggerManager sharedApploggerManager] setServiceUri:[NSString stringWithFormat:@"%@:%@/api", host, port]];
    }
    
    // init crash reporter
#if !(TARGET_IPHONE_SIMULATOR)
#if defined (CONFIGURATION_Beta)
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"e7fd73ede9c6ac0b87a5d05c706c4f88"];
    
    // Set App Id
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"c68abc88-1065-4459-8d24-04f4e0bedc91"];
    
#elif defined (CONFIGURATION_Alpha)
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"635c895bc081c58b2e9068f63b9c2343"];
    
    // Set App Id
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"c68abc88-1065-4459-8d24-04f4e0bedc91"];
#elif defined (CONFIGURATION_Continuous)
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"a3bb9e32854039cd46dcb2f41bd1bfa7"];
    
    // Set App Id
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"a3bb9e32854039cd46dcb2f41bd1bfa7"
                                                              AndSecret:@"e2ff9cf6-9fc8-475f-97f3-b18e5d118774"];
    
#else
    
    // Set App Id
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"a3bb9e32854039cd46dcb2f41bd1bfa7"
                                                              AndSecret:@"e2ff9cf6-9fc8-475f-97f3-b18e5d118774"];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"478f9467916ace009a61d6a2d819ebc7"];
    
    //Set log to only error in Release
#endif
    
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
#else
    // Set App Id
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"a3bb9e32854039cd46dcb2f41bd1bfa7"
                                                              AndSecret:@"e2ff9cf6-9fc8-475f-97f3-b18e5d118774"];
    
#endif
    
    // Override cocoaLumberJack logger
    [DDLog addLogger:[ApploggerDDASLLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.window.rootViewController.view addSubview:progressHUD];
    [progressHUD setCenter:self.window.center];
    [progressHUD setLabelText:@"Information"];
    [progressHUD setLabelFont:[UIFont systemFontOfSize:15.0]];
    
    // Start the Applogger
    [[ApploggerManager sharedApploggerManager] startApploggerManagerWithCompletion:^(BOOL successfull, NSError *error){
        
        if (successfull) {
            [self showMessage:@"Applogger connection established"];
            [[(ioStartStopViewController*)[[self.window.rootViewController childViewControllers] objectAtIndex:0] registerLinkTextView] setText:[[ApploggerManager sharedApploggerManager] getAssignDeviceLink]];
        }else{
            [self showMessage:[NSString stringWithFormat:@"Applogger connection failed : %@", error.localizedDescription]];
        }
        
    }];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Message HUD Method
-(void) showMessage:(NSString*) message{
    [progressHUD setDetailsLabelText:message];
    [progressHUD show:YES];
    messageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(hideMessage:) userInfo:nil repeats:NO];
    
}

-(void) hideMessage:(NSTimer *)timer{
    [progressHUD hide:YES];
    [messageTimer invalidate];
    messageTimer = nil;
}

@end
