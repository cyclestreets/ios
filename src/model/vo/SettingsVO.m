//
//  SettingsVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 31/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "SettingsVO.h"
#import "AppConstants.h"


@implementation SettingsVO



/***********************************************************/
// - (id)init
//
/***********************************************************/
- (id)init
{
    self = [super init];
    if (self) {
		// set defaults
        _imageSize=@"full";
        _mapStyle = @"OpenCycleMap";
        _routeUnit = @"miles";
		_autoEndRoute=NO;
    }
    return self;
}





static NSString *PLAN = @"plan";
static NSString *SPEED = @"speed";
static NSString *MAP_STYLE = @"mapStyle";
static NSString *IMAGE_SIZE = @"imageSize";
static NSString *ROUTE_UNIT = @"routeUnit";
static NSString *SHOW_ROUTE_POINT = @"autoEndRoute";



/***********************************************************/
//  Keyed Archiving
//
/***********************************************************/
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    
    [encoder encodeObject:self.imageSize forKey:IMAGE_SIZE];
    [encoder encodeObject:self.mapStyle forKey:MAP_STYLE];
    [encoder encodeObject:self.routeUnit forKey:ROUTE_UNIT];
    [encoder encodeBool:self.autoEndRoute forKey:SHOW_ROUTE_POINT];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super init])) {
        self.mapStyle = [decoder decodeObjectForKey:MAP_STYLE];
        self.routeUnit = [decoder decodeObjectForKey:ROUTE_UNIT];
        self.autoEndRoute = [decoder decodeBoolForKey:SHOW_ROUTE_POINT];
		self.imageSize=[decoder decodeObjectForKey:IMAGE_SIZE];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];
	
    [theCopy setMapStyle:[self.mapStyle copy]];
    [theCopy setRouteUnit:[self.routeUnit copy]];
    [theCopy setAutoEndRoute:self.autoEndRoute];
	[theCopy setImageSize:self.imageSize];
	
    return theCopy;
}
@end
