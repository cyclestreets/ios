//
//  CSAppleMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 04/06/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSAppleMapSource.h"
#import "AppConstants.h"

@implementation CSAppleMapSource


-(int)maxZoom{
	return 15;
}

-(int)minZoom{
	return 1;
}

- (NSString *)tileTemplate
{
	
	return @"http://tile.cyclestreets.net/opencyclemap/{z}/{x}/{y}.png";
}

- (NSString *)uniqueTilecacheKey
{
	return MAPPING_BASE_APPLE;
}

- (NSString *)shortName
{
	return @"Open Cycle Map";
}

- (NSString *)longDescription
{
	return @"Open Cycle Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

- (NSString *)shortAttribution
{
	return @"© OpenCycleMap CC-BY-SA";
}

- (NSString *)longAttribution
{
	return @"Map data © OpenCycleMap, licensed under Creative Commons Share Alike By Attribution.";
}

@end
