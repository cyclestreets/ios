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

//  Segment.m
//  CycleStreets
//
//  Created by Alan Paxton on 04/03/2010.
//

#import "SegmentVO.h"
#import "CSPoint.h"

@implementation SegmentVO

static NSDictionary *roadIcons;

@synthesize startTime;
@synthesize startDistance;

- (id) initWithDictionary:(NSDictionary *)dictionary atTime:(NSInteger)time atDistance:(NSInteger)distance {
	if (self = [super init]) {
		xmlDict = dictionary;
		[xmlDict retain];
		startTime = time;
		startDistance = distance;
	}
	return self;
}

- (NSString *)roadName {
	return [xmlDict valueForKey:@"cs:name"];
}

- (NSInteger)segmentTime {
	return [[xmlDict valueForKey:@"cs:time"] intValue];
}

- (NSInteger)segmentDistance {
	return [[xmlDict valueForKey:@"cs:distance"] intValue];
}

- (NSInteger)startBearing {
	return [[xmlDict valueForKey:@"cs:startBearing"] intValue];
}

- (NSInteger)segmentBusynance {
	return [[xmlDict valueForKey:@"cs:busynance"] intValue];
}

- (NSString *)provisionName {
	return [xmlDict valueForKey:@"cs:provisionName"];
}

- (NSString *)turn {
	return [xmlDict valueForKey:@"cs:turn"];
}

- (CLLocationCoordinate2D)point:(BOOL)first {
	CLLocationCoordinate2D location;
	NSCharacterSet *whiteComma = [NSCharacterSet characterSetWithCharactersInString:@", "];
	NSArray *XYs = [[xmlDict valueForKey:@"cs:points"] componentsSeparatedByCharactersInSet:whiteComma];
	int index = 0;
	if (!first) {
		index = [XYs count] - 2;
	}
	location.longitude = [[XYs objectAtIndex:index] doubleValue];
	location.latitude = [[XYs objectAtIndex:index+1] doubleValue];
	return location;
}

//return array of points, in lat/lon.
- (NSArray *)allPoints {
	NSCharacterSet *whiteComma = [NSCharacterSet characterSetWithCharactersInString:@", "];
	NSArray *XYs = [[xmlDict valueForKey:@"cs:points"] componentsSeparatedByCharactersInSet:whiteComma];
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	for (int X = 0; X < [XYs count]; X += 2) {
		CSPoint *p = [[[CSPoint alloc] init] autorelease];
		CGPoint point;
		point.x = [[XYs objectAtIndex:X] doubleValue];
		point.y = [[XYs objectAtIndex:X+1] doubleValue];
		p.p = point;
		[result addObject:p];
	}
	return result;
}

- (CLLocationCoordinate2D)segmentStart {
	return [self point:YES];
}

- (CLLocationCoordinate2D)segmentEnd {
	return [self point:NO];
}

+ (NSString *)provisionIcon:(NSString *)provisionName {
	if (nil == roadIcons) {
		//TODO the association of symbols to types could be improved
		roadIcons = [[NSDictionary dictionaryWithObjectsAndKeys:
					  @"UIIcon_roads.png", @"Service Road", 
					  @"UIIcon_roads.png", @"Busy Road", 
					  @"UIIcon_roads.png", @"Road", 
					  @"UIIcon_roads.png", @"Busy and fast road", 
					  @"UIIcon_roads.png", @"secondary",
					  @"UIIcon_footpaths.png", @"Footpath", 
					  @"UIIcon_footpaths.png", @"footway", 
					  @"UIIcon_footpaths.png", @"pedestrian",
					  @"UIIcon_footpaths.png", @"Steps with Channel", 
					  @"UIIcon_cycle_lanes.png", @"Unsegregated Shared Use", 
					  @"UIIcon_cycle_lanes.png", @"Narrow Cycle Lane", 
					  @"UIIcon_cycle_lanes.png", @"Cycle Lane", 
					  @"UIIcon_cycle_tracks.png", @"Cycle Track", 
					  @"UIIcon_tracks.png", @"Track", 
					  @"UIIcon_tracks.png", @"bridleway", 
					  @"UIIcon_quiet_street.png", @"Quiet Street",
					  @"UIIcon_quiet_street.png", @"unclassified, service", // need icon for this
					  @"UIIcon_quiet_street.png", @"unclassified,service",
					 nil] retain];
	}
	return [roadIcons valueForKey:provisionName];
}

/*
 * Used to set table view cell and Stage view, which have been set up to share UI fields of the same name.
 */
- (void) setUIElements:(NSObject *)view/*or controller*/ {
	[view setValue:[self roadName] forKeyPath:@"road.text"];
	[view setValue:[NSString stringWithFormat:@"%02d:%02d", startTime/60, startTime%60] forKeyPath:@"time.text"];
	[view setValue:[NSString stringWithFormat:@"%4dm", [self segmentDistance]] forKeyPath:@"distance.text"];
	float totalMiles = ((float)([self startDistance]+[self segmentDistance]))/1600;
	[view setValue:[NSString stringWithFormat:@"(%3.1f miles)", totalMiles] forKeyPath:@"total.text"];
	NSString *imageName = [SegmentVO provisionIcon:[self provisionName]];
	[view setValue:[UIImage imageNamed:imageName] forKeyPath:@"image.image"];
	if ([view respondsToSelector:@selector(setBusyness:)]) {
		[view setValue:[self provisionName] forKeyPath:@"busyness.text"];
	}
	if ([view respondsToSelector:@selector(setTurn:)]) {
		[view setValue:[self turn] forKeyPath:@"turn.text"];
	}
}

- (NSString *) infoString {
	NSString *hm = [NSString stringWithFormat:@"%02d:%02d", startTime/60, startTime%60];
	NSString *distance = [NSString stringWithFormat:@"%4dm", [self segmentDistance]];
	float totalMiles = ((float)([self startDistance]+[self segmentDistance]))/1600;
	NSString *total = [NSString stringWithFormat:@"(%3.1f miles)", totalMiles];
	
	NSArray *turnParts = [[self turn] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
	
	NSString *hm = [NSString stringWithFormat:@"%02d:%02d", startTime/60, startTime%60];
	NSString *distance = [NSString stringWithFormat:@"%im", [self segmentDistance]];
	float totalMiles = ((float)([self startDistance]+[self segmentDistance]))/1600;
	NSString *total = [NSString stringWithFormat:@"%3.1f miles", totalMiles];
	
	NSArray *turnParts = [[self turn] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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



- (void) dealloc {
	[xmlDict release];
	
	[super dealloc];
}

@end
