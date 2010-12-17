//
//  DeviceUtilities.h
//  RacingUK
//
//  Created by neil on 25/02/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import <sys/utsname.h>

enum {
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPHONE,
    MODEL_IPHONE_3G
};

@interface DeviceUtilities : NSObject

+ (uint) detectDevice;
+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;

@end