//
//  ioAppDelegate.h
//  applogger-examples
//
//  Created by Mirko Olsiewicz on 12.05.14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ioAppDelegate : UIResponder <UIApplicationDelegate>{
    NSTimer *messageTimer;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
-(void) showMessage:(NSString*) message;

-(void) hideMessage:(NSTimer *)timer;
@end