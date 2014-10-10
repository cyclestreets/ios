//
//  OpenCycleMapSource.m
//
// Copyright (c) 2008-2013, Route-Me Contributors
// All rights reserved.
//


#import "CSOpenCycleMapSource.h"
#import "AppConstants.h"

@implementation CSOpenCycleMapSource



-(int)maxZoom{
	return 19;
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
	return MAPPING_BASE_OPENCYCLEMAP;
}

- (NSString *)shortName
{
	return @"Open Cycle Map";
}

- (NSString *)longDescription
{
	return @"Open Cycle Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

- (NSString *)shortDescription
{
	return @"Detailed map with cycle features and hills";
}

- (NSString *)shortAttribution
{
	return @" © OpenCycleMap; data © OpenStreetMap contributors ";
}

- (NSString *)longAttribution
{
	return @"Map data © OpenCycleMap, licensed under Creative Commons Share Alike By Attribution.";
}

-(NSString*)thumbnailImage{
	return @"OCMMapStyle.png";
}

@end
