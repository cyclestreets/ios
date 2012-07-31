//
//  DeviceUtilities.m
//
//
//  Created by neil on 25/02/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "DeviceUtilities.h"


@implementation DeviceUtilities

+ (uint) detectDevice {
    NSString *model= [[UIDevice currentDevice] model];
    
    // Some iPod Touch return "iPod Touch", others just "iPod"
    
    NSString *iPodTouch = @"iPod Touch";
    NSString *iPodTouchLowerCase = @"iPod touch";
    NSString *iPodTouchShort = @"iPod";
    NSString *iPad = @"iPad";
    NSString *iPhoneSimulator = @"iPhone Simulator";
    NSString *iPadSimulator = @"iPad Simulator";
    
    uint detected;
    struct utsname u;
    uname(&u);
    
    if ([model compare:iPhoneSimulator] == NSOrderedSame) {
        // iPhone simulator
        detected = MODEL_IPHONE_SIMULATOR;
    } else if ([model compare:iPodTouch] == NSOrderedSame) {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    } else if ([model compare:iPodTouchLowerCase] == NSOrderedSame) {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    } else if ([model compare:iPodTouchShort] == NSOrderedSame) {
        // iPod Touch
        detected = MODEL_IPOD_TOUCH;
    }else if ([model compare:iPadSimulator] == NSOrderedSame) {
        // iPad Simulator
        detected = MODEL_IPAD_SIMULATOR;
    }else if ([model compare:iPad] == NSOrderedSame) {
        // iPad
        if (!strcmp(u.machine, "iPad1,1")) {
            detected = MODEL_IPAD;
        } else if (!strcmp(u.machine, "iPad2,1")){
            detected = MODEL_IPAD_2;
        }else {
			detected=MODEL_IPAD_3;
		}
        
    } else {
        // iPhone
        
        if (!strcmp(u.machine, "iPhone1,1")) {
            detected = MODEL_IPHONE;
        } else if (!strcmp(u.machine, "iPhone1,2")){
            detected = MODEL_IPHONE_3G;
        }else if (!strcmp(u.machine, "iPhone2,1")){
            detected = MODEL_IPHONE_3GS;
        }else if(!strcmp(u.machine, "iPhone3,1")){ 
            detected = MODEL_IPHONE_4;
        }else{
			detected=MODEL_IPHONE_4S;
		}
    }
    return detected;
}


+ (uint) detectDeviceFamily {
    NSString *model= [[UIDevice currentDevice] model];
    
    // Some iPod Touch return "iPod Touch", others just "iPod"
    
    NSString *iPodTouch = @"iPod Touch";
    NSString *iPodTouchLowerCase = @"iPod touch";
    NSString *iPodTouchShort = @"iPod";
    NSString *iPad = @"iPad";
    NSString *iPhoneSimulator = @"iPhone Simulator";
    NSString *iPadSimulator = @"iPad Simulator";
    
    uint detected;
    struct utsname u;
    uname(&u);
    
    if ([model compare:iPhoneSimulator] == NSOrderedSame) {
        // iPhone simulator
        detected = DEVICEFAMILY_SIMULATOR;
    } else if ([model compare:iPodTouch] == NSOrderedSame) {
        // iPod Touch
        detected = DEVICEFAMILY_IPOD_TOUCH;
    } else if ([model compare:iPodTouchLowerCase] == NSOrderedSame) {
        // iPod Touch
        detected = DEVICEFAMILY_IPOD_TOUCH;
    } else if ([model compare:iPodTouchShort] == NSOrderedSame) {
        // iPod Touch
        detected = DEVICEFAMILY_IPOD_TOUCH;
    }else if ([model compare:iPadSimulator] == NSOrderedSame) {
        // iPad Simulator
        detected = DEVICEFAMILY_SIMULATOR;
    }else if ([model compare:iPad] == NSOrderedSame) {
        detected = DEVICEFAMILY_IPAD;
        
    } else {
        detected=DEVICEFAMILY_IPHONE;
    }
    return detected;
}


+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator {
    NSString *returnValue = @"Unknown";
    
    switch ([DeviceUtilities detectDevice]) {
        case MODEL_IPHONE_SIMULATOR:
            if (ignoreSimulator) {
                returnValue = @"iPhone 3G";
            } else {
                returnValue = @"iPhone Simulator";
            }
            break;
        case MODEL_IPOD_TOUCH:
            returnValue = @"iPod Touch";
            break;
        case MODEL_IPHONE:
            returnValue = @"iPhone";
            break;
        case MODEL_IPHONE_3G:
            returnValue = @"iPhone 3G";
            break;
        case MODEL_IPHONE_3GS:
            returnValue = @"iPhone 3GS";
            break;
        case MODEL_IPHONE_4:
            returnValue = @"iPhone 4";
            break;
		case MODEL_IPHONE_4S:
            returnValue = @"iPhone 4S";
            break;
        case MODEL_IPAD:
            returnValue = @"iPad";
            break;
        case MODEL_IPAD_2:
            returnValue = @"iPad 2";
            break;
		case MODEL_IPAD_3:
            returnValue = @"iPad 3";
            break;
        default:
            break;
    }
    
    return returnValue;
}


+ (NSString *) uniqueIdentifier{
	
    CFUUIDRef   uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    
	NSString *convertedStr=(__bridge_transfer NSString *)uuidStr;
	NSString *str = [NSString stringWithFormat:@"%@",convertedStr];
	
	CFRelease(uuidStr);
    CFRelease(uuid);
	
	return str;
	
}

@end
