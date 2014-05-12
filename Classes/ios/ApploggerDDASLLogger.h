//
//  ApploggerDDASLLogger.h
//  Pods
//
//  Created by Mirko Olsiewicz on 08.04.14.
//
//

#import "DDLog.h"
#import <Foundation/Foundation.h>

@interface ApploggerDDASLLogger : DDAbstractLogger <DDLogger>

+ (instancetype)sharedInstance;


@end
