//
//  OpenStreetMapsSource.m
//
// Copyright (c) 2008-2013, Route-Me Contributors
// All rights reserved.
//


#import "CSOpenStreetMapSource.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"

@interface CSOpenStreetMapSource()

@end

@implementation CSOpenStreetMapSource


// getters

-(CGSize)tileSize{
	if (self.isRetinaEnabled) {
		return CGSizeMake(512,512);
	}else{
		return CGSizeMake(256,256);
	}
}

-(int)maxZoom{
	return 19;
}

-(int)minZoom{
	return 1;
}

-(BOOL)isRetinaEnabled{
	return YES;
}


// for use with new retina tiles
-(NSString*)cacheTileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/%li/%li/%li.png";
	}

}

// for use directly with map kit, if - (NSURL *)URLForTilePath:(MKTileOverlayPath)path is implemented this is effectively ignored
- (NSString *)tileTemplate{
	
	if([self isRetinaEnabled]){
		return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}/{s}.png";
	}else{
		return @"http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png";
	}
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
