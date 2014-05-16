<img src="applogger.png" title="Applogger.io" float=left>applogger-ios-sdk
=================
The official iOS SDK for the applogger.io service (Releases are in the master branch) https://applogger.io

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

In the ioAppDelegate.m you will find the following code in the method 

application:didfinishLaunchingWithOptions:

[[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"<AppIdentifier>"
                                                              AndSecret:@"<AppSecret>"];

This part is used to connect the right Application on applogger.io with your mobile device

The half magic is done.

At least you must decide which logging client you want to use

To use Cocoalumberjack can add the shared Instance of the applogger logger to the 
cocoalumberjack logger with the following code

[DDLog addLogger:[ApploggerDDASLLogger sharedInstance]];

To use NSLog you can add a preprocessor macro to you .pch file with the following syntax

#import "DDlog.h"
#define NSLog(args...) logMessage(__FILE__, __PRETTY_FUNCTION__,args);

And to use this method in you class you have to add

#import "ApploggerNSLog.h"


## Requirements

## Installation

apploggerSDK is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "apploggerSDK"

## Author

Dirk Eisenberg and Mirko Olsiewicz

## License

apploggerSDK is available under the MIT license. See the LICENSE file for more info.

