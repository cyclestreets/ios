//
//  RMOpenStreetMapOSMapSource.m
//  MapView
//
//  Created by Neil Edwards on 24/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "RMOrdnanceSurveyStreetViewMapSource.h"


@implementation RMOrdnanceSurveyStreetViewMapSource

-(id) init
{       
	if(self = [super init]) 
	{
		//http://wiki.openstreetmap.org/index.php/FAQ#What_is_the_map_scale_for_a_particular_zoom_level_of_the_map.3F 
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
	return [NSString stringWithFormat:@"http://c.os.openstreetmap.org/sv/%d/%d/%d.png", tile.zoom, tile.x, tile.y];
}

-(NSString*) uniqueTilecacheKey
{
	return @"OpenStreetMapOS";
}

-(NSString *)shortName
{
	return @"Open Street Map Ordnance Survey";
}
-(NSString *)longDescription
{
	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}
-(NSString *)shortAttribution
{
	return @"© Ordnance Survey data (c)";
}
-(NSString *)longAttribution
{
	return @"Contains Ordnance Survey data (c) Crown copyright and database right 2010";
}

@end
