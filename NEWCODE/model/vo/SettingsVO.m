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
@synthesize plan;
@synthesize speed;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize routeUnit;
@synthesize showRoutePoint;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [plan release], plan = nil;
    [speed release], speed = nil;
    [mapStyle release], mapStyle = nil;
    [imageSize release], imageSize = nil;
    [routeUnit release], routeUnit = nil;
	
    [super dealloc];
}


/***********************************************************/
// - (id)init
//
/***********************************************************/
- (id)init
{
    self = [super init];
    if (self) {
        self.plan = @"balanced";
        speed = @"12";
        mapStyle = @"OpenStreetMap";
        imageSize = @"full";
        routeUnit = @"miles";
		showRoutePoint=YES;
    }
    return self;
}




-(NSString*)returnKilometerSpeedValue{
	
	if([routeUnit isEqualToString:MILES]){
		int milesvalue=[speed intValue]*1.70;
		return [NSString stringWithFormat:@"%i",milesvalue];
	}else{
		return speed;
	}
	
}


static NSString *PLAN = @"plan";
static NSString *SPEED = @"speed";
static NSString *MAP_STYLE = @"mapStyle";
static NSString *IMAGE_SIZE = @"imageSize";
static NSString *ROUTE_UNIT = @"routeUnit";
static NSString *SHOW_ROUTE_POINT = @"showRoutePoint";



/***********************************************************/
//  Keyed Archiving
//
/***********************************************************/
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.plan forKey:PLAN];
    [encoder encodeObject:self.speed forKey:SPEED];
    [encoder encodeObject:self.mapStyle forKey:MAP_STYLE];
    [encoder encodeObject:self.imageSize forKey:IMAGE_SIZE];
    [encoder encodeObject:self.routeUnit forKey:ROUTE_UNIT];
    [encoder encodeBool:self.showRoutePoint forKey:SHOW_ROUTE_POINT];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super init])) {
        self.plan = [decoder decodeObjectForKey:PLAN];
        self.speed = [decoder decodeObjectForKey:SPEED];
        self.mapStyle = [decoder decodeObjectForKey:MAP_STYLE];
        self.imageSize = [decoder decodeObjectForKey:IMAGE_SIZE];
        self.routeUnit = [decoder decodeObjectForKey:ROUTE_UNIT];
        self.showRoutePoint = [decoder decodeBoolForKey:SHOW_ROUTE_POINT];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
	
    [theCopy setPlan:[[self.plan copy] autorelease]];
    [theCopy setSpeed:[[self.speed copy] autorelease]];
    [theCopy setMapStyle:[[self.mapStyle copy] autorelease]];
    [theCopy setImageSize:[[self.imageSize copy] autorelease]];
    [theCopy setRouteUnit:[[self.routeUnit copy] autorelease]];
    [theCopy setShowRoutePoint:self.showRoutePoint];
	
    return theCopy;
}
@end
