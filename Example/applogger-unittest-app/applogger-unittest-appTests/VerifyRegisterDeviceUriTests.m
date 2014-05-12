//
//  VerifyRegisterDeviceUriTests.m
//  applogger-unittest-app
//
//  Created by Dirk Eisenberg on 10/05/14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UnittestHelperMacros.h"
#import "ApploggerManager.h"

@interface VerifyRegisterDeviceUriTests : XCTestCase

@end

@implementation VerifyRegisterDeviceUriTests

- (void)setUp
{
    [super setUp];

    // This section configures the SDK with an invalid application identifier and an invalid secret which is not
    // available in the backend at applogger.io. All request in the network will be mocked so that no real network
    // connection is needed
    [[ApploggerManager sharedApploggerManager] setApplicationIdentifier:@"55863CD5-42E8-4CA5-9C39-7DE0EC3A9386"
                                                              AndSecret:@"14E81087-82B6-4C74-9E5D-716ACDBCFF77"];
}

- (void) testVerifyRegisterDeviceUri
{
    // generate the register device uri
    NSString* generatedLink = [[ApploggerManager sharedApploggerManager] getAssignDeviceLink];
    NSURL* generatedUrl = [NSURL URLWithString:generatedLink];
    
    // check the protocol scheme
    XCTAssertTrue([@"https" compare:generatedUrl.scheme] == NSOrderedSame, @"We require https as protocol");
    
    // check the correct host
    XCTAssertTrue([@"applogger.io" compare:generatedUrl.host] == NSOrderedSame, @"The hostname should be applogger.io");
    
    // check the correct port
    XCTAssertTrue(generatedUrl.port.integerValue == 443, @"The networkport should be 443");
    
    // check the correct path
    XCTAssertStringEquals(generatedUrl.path, @"/api/applications/55863CD5-42E8-4CA5-9C39-7DE0EC3A9386/devices/new");
    
    // check the correct query string
    XCTAssertStringContains(generatedUrl.query, @"identifier=");
    XCTAssertStringContains(generatedUrl.query, @"name=iPhone%20Simulator");
    XCTAssertStringContains(generatedUrl.query, @"hwtype=x86");
    XCTAssertStringContains(generatedUrl.query, @"ostype=");
}

- (void) testVerifyRegisterDeviceUriWithCustomServiceUri
{
    // register a custom service uri
    [[ApploggerManager sharedApploggerManager] setServiceUri:@"http://api.google.de:80/applogger"];
    
    // generate the register device uri
    NSString* generatedLink = [[ApploggerManager sharedApploggerManager] getAssignDeviceLink];
    NSURL* generatedUrl = [NSURL URLWithString:generatedLink];
    
    // check the protocol scheme
    XCTAssertTrue([@"http" compare:generatedUrl.scheme] == NSOrderedSame, @"We require http as protocol");
    
    // check the correct host
    XCTAssertTrue([@"api.google.de" compare:generatedUrl.host] == NSOrderedSame, @"The hostname should be api.google.de");
    
    // check the correct port
    XCTAssertTrue(generatedUrl.port.integerValue == 80, @"The networkport should be 80");
    
    // check the correct path
    XCTAssertStringEquals(generatedUrl.path, @"/applogger/applications/55863CD5-42E8-4CA5-9C39-7DE0EC3A9386/devices/new");
    
    // check the correct query string
    XCTAssertStringContains(generatedUrl.query, @"identifier=");
    XCTAssertStringContains(generatedUrl.query, @"name=iPhone%20Simulator");
    XCTAssertStringContains(generatedUrl.query, @"hwtype=x86");
    XCTAssertStringContains(generatedUrl.query, @"ostype=");
}


@end
