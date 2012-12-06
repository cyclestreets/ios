//
//  CSOverlayMapSource.m
//  CycleStreets
//
//  Created by Neil Edwards on 06/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "CSOverlayMapSource.h"


@interface CSOverlayMapSource()

@end


@implementation CSOverlayMapSource

-(id) init
{
	if(self = [super init])
	{
		[self setMaxZoom:18];
		[self setMinZoom:1];
	}
	return self;
}

-(NSString*) tileURL: (RMTile) tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f",
			  self, tile.zoom, self.minZoom, self.maxZoom);
	return [NSString stringWithFormat:@"http://www.buffer.uk.com/iphone/cyclestreets/CSMapOverlay.png"];
}

-(NSString*) uniqueTilecacheKey
{
	return @"OpenCycleMap";
}

-(NSString *)shortName
{
	return @"Open Cycle Map";
}
-(NSString *)longDescription
{
	return @"Open Cycle Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}
-(NSString *)shortAttribution
{
	return @"© OpenCycleMap CC-BY-SA";
}
-(NSString *)longAttribution
{
	return @"Map data © OpenCycleMap, licensed under Creative Commons Share Alike By Attribution.";
}

@end
