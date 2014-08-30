//
//  main.m
//  applogger-examples
//
//  Created by Mirko Olsiewicz on 12.05.14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ioAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        LoggerStartForBuildUser();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ioAppDelegate class]));
    }
}
