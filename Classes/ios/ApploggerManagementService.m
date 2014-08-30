//
//  AppLoggerManagementService.m
//  Pods
//
//  Created by Dirk Eisenberg on 21/04/14.
//
//

#import "ApploggerManagementService.h"
#import "ioApploggerHelper.h"

#import <AdSupport/ASIdentifierManager.h>
#import <UIKit/UIKit.h>

typedef void (^ALMSNetworkRequestCompletionHandler)(NSError *error);

@interface AppLoggerManagementService()
@property (nonatomic, strong) NSString* applicationIdentifier;
@property (nonatomic, strong) NSString* applicationSecret;
@property (nonatomic, strong) NSString* serviceUri;
@property (nonatomic, strong) NSOperationQueue* networkQueue;
@end

@implementation AppLoggerManagementService

+ (id) service:(NSString*)applicationIdentifier withSecret:(NSString*)applicationSecret andServiceUri:(NSString*)serviceUri {
    return [[AppLoggerManagementService alloc] init:applicationIdentifier withSecret:applicationSecret andServiceUri:serviceUri];
}

- (id) init:(NSString*)applicationIdentifier withSecret:(NSString*)applicationSecret andServiceUri:(NSString*)serviceUri {

    // remind some information
    _applicationIdentifier = applicationIdentifier;
    _applicationSecret = applicationSecret;
    _serviceUri = serviceUri;
    
    // create a queue for our network requests
    _networkQueue = [[NSOperationQueue alloc] init];

    return self;
}

- (NSString*) deviceIdentifier {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

- (void) announceDeviceWithName:(NSString*)name completion:(ALMSAnnounceDeviceCompletionHandler)completion {
    
    // build the displayname of the device
    NSString* deviceName = name;
    if (!deviceName)
        deviceName = [[UIDevice currentDevice] name];
    
    // add information for creating a queue for the current device with date prefix
    NSDictionary* postData = @{ @"device" : @{ @"identifier"    : [self deviceIdentifier],
                                               @"name"          : deviceName,
                                               @"hwtype"        : [ioBeaverHelper getPlatform],
                                               @"ostype"        : [[UIDevice currentDevice] systemVersion] } };
        
    
    // perform the request
    [self deviceRequestPost:nil to:nil data:postData completion:^(NSError *error) {
        if (completion)
            completion(error);
    }];
}

- (void) requestDataStreamConfiguration:(ALMSRequestDataStreamConfigurationCompletionHandler)completion {
    
    // create the url for config
    NSURL* dataStreamConfigUrl = [self createDeviceRequestUrl:[self deviceIdentifier]];
    dataStreamConfigUrl = [self append:@"/stream" toRequestUrl:dataStreamConfigUrl];
    
    // Set Url for get stream
    NSMutableURLRequest * dataStreamRequest = [NSMutableURLRequest requestWithURL: dataStreamConfigUrl];

    // configure the correct http headers
    [dataStreamRequest setHTTPMethod:@"GET"];
    [dataStreamRequest addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    // attach the authorization header because we have a harvester request
    [self attachAuthorizationHeaderToRequest:dataStreamRequest];

    // query the data
    [NSURLConnection sendAsynchronousRequest:dataStreamRequest queue:_networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
            completion(nil, connectionError);
        else if ([(NSHTTPURLResponse*)response statusCode] != 200)
            completion(nil, [NSError errorWithDomain:@"HTTP Error" code:[(NSHTTPURLResponse*)response statusCode] userInfo:nil]);
        else {
            
            // parse the result
            NSError* parseError = nil;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
            
            // check if we have a stream config
            if (!result || ![result objectForKey:@"stream"])
            {
                completion(nil, parseError);
                return;
            }
            
            // generate the reuslt obejct
            AppLoggerLogStreamConfiguration* config = [[AppLoggerLogStreamConfiguration alloc] init];
            [config setNetworkProtocol:[[result objectForKey:@"stream"] objectForKey:@"protocol"]];
            [config setServerAddress:[[result objectForKey:@"stream"] objectForKey:@"server"]];
            [config setServerPort:[[result objectForKey:@"stream"] objectForKey:@"port"]];
            
            // done
            completion(config, nil);
        }
    }];
}

- (NSURL*) createDeviceRequestUrl:(NSString*)deviceIdentifier {
    if (deviceIdentifier != nil)
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@/harvester/applications/%@/devices/%@", _serviceUri, _applicationIdentifier, deviceIdentifier]];
    else
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@/harvester/applications/%@/devices", _serviceUri, _applicationIdentifier]];
}

- (NSURL*) append:(NSString*)value toRequestUrl:(NSURL*)requestUrl {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [requestUrl absoluteString], value]];
}

