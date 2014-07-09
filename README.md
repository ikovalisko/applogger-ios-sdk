<img src="applogger.png" title="Applogger.io" float=left>applogger-ios-sdk
=================
The official iOS SDK for the applogger.io service (Releases are in the master branch) https://applogger.io

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

### Connect you device with the App on applogger.io 
To connect your device you have to do the following things in your appdelegate
application:didfinishLaunchingWithOptions: method

First of all set the AppIdentifier and AppSecret of your application 
```ruby
[[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"<AppIdentifier>"
                                                              AndSecret:@"<AppSecret>"];
```
This part is used to connect the right Application on applogger.io with your mobile device

### Start the applogger
To start the applogger you have to do two steps

First you must check in your device with checkInDevice method
```ruby
[ApploggerManager sharedApploggerManager] 
				checkInDeviceWithCompletion:^(BOOL successfull, NSError *error){
```
### Register your device
In the completion block and if the start was successful you can use the getAssignDeviceLink 
method to receive the url for register your device. This must be done only at the first
time you are using the device with applogger SDK
```ruby     
if (successfull) {
    NSString *deviceRegisterURLString = [[ApploggerManager sharedApploggerManager] 
    														 getAssignDeviceLink]];
}else{
    [self showMessage:[NSString stringWithFormat:@"Applogger connection failed : %@", 
    													error.localizedDescription]];
}
```
### Start session with applogger.io
To send the log to applogger.io you must start a session with the method
```ruby 
[[ApploggerManager sharedApploggerManager] 
				startSessionWithCompletion:^(BOOL successfull, NSError *error){
```		
if you would no longer send logs you can close your session with the method
```ruby 
[[ApploggerManager sharedApploggerManager] 
				stopSessionWithCompletion:^(BOOL successfull, NSError *error){
```		
if you have started the session and nobody watch your app on applogger.io we send no
log statements. That means you have no data stream if nobody watch on applogger.io
### Configure your logging framework to use applogger.io
With **Cocoalumberjack** you can add the shared Instance of the applogger logger to the 
cocoalumberjack logger with the following code
```ruby
[DDLog addLogger:[ApploggerDDASLLogger sharedInstance]];
```

With **NSLog** you can add a preprocessor macro to you .pch file with the following syntax
```ruby
#import "DDlog.h"
#define NSLog(args...) logMessage(__FILE__, __PRETTY_FUNCTION__,args);
```
And to use this method in you class you have to add
```ruby
#import "ApploggerNSLog.h"
```
With **NSLogger** you can register a NSLogger connection with the method
```ruby
[[ApploggerManager sharedApploggerManager] 
					registerNSLoggerConnectionWithDelegate:<Delegate>];
```
If ou set a delegate you will be informed about connection established and 
connection failed.

***Now you are able to log to applogger.io***


## Requirements

To use the applogger SDK you must use either Cocoalumberjack or NSLog. Will will extend this in the next Versions

## Installation

apploggerSDK is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```
    pod "apploggerSDK", :git => 'https://github.com/applogger/applogger-ios-sdk.git'
```

## Author

- Dirk Eisenberg
- Mirko Olsiewicz

## License

apploggerSDK is available under the MIT license. See the [LICENSE file](https://github.com/applogger/applogger-ios-sdk/blob/master/LICENSE) for more info.

