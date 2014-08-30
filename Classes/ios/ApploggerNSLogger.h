//
//  ApploggerNSLogger.h
//  Pods
//
//  Created by Mirko Olsiewicz on 28.06.14.
//
//

#import <Foundation/Foundation.h>

@protocol ApploggerNSLoggerDelegate <NSObject>

@optional
-(void)nSLoggerConnectionEstablished;
-(void)nSLoggerconnectionFailed:(NSDictionary*)errorDict;

@end
@interface ApploggerNSLogger : NSObject

-(id)initWithDelegate:(id<ApploggerNSLoggerDelegate>) classDelegte;

-(void)registerServer;

@end
