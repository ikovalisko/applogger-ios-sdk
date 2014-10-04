<img src="applogger.png" title="Applogger.io" float=left>applogger-ios-sdk
=================
The official iOS SDK for the applogger.io service (Releases are in the master branch) 
[https://applogger.io](https://applogger.io)

## Quick Start

### Install via CocoaPods
The [applogger.io](https://applogger.io) iOS SDK is available through [CocoaPods](http://cocoapods.org). Install
it simply add the following line to your Podfile:

```
pod 'apploggerSDK', '0.3.4'
```

### Configure the SDK
The SDK needs to be configured and connected with a specific app you generated in the 
[applogger.io](https://applogger.io) dashboard. The following lines should be added to the
application:didfinishLaunchingWithOptions: method

```objc
[[ApploggerManager sharedManager] setApplicationIdentifier:@"<AppIdentifier>" AndSecret:@"<AppSecret>"];
```

The needed information can be found on the application details page as text or via 
QR Code. Check out our demo application from the Apple app store.

### Stream logs 
[applogger.io](https://applogger.io) will never send logfiles behind your back. It starts 
sending logs with the following call:  

```objc
[[ApploggerManager sharedManager] 
				startSessionWithCompletion:^(BOOL successfull, NSError *error){
```		

The log stream will be interrupted when no watcher on the other side is checking the data 
to respect you data plan when using [applogger.io](https://applogger.io) on the road. It 
also stops sending when the application goes to the background or you just call the 
following API:

```objc
[[ApploggerManager sharedManager] stopSessionWithCompletion:^(BOOL successfull, NSError *error){
```		

## Overview
[applogger.io](https://applogger.io) is a service which allows to watch log information and 
screenshots directly from your webbrowser without any need to connect a mobile device via 
USB cable to a computer. This is good when you need to support user which are not right
next to your office, e.g. every customer who is using your app or crowd testers when you 
are in a heavy beta phase. 

The following documentation gives you an in deep documentation about the different 
capabilities the iOS SDK offers iOS clients, e.g. iPhone or iPad. If you have any 
questions or feature requests just use our support portal.

### Content
The following information will be explained in detail in our wiki. Please check the wiki pages for this by starting [here](https://github.com/applogger/applogger-ios-sdk/wiki).

* Scenarios explained
	* [Crowd based testing](https://github.com/applogger/applogger-ios-sdk/wiki/Scenario%3A-Crowd-based-testingScenario)
	* [Support Sessions](https://github.com/applogger/applogger-ios-sdk/wiki/Scenario%3A-Support-Sessions)
	
* How-To integrate
	* [via CocoaPods](https://github.com/applogger/applogger-ios-sdk/wiki/Integration-via-CocoaPods)
	* Manually
	
* Log-Framework Plugins
 	* [NSLog](https://github.com/applogger/applogger-ios-sdk/wiki/NSLog-integration)
	* [CocoaLumberjack](https://github.com/applogger/applogger-ios-sdk/wiki/CocoaLumberjack-integration)
	* [NSLogger](https://github.com/applogger/applogger-ios-sdk/wiki/NSLogger-integration)
	
* [SDK Reference](https://github.com/applogger/applogger-ios-sdk/wiki/API-Reference)

## Contributing
 
* Fork the project
* Fix the issue
* Add specs
* Create pull request on github

## Author

- Dirk Eisenberg
- Mirko Olsiewicz

## License

apploggerSDK is available under the MIT license. See the [LICENSE file](https://github.com/applogger/applogger-ios-sdk/blob/master/LICENSE) for more info.
