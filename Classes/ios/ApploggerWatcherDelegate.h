//
//  ApploggerWatcherDelegate.h
//  Pods
//
//  Created by Dirk Eisenberg on 28/07/14.
//
//

#import <Foundation/Foundation.h>

@protocol ApploggerWatcherDelegate <NSObject>

- (void) apploggerWatchersUpdated:(NSArray*)watchers;

@end
