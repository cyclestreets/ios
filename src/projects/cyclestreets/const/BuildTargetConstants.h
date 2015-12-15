//
//  BuildTargetConstants.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppConstants.h"

extern NSString *const API_IDENTIFIER;
extern NSString *const APPLICATIONNAME;

extern BOOL const APIREQUIRESIDENTIFIER;


@interface BuildTargetConstants : NSObject


+(NSArray*)ApplicationSupportedMaps;

+(ApplicationBuildTarget)buildTarget;

+(NSString*)defaultMapStyle;

+(void)insertAPIIdentifier:(NSMutableDictionary*)requestDict;

@end
