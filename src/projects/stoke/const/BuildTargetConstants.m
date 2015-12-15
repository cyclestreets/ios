//
//  BuildTargetConstants.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BuildTargetConstants.h"
#import "CycleStreets.h"

NSString *const API_IDENTIFIER=@"cyclenorthstaffs";
NSString *const APPLICATIONNAME=@"Cycle North Staffs";
NSString *const CYCLENORTHSTAFFS=@"cyclenorthstaffs";

BOOL const APIREQUIRESIDENTIFIER=YES;



@implementation BuildTargetConstants


+(NSArray*)ApplicationSupportedMaps{
	
	return @[MAPPING_BASE_CYCLENORTH, MAPPING_BASE_OSM,MAPPING_BASE_OPENCYCLEMAP,MAPPING_BASE_OS,MAPPING_BASE_APPLE_VECTOR,MAPPING_BASE_BING_SATELLITE];
	
}

+(ApplicationBuildTarget)buildTarget{
	return ApplicationBuildTarget_CNS;
}

+(NSString*)defaultMapStyle{
	return MAPPING_BASE_CYCLENORTH;
}

+(void)insertAPIIdentifier:(NSMutableDictionary*)requestDict{
	
	[requestDict setObject:API_IDENTIFIER forKey:@"username"];
	
}

@end
