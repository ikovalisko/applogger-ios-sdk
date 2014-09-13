//
//  ioBeaverHelper.h
//  Pods
//
//  Created by Mirko Olsiewicz on 18.03.14.
//
//

#import <Foundation/Foundation.h>

@interface ioBeaverHelper : NSObject
/*
 * get platform for device (ex iPhone1,1)
 */
+ (NSString*)getPlatform;

/*
 * create a bit 64 string
 */
+(NSString *)createBase64String:(NSData *)data WithLength:(unsigned long)length;
+(NSString *)createBase64StringFromString:(NSString*)string;

/*
 * internal log method to enable / disable log in sdk
 */
void internalLog(NSString *format, ...);

/*
 * get a unique id for device
 */
+(NSString*)getUniqueDeviceIdentifier;
@end
