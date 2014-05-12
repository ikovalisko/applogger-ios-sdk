//
//  UnittestHelperMacros.h
//  applogger-unittest-app
//
//  Created by Dirk Eisenberg on 10/05/14.
//  Copyright (c) 2014 applogger.io. All rights reserved.
//

#ifndef applogger_unittest_app_UnittestHelperMacros_h
#define applogger_unittest_app_UnittestHelperMacros_h

#define XCTAssertStringEquals(stringValue, expectValue)  XCTAssertTrue([stringValue isEqualToString:expectValue], @"Strings are not equal %@ %@", expectValue, stringValue)
#define XCTAssertStringContains(stringValue, expectValue) XCTAssertFalse([stringValue rangeOfString:expectValue].location == NSNotFound, @"String contains not other string %@ %@", expectValue, stringValue)

#endif
