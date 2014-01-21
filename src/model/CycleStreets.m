/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  CycleStreets.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "CycleStreets.h"
#import "Files.h"
#import "PhotoCategoryManager.h"
#import "SynthesizeSingleton.h"

#import "RMOpenStreetMapSource.h"
#import "RMOpenCycleMapSource.h"


static NSInteger MAX_ZOOM = 18;

static NSInteger MAX_ZOOM_LOCATION = 16;
static NSInteger MAX_ZOOM_LOCATION_ACCURACY = 200;


@implementation CycleStreets
SYNTHESIZE_SINGLETON_FOR_CLASS(CycleStreets);
@synthesize appDelegate;
@synthesize files;
@synthesize APIKey;
@synthesize userAgent;





- (id) init {
	if (self = [super init]) {
		self.files = [[Files alloc] init];
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSDictionary *infoDict=[mainBundle infoDictionary];
		NSString *appconfigid=[infoDict objectForKey:@"APPCONFIG_ID"];
		NSString *APIFile=nil;
		
		if([appconfigid isEqualToString:APPSTATE_LIVE]){
			APIFile=[mainBundle pathForResource:@"APIKey_live" ofType:@"txt"];
		}else{
			APIFile=[mainBundle pathForResource:@"APIKey_dev" ofType:@"txt"];
		}
		
		
		NSString *keyFromFile = [NSString stringWithContentsOfFile:APIFile encoding:NSUTF8StringEncoding error:NULL];
		self.APIKey = [keyFromFile stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
		
		NSString *version=[infoDict objectForKey:@"CFBundleVersion"];
		NSString *appName=[infoDict objectForKey:@"CFBundleName"];
		self.userAgent=[NSString stringWithFormat:@"%@ iOS / %@",appName,version];
		
		[PhotoCategoryManager sharedInstance];
	}
	return self;
}



#pragma mark - Class methods

+ ( NSObject <RMTileSource> *)tileSource {
	NSString *mapStyle = [[self class] currentMapStyle];
	NSObject <RMTileSource> *tileSource;
	if ([mapStyle isEqualToString:MAPPING_BASE_OSM])
	{
		tileSource = [[RMOpenStreetMapSource alloc] init];
	}
	else if ([mapStyle isEqualToString:MAPPING_BASE_OPENCYCLEMAP])
	{
		//open cycle map
		tileSource = [[RMOpenCycleMapSource alloc] init];
	}
		else
	{
		//default to MAPPING_BASE_OSM.
		tileSource = [[RMOpenStreetMapSource alloc] init];
	}
	return tileSource;
}


+ (NSArray *)mapStyles {
	return [NSArray arrayWithObjects:MAPPING_BASE_OSM, MAPPING_BASE_OPENCYCLEMAP, MAPPING_BASE_OS,nil];
}

+ (NSString *)currentMapStyle {
	NSString *mapStyle = MAPPING_BASE_OSM;
	if (mapStyle == nil) {
		mapStyle = [[[self class] mapStyles] objectAtIndex:0];
	}
	
	return mapStyle;
}

+ (NSString *)mapAttribution {
	NSString *mapStyle = [[self class] currentMapStyle];
	NSString *mapAttribution = nil;
	if ([mapStyle isEqualToString:MAPPING_BASE_OSM]) {
		mapAttribution = MAPPING_ATTRIBUTION_OSM;
	} else if ([mapStyle isEqualToString:MAPPING_BASE_OPENCYCLEMAP]) {
		mapAttribution = MAPPING_ATTRIBUTION_OPENCYCLEMAP;
	}else if ([mapStyle isEqualToString:MAPPING_BASE_OS]) {
		mapAttribution = MAPPING_ATTRIBUTION_OS;
	}
	return mapAttribution;
	
}

+ (void)zoomMapView:(RMMapView *)mapView toLocation:(CLLocation *)newLocation {
	CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
	if (accuracy < 0) {
		accuracy = 2000;
	}
	int wantZoom = MAX_ZOOM_LOCATION;
	CLLocationAccuracy wantAccuracy = MAX_ZOOM_LOCATION_ACCURACY;
	while (wantAccuracy < accuracy) {
		wantZoom--;
		wantAccuracy = wantAccuracy * 2;
	}
	
	[mapView setCenterCoordinate:newLocation.coordinate];
	[mapView setZoom:wantZoom];
}


@end
