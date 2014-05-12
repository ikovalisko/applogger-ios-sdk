//
//  AppLoggerLogStreamConfiguration.h
//  Pods
//
//  Created by Dirk Eisenberg on 21/04/14.
//
//

#import <Foundation/Foundation.h>

@interface AppLoggerLogStreamConfiguration : NSObject
@property (nonatomic, strong) NSString* networkProtocol;
@property (nonatomic, strong) NSString* serverAddress;
@property (nonatomic, strong) NSNumber* serverPort;
@end