- (void) deviceRequestPost:(NSString*)deviceIdentifier to:(NSString*)subpath data:(NSDictionary*)postData completion:(ALMSNetworkRequestCompletionHandler)completion {

    // Generate the device uri
    NSURL* deviceRelatedUri = [self createDeviceRequestUrl:deviceIdentifier];
    
    // add the sub path
    if (subpath)
        deviceRelatedUri = [self append:subpath toRequestUrl:deviceRelatedUri];
    
    // Generate the postrequest
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:deviceRelatedUri];
    
    // configure the correct http headers
    [postRequest setHTTPMethod:@"POST"];
    [postRequest addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    // attach the authorization header because we have a harvester request
    [self attachAuthorizationHeaderToRequest:postRequest];
    
    // convert the data to json
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:&error];
    
    // set the http body
    [postRequest setHTTPBody:jsonData];
    
    // create the connection with the request
    [NSURLConnection sendAsynchronousRequest:postRequest queue:_networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
            completion(connectionError);
        else if ([(NSHTTPURLResponse*)response statusCode] != 201)
            completion([NSError errorWithDomain:@"HTTP Error" code:[(NSHTTPURLResponse*)response statusCode] userInfo:nil]);
        else
            completion(nil);
    }];
}

/*
 * Current option: Authorization: Secret ZTJmZjljZjYtOWZjOC00NzVmLTk3ZjMtYjE4ZTVkMTE4Nzc0
 */
- (void) attachAuthorizationHeaderToRequest:(NSMutableURLRequest*)request {
    // attach the authorization header because we have a harvester request
    NSString *authPayload = [ioBeaverHelper createBase64StringFromString:_applicationSecret];
    [request setValue:[NSString stringWithFormat:@"Secret %@", authPayload] forHTTPHeaderField:@"Authorization"];
}

- (void) requestWatchersProfile:(NSString*)userIndentifier completion:(ALMSRequestWatchersProfileCompletionHandler)completion {

    // create the url for profile
    NSURL* requestProfileUrl = [self createDeviceRequestUrl:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    requestProfileUrl = [self append:@"/watchers/" toRequestUrl:requestProfileUrl];
    requestProfileUrl = [self append:userIndentifier toRequestUrl:requestProfileUrl];
    
    // Set Url for get profile
    NSMutableURLRequest * profileRequest = [NSMutableURLRequest requestWithURL: requestProfileUrl];
    
    // configure the correct http headers
    [profileRequest setHTTPMethod:@"GET"];
    [profileRequest addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    // attach the authorization header because we have a harvester request
    [self attachAuthorizationHeaderToRequest:profileRequest];
    
    // query the data
    [NSURLConnection sendAsynchronousRequest:profileRequest queue:_networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
            completion(nil, connectionError);
        else if ([(NSHTTPURLResponse*)response statusCode] != 200)
            completion(nil, [NSError errorWithDomain:@"HTTP Error" code:[(NSHTTPURLResponse*)response statusCode] userInfo:nil]);
        else {
            
            // parse the result
            NSError* parseError = nil;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
            
            // check if we have at lease a name
            if (!result || ![result objectForKey:@"name"])
            {
                completion(nil, parseError);
                return;
            }
            
            // generate the reuslt obejct
            ApploggerWatcher* watcher = [[ApploggerWatcher alloc] init];
            [watcher setIdentifier:userIndentifier];
            [watcher setName:[result objectForKey:@"name"]];
            
            // check if we have an icon
            if ([result objectForKey:@"image"]) {
                
                // load the image data
                @try {
                    NSData* iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"image"]]];
                    [watcher setAvatar:iconData];
                }
                @catch (NSException *exception) {

                }
            }
            
            // done
            completion(watcher, nil);
        }
    }];
}

@end
