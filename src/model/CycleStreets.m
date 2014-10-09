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
//

#import "CycleStreets.h"
#import "Files.h"
#import "PhotoCategoryManager.h"
#import "SynthesizeSingleton.h"
#import "SettingsManager.h"
#import "AppConstants.h"
#import "GenericConstants.h"
#import "CSMapSourceProtocol.h"

#import "CSOpenCycleMapSource.h"
#import "CSOpenStreetMapSource.h"
#import "CSOrdnanceSurveyStreetViewMapSource.h"
#import "CSAppleVectorMapSource.h"
#import "CSCycleNorthMapSource.h"
#import "CSAppleSatelliteMapSource.h"

const NSInteger MAX_ZOOM_LOCATION = 18;
const NSInteger MAX_ZOOM_SEGMENT = 20;
const NSInteger MAX_ZOOM_LOCATION_ACCURACY = 200;

@implementation CycleStreets
SYNTHESIZE_SINGLETON_FOR_CLASS(CycleStreets);


- (id) init {
	
	self = [super init];
	
	if (self) {
		
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
		
		self.appTarget=[infoDict objectForKey:@"APPTARGET"];
		
	}
	return self;
}




+ (NSArray *)mapStyles {
	return [NSArray arrayWithObjects:MAPPING_BASE_OSM, MAPPING_BASE_OPENCYCLEMAP,MAPPING_BASE_OS,MAPPING_BASE_APPLE_VECTOR,nil];
}


+ (NSString *)currentMapStyle {
	NSString *mapStyle = [SettingsManager sharedInstance].dataProvider.mapStyle;
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
		
	}else if ([mapStyle isEqualToString:MAPPING_BASE_APPLE_VECTOR]) {
		
		mapAttribution = nil;
		
	}
	return mapAttribution;
	
}


+(CSMapSource*)activeMapSource{
	
	NSString *mapStyle = [CycleStreets currentMapStyle];
	
	if ([mapStyle isEqualToString:MAPPING_BASE_OSM]){
		
		return [[CSOpenStreetMapSource alloc]init];
		
	}else if ([mapStyle isEqualToString:MAPPING_BASE_OPENCYCLEMAP]){
		
		return [[CSOpenCycleMapSource alloc]init];
		
	}else if ([mapStyle isEqualToString:MAPPING_BASE_OS]){
		
		return [[CSOrdnanceSurveyStreetViewMapSource alloc]init];
		
	}else if ([mapStyle isEqualToString:MAPPING_BASE_APPLE_VECTOR]){
		
		return [[CSAppleVectorMapSource alloc]init];
		
	}else if ([mapStyle isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
		
		return [[CSAppleSatelliteMapSource alloc]init];
		
	}else if ([mapStyle isEqualToString:MAPPING_BASE_CYCLENORTH]){
		
		return [[CSCycleNorthMapSource alloc]init];
	}
	
	return [[CSOpenStreetMapSource alloc]init];
	
	
}



@end
