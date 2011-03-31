//
//  SettingsVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 31/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "SettingsVO.h"


@implementation SettingsVO
@synthesize plan;
@synthesize speed;
@synthesize mapStyle;
@synthesize imageSize;
@synthesize routeUnit;

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
        imageSize = @"640px";
        routeUnit = @"miles";
    }
    return self;
}








static NSString *PLAN = @"plan";
static NSString *SPEED = @"speed";
static NSString *MAP_STYLE = @"mapStyle";
static NSString *IMAGE_SIZE = @"imageSize";
static NSString *ROUTE_UNIT = @"routeUnit";



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
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.plan = [decoder decodeObjectForKey:PLAN];
        self.speed = [decoder decodeObjectForKey:SPEED];
        self.mapStyle = [decoder decodeObjectForKey:MAP_STYLE];
        self.imageSize = [decoder decodeObjectForKey:IMAGE_SIZE];
        self.routeUnit = [decoder decodeObjectForKey:ROUTE_UNIT];
    }
    return self;
}
@end
