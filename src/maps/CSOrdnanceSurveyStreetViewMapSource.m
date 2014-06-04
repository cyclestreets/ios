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
	return 18;
}

-(int)minZoom{
	return 1;
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
-(NSString *)shortAttribution
{
	return @" © Ordnance Survey data (c)    ";
}
-(NSString *)longAttribution
{
	return @"Contains Ordnance Survey data (c) Crown copyright and database right 2010";
}

@end
