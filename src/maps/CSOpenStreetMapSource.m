//
//  OpenStreetMapsSource.m
//
// Copyright (c) 2008-2013, Route-Me Contributors
// All rights reserved.
//


#import "CSOpenStreetMapSource.h"
#import "AppConstants.h"

@implementation CSOpenStreetMapSource


-(int)maxZoom{
	return 18;
}

-(int)minZoom{
	return 1;
}

- (NSString *)tileTemplate{
	

	return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png";
}

- (NSString *)uniqueTilecacheKey
{
	return MAPPING_BASE_OSM;
}

- (NSString *)shortName
{
	return @"Open Street Map";
}

- (NSString *)longDescription
{
	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

- (NSString *)shortAttribution
{
	return @" © OpenStreetMap CC-BY-SA ";
}

- (NSString *)longAttribution
{
	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
}

@end
