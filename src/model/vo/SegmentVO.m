//
//  SegmentVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 24/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SegmentVO.h"
#import "CSPointVO.h"

static NSDictionary *roadIcons;

@implementation SegmentVO
@synthesize roadName;
@synthesize provisionName;
@synthesize turnType;
@synthesize segmentTime;
@synthesize segmentDistance;
@synthesize startBearing;
@synthesize segmentBusynance;
@synthesize startTime;
@synthesize startDistance;
@synthesize pointsArray;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [roadName release], roadName = nil;
    [provisionName release], provisionName = nil;
    [turnType release], turnType = nil;
    [pointsArray release], pointsArray = nil;
	
    [super dealloc];
}









//
/***********************************************
 * @description			getters
 ***********************************************/
//


-(NSString*)timeString{
	
	NSUInteger h = startTime / 3600;
	NSUInteger m = (startTime / 60) % 60;
	NSUInteger s = startTime % 60;
	
	if (startTime>3600) {
		return [NSString stringWithFormat:@"%02d:%02d:%02d", h,m,s];
	}else {
		return [NSString stringWithFormat:@"%02d:%02d", m,s];
	}
}





//
/***********************************************
 * @description			Utility
 ***********************************************/
//



//return array of points, in lat/lon.
- (NSArray *)allPoints {
	
	return pointsArray;

}

- (CLLocationCoordinate2D)segmentStart {
	CSPointVO *point=[pointsArray objectAtIndex:0];
	return [point  coordinate];
}

- (CLLocationCoordinate2D)segmentEnd {
	return [(CSPointVO*)[pointsArray objectAtIndex:[pointsArray count]-1] coordinate];
}

+ (NSString *)provisionIcon:(NSString *)provisionName {
	
	if (nil == roadIcons) {
		//TODO the association of symbols to types could be improved
		roadIcons = [[NSDictionary dictionaryWithObjectsAndKeys:
					  @"UIIcon_roads.png", @"busy road", 
					  @"UIIcon_roads.png", @"road", 
					  @"UIIcon_roads.png", @"busy and fast road", 
					  @"UIIcon_roads.png", @"secondary",
					  @"UIIcon_roads.png", @"major road",
					  @"UIIcon_roads.png", @"main road",
					  @"UIIcon_roads.png", @"unclassified road",
					  @"UIIcon_minor_roads.png", @"minor road",
					  @"UIIcon_minor_roads.png", @"service road",
					  @"UIIcon_footpaths.png", @"footpath", 
					  @"UIIcon_footpaths.png", @"footway", 
					  @"UIIcon_footpaths.png", @"pedestrian",
					  @"UIIcon_footpaths.png", @"steps with channel", 
					  @"UIIcon_cycle_lanes.png", @"unsegregated shared use", 
					  @"UIIcon_cycle_lanes.png", @"narrow cycle lane", 
					  @"UIIcon_cycle_lanes.png", @"cycle lane", 
					  @"UIIcon_cycle_tracks.png", @"cycle track", 
					  @"UIIcon_cycle_tracks.png", @"cycle path", 
					  @"UIIcon_tracks.png", @"track", 
					  @"UIIcon_tracks.png", @"bridleway", 
					  @"UIIcon_quiet_street.png", @"quiet street",
					  @"UIIcon_quiet_street.png", @"residential street",
					  @"UIIcon_quiet_street.png", @"unclassified, service", // need icon for this
					  @"UIIcon_quiet_street.png", @"unclassified,service",
					  nil] retain];
	}
	
	return [roadIcons valueForKey:provisionName];
}



