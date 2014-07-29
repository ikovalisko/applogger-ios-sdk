//
//  ApploggerWatcher.h
//  Pods
//
//  Created by Dirk Eisenberg on 29/07/14.
//
//

#import <Foundation/Foundation.h>

@interface ApploggerWatcher : NSObject

/*
 * The unique identifier of the watcher
 */
@property (nonatomic, strong) NSString* Identifier;

/* 
 * Contains the name of the user is watching the stream 
 */
@property (nonatomic, strong) NSString* Name;

/*
 * Contains the data for the avatar image of the user is watching the stream
 */
@property (nonatomic, strong) NSData*   Avatar;

@end
