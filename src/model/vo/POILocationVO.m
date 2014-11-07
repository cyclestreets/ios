//
//  POILocationVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POILocationVO.h"
#import <MapKit/MapKit.h>

@implementation POILocationVO


- (instancetype)init
{
	self = [super init];
	if (self) {
		
	}
	return self;
}

// note manual nscoding due to _coordinate

- (void)encodeWithCoder:(NSCoder *)encoder
{
	
	[encoder encodeObject:_poiType forKey:@"poitype"];
	[encoder encodeObject:_locationid forKey:@"locationid"];
	[encoder encodeObject:_name forKey:@"name"];
	[encoder encodeObject:_notes forKey:@"notes"];
	[encoder encodeObject:_website forKey:@"website"];
	[encoder encodeDouble:_coordinate.latitude forKey:@"latitude"];
	[encoder encodeDouble:_coordinate.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if((self = [super init])) {
		
		_name=[decoder decodeObjectForKey:@"name"];
		_locationid=[decoder decodeObjectForKey:@"locationid"];
		_poiType=[decoder decodeObjectForKey:@"poiType"];
		_notes=[decoder decodeObjectForKey:@"notes"];
		_website=[decoder decodeObjectForKey:@"website"];
		
		CLLocationDegrees latitude = [decoder decodeDoubleForKey:@"latitude"];
		CLLocationDegrees longitude = [decoder decodeDoubleForKey:@"longitude"];
		_coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		
	}
	return self;
}

@end