- (NSString *) infoString {
	NSString *hm = [self timeString];
	NSString *distance = [NSString stringWithFormat:@"%4dm", [self segmentDistance]];
	float totalMiles = ((float)([self startDistance]+[self segmentDistance]))/1600;
	NSString *total = [NSString stringWithFormat:@"(%3.1f miles)", totalMiles];
	
	NSArray *turnParts = [[self turnType] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *capitalizedTurn = @"";
	for (NSString *string in turnParts) {
		if ([capitalizedTurn length] == 0) {
			capitalizedTurn = [string capitalizedString];
		} else {
			capitalizedTurn = [capitalizedTurn stringByAppendingFormat:@" %@", string];
		}
	}
	if ([turnParts count] ==0 || [capitalizedTurn isEqualToString:@"Unknown"]) {
		return [NSString stringWithFormat:@"%@\n(%@)\n%@  %@  %@",
				[self roadName],
				[self provisionName],
				hm, distance, total];		
	} else {
		return [NSString stringWithFormat:@"%@, %@\n(%@)\n%@  %@  %@",
				capitalizedTurn,
				[self roadName],
				[self provisionName],
				hm, distance, total];
	}
}

-(NSDictionary*)infoStringDictionary{
	
	NSString *hm = [self timeString];
	NSString *distance = [NSString stringWithFormat:@"%im", [self segmentDistance]];
	float totalMiles = ((float)([self startDistance]+[self segmentDistance]))/1600;
	NSString *total = [NSString stringWithFormat:@"%3.1f miles", totalMiles];
	
	NSArray *turnParts = [[self turnType] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *capitalizedTurn = @"";
	for (NSString *string in turnParts) {
		if ([capitalizedTurn length] == 0) {
			capitalizedTurn = [string capitalizedString];
		} else {
			capitalizedTurn = [capitalizedTurn stringByAppendingFormat:@" %@", string];
		}
	}
	
	NSString *provisionstring=[[self provisionName] stringByReplacingOccurrencesOfString:@"," withString:@", "];
	
	if ([turnParts count] ==0 || [capitalizedTurn isEqualToString:@"Unknown"]) {
		
		return [NSDictionary dictionaryWithObjectsAndKeys:[self roadName],@"roadname",
				provisionstring,@"provisionName",
				hm,@"hm",distance,@"distance",total,@"total",nil];
	} else {
		
		return [NSDictionary dictionaryWithObjectsAndKeys:capitalizedTurn,@"capitalizedTurn",
				[self roadName],@"roadname",
				provisionstring,@"provisionName",
				hm,@"hm",distance,@"distance",total,@"total",nil];
	}
	
}



static NSString *ROAD_NAME = @"roadName";
static NSString *PROVISION_NAME = @"provisionName";
static NSString *TURN_TYPE = @"turnType";
static NSString *SEGMENT_TIME = @"segmentTime";
static NSString *SEGMENT_DISTANCE = @"segmentDistance";
static NSString *START_BEARING = @"startBearing";
static NSString *SEGMENT_BUSYNANCE = @"segmentBusynance";
static NSString *START_TIME = @"startTime";
static NSString *START_DISTANCE = @"startDistance";
static NSString *POINTS_ARRAY = @"pointsArray";



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.roadName forKey:ROAD_NAME];
    [encoder encodeObject:self.provisionName forKey:PROVISION_NAME];
    [encoder encodeObject:self.turnType forKey:TURN_TYPE];
    [encoder encodeInteger:self.segmentTime forKey:SEGMENT_TIME];
    [encoder encodeInteger:self.segmentDistance forKey:SEGMENT_DISTANCE];
    [encoder encodeInteger:self.startBearing forKey:START_BEARING];
    [encoder encodeInteger:self.segmentBusynance forKey:SEGMENT_BUSYNANCE];
    [encoder encodeInteger:self.startTime forKey:START_TIME];
    [encoder encodeInteger:self.startDistance forKey:START_DISTANCE];
    [encoder encodeObject:self.pointsArray forKey:POINTS_ARRAY];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.roadName = [decoder decodeObjectForKey:ROAD_NAME];
        self.provisionName = [decoder decodeObjectForKey:PROVISION_NAME];
        self.turnType = [decoder decodeObjectForKey:TURN_TYPE];
        self.segmentTime = [decoder decodeIntegerForKey:SEGMENT_TIME];
        self.segmentDistance = [decoder decodeIntegerForKey:SEGMENT_DISTANCE];
        self.startBearing = [decoder decodeIntegerForKey:START_BEARING];
        self.segmentBusynance = [decoder decodeIntegerForKey:SEGMENT_BUSYNANCE];
        self.startTime = [decoder decodeIntegerForKey:START_TIME];
        self.startDistance = [decoder decodeIntegerForKey:START_DISTANCE];
        self.pointsArray = [decoder decodeObjectForKey:POINTS_ARRAY];
    }
    return self;
}



@end
