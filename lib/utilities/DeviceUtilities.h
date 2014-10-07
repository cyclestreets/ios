//
//  DeviceUtilities.h
//
//
//  Created by neil on 25/02/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <sys/utsname.h>

enum {
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPAD_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPAD,
    MODEL_IPAD_2,
	MODEL_IPAD_3,
    MODEL_IPHONE_3GS,
    MODEL_IPHONE_4,
	MODEL_IPHONE_4S
};

enum {
    DEVICEFAMILY_SIMULATOR,
    DEVICEFAMILY_IPAD,
    DEVICEFAMILY_IPOD_TOUCH,
    DEVICEFAMILY_IPHONE
};

@interface DeviceUtilities : NSObject

+ (uint) detectDevice;
+ (uint) detectDeviceFamily;
+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;
+ (NSString *) uniqueIdentifier;
+(BOOL)isSimulatorDevice;

@end