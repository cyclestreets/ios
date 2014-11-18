//
//  RMOpenStreetMapOSMapSource.m
//  MapView
//
//  Created by Neil Edwards on 24/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "CSOrdnanceSurveyStreetViewMapSource.h"
#import "AppConstants.h"

@implementation CSOrdnanceSurveyStreetViewMapSource



-(int)maxZoom{
	return 19;
}

-(int)minZoom{
	return 1;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{
	
	//NSString *tileURLString=[NSString stringWithFormat:@"http://tile.cyclestreets.net/mapnik/%li/%li/%li@%ix.png",(long)path.z,(long)path.x, (long)path.y, (int)path.contentScaleFactor];
	//return [NSURL URLWithString:tileURLString];
	
	NSString *tileURLString=[NSString stringWithFormat:@"http://c.os.openstreetmap.org/sv/%li/%li/%li.png",(long)path.z,(long)path.x, (long)path.y];
	return [NSURL URLWithString:tileURLString];
	
}

-(NSString*) tileTemplate
{
	
	return @"http://c.os.openstreetmap.org/sv/{z}/{x}/{y}.png";
}

-(NSString*) uniqueTilecacheKey
{
	return MAPPING_BASE_OS;
}

-(NSString *)shortName
{
	return @"Open Street Map Ordnance Survey";
}
-(NSString *)longDescription
{
	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}

- (NSString *)shortDescription
{
	return @"Ordnance Survey open data Street View";
}
-(NSString *)shortAttribution
{
	return @" © Ordnance Survey data    ";
}
-(NSString *)longAttribution
{
	return @"Contains Ordnance Survey data (c) Crown copyright and database right 2010";
}

-(NSString*)thumbnailImage{
	return @"OSMapStyle.png";
}

@end
