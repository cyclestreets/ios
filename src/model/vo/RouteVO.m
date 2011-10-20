//
//  RouteVO.m
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteVO.h"
#import "SegmentVO.h"
#import "SettingsManager.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "NSDate+Helper.h"

// deprecated
/*
static NSString *ROUTE_ELEMENT = @"cs:route";
static NSString *SEGMENT_ELEMENT = @"cs:segment";
static NSString *ITINERARY = @"cs:itinerary";
static NSString *EAST = @"cs:east";
static NSString *WEST = @"cs:west";
static NSString *NORTH = @"cs:north";
static NSString *SOUTH = @"cs:south";
static NSString *SPEED = @"cs:speed";
static NSString *NAME = @"cs:name";
static NSString *LENGTH = @"cs:length";
static NSString *PLAN = @"cs:plan";
static NSString *TIME = @"cs:time";
static NSString *ROUTEDATE = @"cs:whence";
 */

@implementation RouteVO
@synthesize segments;
@synthesize routeid;
@synthesize northEast;
@synthesize southWest;
@synthesize name;
@synthesize speed;
@synthesize length;
@synthesize plan;
@synthesize time;
@synthesize date;
@synthesize userRouteName;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [segments release], segments = nil;
    [routeid release], routeid = nil;
    [northEast release], northEast = nil;
    [southWest release], southWest = nil;
    [name release], name = nil;
    [length release], length = nil;
    [plan release], plan = nil;
    [date release], date = nil;
    [userRouteName release], userRouteName = nil;
	
    [super dealloc];
}






- (SegmentVO *) segmentAtIndex:(int)index {
	return [segments objectAtIndex:index];
}

//
/***********************************************
 * @description			getters
 ***********************************************/
//

- (int) numSegments {
	return [segments count];
}

- (NSString *) nameString {
	
	if(userRouteName==nil || [userRouteName isEqualToString:EMPTYSTRING]){
		return name;
	}else{
		return userRouteName;
	}
}


-(NSString*)timeString{
	
	NSUInteger h = [self time] / 3600;
	NSUInteger m = ([self time] / 60) % 60;
	NSUInteger s = [self time] % 60;
	
	if ([self time]>3600) {
		return [NSString stringWithFormat:@"%02d:%02d:%02d", h,m,s];
	}else {
		return [NSString stringWithFormat:@"%02d:%02d", m,s];
	}
}

-(NSString*)lengthString{
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		float totalMiles = [[self length] floatValue]/1600;
		return [NSString stringWithFormat:@"%3.1f miles", totalMiles];
	}else {
		float	kms=[[self length] floatValue]/1000;
		return [NSString stringWithFormat:@"%4.1f km", kms];
	}
	
	
}

-(NSString*)speedString{
	
	NSNumber *kmSpeed = [NSNumber numberWithInteger:[self speed]];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES) {
		NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
		return [NSString stringWithFormat:@"%2d mph", mileSpeed];
	}else {
		return [NSString stringWithFormat:@"%@ km/h", kmSpeed];
	}
}

-(NSString*)dateString{
	
	NSDate *newdate=[NSDate dateFromString:[self date] withFormat:@"y-MM-dd HH:mm:ss"];		
	return [NSDate stringFromDate:newdate withFormat:@"eee d MMMM y HH:mm"];
	
}

-(NSString*)planString{
	
	return [[self plan] capitalizedString];
	
}


//
/***********************************************
 * @description			CL getters: note use of CLLocation so NSCoding is optimised.
 ***********************************************/
//

- (CLLocationCoordinate2D) basicNorthEast {
	CLLocationCoordinate2D location;
	location.latitude = northEast.coordinate.latitude;
	location.longitude = northEast.coordinate.longitude;
	return location;
}

- (CLLocationCoordinate2D) basicSouthWest {
	CLLocationCoordinate2D location;
	location.latitude = southWest.coordinate.latitude;
	location.longitude = southWest.coordinate.longitude;
	return location;	
}

- (CLLocationCoordinate2D) insetNorthEast {
	CLLocationCoordinate2D location;
	location.latitude = northEast.coordinate.latitude+0.002;
	location.longitude = northEast.coordinate.longitude+0.002;
	return location;
}

- (CLLocationCoordinate2D) insetSouthWest {
	CLLocationCoordinate2D location;
	location.latitude = southWest.coordinate.latitude-0.002;
	location.longitude = southWest.coordinate.longitude-0.002;
	return location;	
}



//
/***********************************************
 * @description			NSCODING
 ***********************************************/
//


static NSString *SEGMENTS = @"segments";
static NSString *ITINERARY = @"itinerary";
static NSString *NORTH_EAST = @"northEast";
static NSString *SOUTH_WEST = @"southWest";
static NSString *NAME = @"name";
static NSString *SPEED = @"speed";
static NSString *LENGTH = @"length";
static NSString *PLAN = @"plan";
static NSString *TIME = @"time";
static NSString *ROUTEDATE = @"routedate";
static NSString *USER_ROUTE_NAME = @"userRouteName";



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.segments forKey:SEGMENTS];
    [encoder encodeObject:self.routeid forKey:ITINERARY];
    [encoder encodeObject:self.northEast forKey:NORTH_EAST];
    [encoder encodeObject:self.southWest forKey:SOUTH_WEST];
    [encoder encodeObject:self.name forKey:NAME];
    [encoder encodeInteger:self.speed forKey:SPEED];
    [encoder encodeObject:self.length forKey:LENGTH];
    [encoder encodeObject:self.plan forKey:PLAN];
    [encoder encodeInteger:self.time forKey:TIME];
    [encoder encodeObject:self.date forKey:ROUTEDATE];
    [encoder encodeObject:self.userRouteName forKey:USER_ROUTE_NAME];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.segments = [decoder decodeObjectForKey:SEGMENTS];
        self.routeid = [decoder decodeObjectForKey:ITINERARY];
        self.northEast = [decoder decodeObjectForKey:NORTH_EAST];
        self.southWest = [decoder decodeObjectForKey:SOUTH_WEST];
        self.name = [decoder decodeObjectForKey:NAME];
        self.speed = [decoder decodeIntegerForKey:SPEED];
        self.length = [decoder decodeObjectForKey:LENGTH];
        self.plan = [decoder decodeObjectForKey:PLAN];
        self.time = [decoder decodeIntegerForKey:TIME];
        self.date = [decoder decodeObjectForKey:ROUTEDATE];
        self.userRouteName = [decoder decodeObjectForKey:USER_ROUTE_NAME];
    }
    return self;
}

@end
