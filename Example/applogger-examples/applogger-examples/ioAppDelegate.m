//
//  ioAppDelegate.m
//  applogger-examples
//
//  Created by Mirko Olsiewicz on 12.05.14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#import "ioAppDelegate.h"
#import "ApploggerManager.h"
#import "ioStartStopViewController.h"

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
    
    // configure logging
    [[ApploggerManager sharedApploggerManager] setIsSDKConsoleLogEnable:YES];
    
    // configure local
    [[ApploggerManager sharedApploggerManager] setServiceUri:@"http://127.0.0.1:3000/api"];
    
    // Set App Id
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"a3bb9e32854039cd46dcb2f41bd1bfa7"
                                                              AndSecret:@"e2ff9cf6-9fc8-475f-97f3-b18e5d118774"];
    
    //Add NSLogger
    //[[ApploggerManager sharedApploggerManager] registerNSLoggerConnectionWithDelegate:nil];
    
    // Override cocoaLumberJack logger
    //[DDLog addLogger:[ApploggerDDASLLogger sharedInstance]];
    //[DDLog addLogger:[DDASLLogger sharedInstance]];
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.window.rootViewController.view addSubview:progressHUD];
    [progressHUD setCenter:self.window.center];
    [progressHUD setLabelText:@"Information"];
    [progressHUD setLabelFont:[UIFont systemFontOfSize:15.0]];
        
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
