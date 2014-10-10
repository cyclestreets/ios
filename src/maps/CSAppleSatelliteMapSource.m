//
//  CSAppleSatelliteMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSAppleSatelliteMapSource.h"

@implementation CSAppleSatelliteMapSource

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
	return MAPPING_BASE_APPLE_SATELLITE;
}

- (NSString *)shortName
{
	return @"Apple Satellite";
}

- (NSString *)longDescription
{
	return @"Open Cycle Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

- (NSString *)shortDescription
{
	return @"Apple's default satellite image map";
}

- (NSString *)shortAttribution
{
	return @" © Apple 2014 ";
}

- (NSString *)longAttribution
{
	return @"Map data © OpenCycleMap, licensed under Creative Commons Share Alike By Attribution.";
}

-(NSString*)thumbnailImage{
	return @"ASMapStyle.png";
}

@end
