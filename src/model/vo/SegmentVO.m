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

@interface SegmentVO()

@property(nonatomic,strong)  NSDictionary			*stringDictionary;


@end

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
@synthesize walkValue;
@synthesize elevations;




- (id)init {
    if (self = [super init]) {
		
    }
    return self;
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


+(NSString*)provisionIconForType:(NSString*)type isWalking:(int)walking{
	
	if(walking==1){
		
		return @"UIIcon_walking.png";
		
	}else{
		return [SegmentVO iconForType:[type lowercaseString]];
	}
	
}

- (NSString *)provisionIcon {
	
	if([self isWalkingSection]==YES){
		
		return @"UIIcon_walking.png";
		
	}else{
		return [SegmentVO iconForType:[self.provisionName lowercaseString]];
	}
	
}

+(NSString*)iconForType:(NSString*)type{
	
	if (nil == roadIcons) {
		//TODO the association of symbols to types could be improved
		roadIcons = [NSDictionary dictionaryWithObjectsAndKeys:
					 @"UIIcon_roads.png", @"busy road",
					 @"UIIcon_roads.png", @"road",
					 @"UIIcon_roads.png", @"busy and fast road",
					 @"UIIcon_roads.png", @"secondary",
					 @"UIIcon_roads.png", @"major road",
					 @"UIIcon_roads.png", @"trunk road",
					 @"UIIcon_roads.png", @"main road",
					 @"UIIcon_roads.png", @"unclassified road",
					 @"UIIcon_minor_roads.png", @"minor road",
					 @"UIIcon_minor_roads.png", @"service road",
					 @"UIIcon_footpaths.png", @"footpath",
					 @"UIIcon_footpaths.png", @"footway",
					 @"UIIcon_footpaths.png", @"pedestrian",
					 @"UIIcon_footpaths.png", @"pedestrianized area",
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
					 nil];
	}
	
	return [roadIcons valueForKey:type];
	
	
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


-(void)populateStringDictionary{
	
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
		
		_stringDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[self roadName],@"roadname",
				provisionstring,@"provisionName",
				hm,@"hm",distance,@"distance",total,@"total",nil];
	} else {
		
		_stringDictionary=[NSDictionary dictionaryWithObjectsAndKeys:capitalizedTurn,@"capitalizedTurn",
				[self roadName],@"roadname",
				provisionstring,@"provisionName",
				hm,@"hm",distance,@"distance",total,@"total",nil];
	}
	
	
}

-(NSDictionary*)infoStringDictionary{
	
	if(_stringDictionary==nil)
		[self populateStringDictionary];
	
	return _stringDictionary;
	
}



-(BOOL)isWalkingSection{
	return walkValue==1;
}





-(int)segmentElevation{
	
	NSMutableArray *earray=[[elevations componentsSeparatedByString:@","] mutableCopy];
	
	if(earray.count>1){
		
		[earray removeLastObject];
		for(int i=0;i<earray.count;i++){
			NSString *str=earray[i];
			int value=[str intValue];
			[earray replaceObjectAtIndex:i withObject:@(value)];
		}
		
		return [[earray valueForKeyPath:@"@avg.self"] intValue];
	}else{
		return [earray[0] intValue];
	}
}




//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.roadName forKey:@"roadName"];
    [encoder encodeObject:self.provisionName forKey:@"provisionName"];
    [encoder encodeObject:self.turnType forKey:@"turnType"];
    [encoder encodeInteger:self.walkValue forKey:@"walkValue"];
    [encoder encodeInteger:self.segmentTime forKey:@"segmentTime"];
    [encoder encodeInteger:self.segmentDistance forKey:@"segmentDistance"];
    [encoder encodeInteger:self.startBearing forKey:@"startBearing"];
    [encoder encodeInteger:self.segmentBusynance forKey:@"segmentBusynance"];
    [encoder encodeObject:self.elevations forKey:@"elevations"];
    [encoder encodeInteger:self.startTime forKey:@"startTime"];
    [encoder encodeInteger:self.startDistance forKey:@"startDistance"];
    [encoder encodeObject:self.pointsArray forKey:@"pointsArray"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.roadName = [decoder decodeObjectForKey:@"roadName"];
        self.provisionName = [decoder decodeObjectForKey:@"provisionName"];
        self.turnType = [decoder decodeObjectForKey:@"turnType"];
        self.walkValue = [decoder decodeIntegerForKey:@"walkValue"];
        self.segmentTime = [decoder decodeIntegerForKey:@"segmentTime"];
        self.segmentDistance = [decoder decodeIntegerForKey:@"segmentDistance"];
        self.startBearing = [decoder decodeIntegerForKey:@"startBearing"];
        self.segmentBusynance = [decoder decodeIntegerForKey:@"segmentBusynance"];
        self.elevations = [decoder decodeObjectForKey:@"elevations"];
        self.startTime = [decoder decodeIntegerForKey:@"startTime"];
        self.startDistance = [decoder decodeIntegerForKey:@"startDistance"];
        self.pointsArray = [decoder decodeObjectForKey:@"pointsArray"];
    }
    return self;
}


@end
