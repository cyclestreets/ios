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

//  ALAsset+Info.m
//  CycleStreets
//
//  Created by Alan Paxton on 19/08/2010.
//

#import "ALAsset+Info.h"
#import "CycleStreets.h"
#import "Files.h"

@implementation ALAsset (Info)

- (NSString *) keyOfAssetURL:(NSURL *)url {
	NSString *key = [url absoluteString];
	key = [key stringByReplacingOccurrencesOfString:@"/" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"=" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"&" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"-" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@":" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"?" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"." withString:@""];
	return key;
}

//save location in our own database.
- (void) saveLocation:(CLLocationCoordinate2D)location {
	NSDictionary *urlDictionary = [self valueForProperty:ALAssetPropertyURLs];
	NSURL *jpeg = [urlDictionary valueForKey:@"public.jpeg"];
	
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	Files *files = cycleStreets.files;
	NSMutableDictionary *photoLocations = [NSMutableDictionary dictionaryWithDictionary:[files photoLocations]];
	NSDictionary *latlon = [NSDictionary dictionaryWithObjectsAndKeys:
							[[NSNumber numberWithDouble:location.latitude] stringValue],
							@"latitude",
							[[NSNumber numberWithDouble:location.longitude] stringValue],
							@"longitude",
							nil];
	[photoLocations setValue:latlon forKey:[jpeg absoluteString]];
	[files setPhotoLocations:photoLocations];
}

- (CLLocationCoordinate2D) restoreLocation:(NSURL *)assetURL {
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	Files *files = cycleStreets.files;
	NSDictionary *photoLocations = [files photoLocations];
	NSDictionary *latlon = [photoLocations valueForKey:[assetURL absoluteString]];
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 0.0;
	coordinate.longitude = 0.0;
	if (latlon != nil) {
		coordinate.latitude = [[latlon valueForKey:@"latitude"] doubleValue];
		coordinate.longitude = [[latlon valueForKey:@"longitude"] doubleValue];
	}
	return coordinate;
}

- (CLLocationCoordinate2D) location {
	CLLocation *location = [self valueForProperty:ALAssetPropertyLocation];
	if (CLLocationCoordinate2DIsValid(location.coordinate)) {
		return location.coordinate;
	}
	
	NSDictionary *dictionary = [[self defaultRepresentation] metadata];
	if ([dictionary valueForKey:@"{GPS}"] != nil) {
		CLLocationCoordinate2D coordinate;
		coordinate.latitude = [[dictionary valueForKeyPath:@"{GPS}.Latitude"] doubleValue];
		coordinate.longitude = [[dictionary valueForKeyPath:@"{GPS}.Longitude"] doubleValue];
		NSString *latitudeRef = [dictionary valueForKeyPath:@"{GPS}.LatitudeRef"];
		if ([latitudeRef isEqualToString:@"S"]) {
			coordinate.latitude = -coordinate.latitude;
		}
		NSString *longitudeRef = [dictionary valueForKeyPath:@"{GPS}.LongitudeRef"];
		if ([longitudeRef isEqualToString:@"W"]) {
			coordinate.longitude = -coordinate.longitude;
		}
		return coordinate;
	}
	
	//Look it up in our own database - the one for images we saved ourselves.
	NSDictionary *urlDictionary = [self valueForProperty:ALAssetPropertyURLs];
	NSURL *jpeg = [urlDictionary valueForKey:@"public.jpeg"];
	CLLocationCoordinate2D coordinate = [self restoreLocation:jpeg];
	return coordinate;
}

- (NSDate *) date {
	NSDate *date = [self valueForProperty:ALAssetPropertyDate];
	return date;
}

@end
