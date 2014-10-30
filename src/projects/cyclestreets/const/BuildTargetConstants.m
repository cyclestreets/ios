//
//  BuildTargetConstants.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BuildTargetConstants.h"

#import "AppConstants.h"

NSString *const API_IDENTIFIER=@"cyclestreets";
NSString *const APPLICATIONNAME=@"CycleStreets";

@implementation BuildTargetConstants

+(NSArray*)ApplicationSupportedMaps{
	
	return @[MAPPING_BASE_OSM,MAPPING_BASE_OPENCYCLEMAP,MAPPING_BASE_OS,MAPPING_BASE_APPLE_VECTOR];
	
}

+(ApplicationBuildTarget)buildTarget{
	return ApplicationBuildTarget_CycleStreets;
}



@end
