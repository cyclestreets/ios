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
	return 19;
}

-(int)minZoom{
	return 1;
}

//-(CGSize) tileSize{
//	return CGSizeMake(256,256);
//};
//
- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{
	
	//NSString *tileURLString=[NSString stringWithFormat:@"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png",(long)path.z,(long)path.x, (long)path.y, (int)path.contentScaleFactor];
	//return [NSURL URLWithString:tileURLString];
	
	NSString *tileURLString=[NSString stringWithFormat:@"http://tile.cyclestreets.net/mapnik/%li/%li/%li.png",(long)path.z,(long)path.x, (long)path.y];
	return [NSURL URLWithString:tileURLString];
	
}


- (NSString *)tileTemplate{
	
	return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png";

	//return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}@{s}x.png";
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

- (NSString *)shortDescription
{
	return @"General map style";
}

- (NSString *)shortAttribution
{
	return @"© OpenStreetMap contributors";
}

- (NSString *)longAttribution
{
	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
}

-(NSString*)thumbnailImage{
	return @"OSMMapStyle.png";
}



@end
