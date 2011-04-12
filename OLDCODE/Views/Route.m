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

//  Route.m
//  CycleStreets
//
//  Created by Alan Paxton on 03/03/2010.
//

#import "Route.h"
#import "SegmentVO.h"
#import "SettingsManager.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "NSDate+Helper.h"

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

@implementation Route

- (id) initWithElements:(NSDictionary *)elements {
	if (self = [super init]) {
		segments = [[NSMutableArray alloc] init];
		NSInteger time = 0;
		NSInteger distance = 0;
		for (NSDictionary *segmentDictionary in [elements objectForKey:SEGMENT_ELEMENT]) {
			SegmentVO *segment = [[SegmentVO alloc] initWithDictionary:segmentDictionary atTime:time atDistance:distance];
			[segments addObject:segment];
			time += [segment segmentTime];
			distance += [segment segmentDistance];
			[segment release];
		}
		NSArray *routeElements = [elements objectForKey:ROUTE_ELEMENT];
		NSDictionary *value = [[[NSDictionary alloc] init] autorelease];
		if ([routeElements count] > 0) {
			value = [[elements objectForKey:ROUTE_ELEMENT] objectAtIndex:0];
		}
		header = [[NSDictionary dictionaryWithDictionary:value] retain];																				 
	}
	return self;
}

+ (NSArray *) routeXMLElementNames {
	return [[[NSArray alloc] initWithObjects:ROUTE_ELEMENT, SEGMENT_ELEMENT, nil] autorelease];
}

- (int) numSegments {
	return [segments count];
}

- (SegmentVO *) segmentAtIndex:(int)index {
	return [segments objectAtIndex:index];
}

// We previously had a String which was numeric.
// Fake one up from the name.
/*
- (NSString *) routeIdentifier {
	NSString *name = [header valueForKey:NAME];
	if (name == nil) {
		return nil;
	}
	NSInteger sum = 0;
	for (int i = 0; i < [name length]; i++) {
		sum += [name characterAtIndex:i];
	}
	return [[NSNumber numberWithInt:sum] stringValue];
}
 */

- (CLLocationCoordinate2D) northEast {
	CLLocationCoordinate2D location;
	location.latitude = [[header valueForKey:NORTH] doubleValue];
	location.longitude = [[header valueForKey:EAST] doubleValue];
	return location;
}

- (CLLocationCoordinate2D) southWest {
	CLLocationCoordinate2D location;
	location.latitude = [[header valueForKey:SOUTH] doubleValue];
	location.longitude = [[header valueForKey:WEST] doubleValue];
	return location;	
}

- (NSString *) name {
	return [header valueForKey:NAME];
}

- (NSString *) itinerary {
	return [header valueForKey:ITINERARY];
}

- (NSInteger) speed {
	return [[header valueForKey:SPEED] intValue];
}

- (NSNumber *) length {
	return [NSNumber numberWithFloat:[[header valueForKey:LENGTH] floatValue]];
}

- (NSInteger) time {
	return [[header valueForKey:TIME] intValue];
}

- (NSString *) plan {
	return [header valueForKey:PLAN];
}


- (NSString *) date {
	return [header valueForKey:ROUTEDATE];
}



//
/***********************************************
 * @description			getters
 ***********************************************/
//


-(NSString*)timeString{
	return [NSString stringWithFormat:@"%02d:%02d", [self time]/60, [self time]%60];
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
		return [NSString stringWithFormat:@"%@ Km", kmSpeed];
	}
}

-(NSString*)dateString{
	
	NSDate *newdate=[NSDate dateFromString:[self date] withFormat:@"y-MM-dd HH:mm:ss"];		
	return [NSDate stringFromDate:newdate withFormat:@"eeee d MMMM y HH:mm"];
	
}


/*
 * Used to set table view cell and potentially other views, which have been set up to share UI fields of the same name.
 */
- (void) setUIElements:(NSObject *)view/*or controller*/ {
	[view setValue:[self name] forKeyPath:@"name.text"];
	[view setValue:[NSString stringWithFormat:@"%02d:%02d", [self time]/60, [self time]%60] forKeyPath:@"time.text"];
	[view setValue:[NSString stringWithFormat:@"%3.1f miles", [[self length] floatValue]/1600] forKeyPath:@"length.text"];
	[view setValue:[self plan] forKeyPath:@"plan.text"];
	NSNumber *kmSpeed = [NSNumber numberWithInteger:[self speed]];
	NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
	[view setValue:[NSString stringWithFormat:@"%2d mph", mileSpeed] forKeyPath:@"speed.text"];
	[view setValue:[UIImage imageNamed:@"mm_15_directional_signage.png"] forKeyPath:@"icon.image"];
	
	
	//[view setValue:[ forKeyPath:@"dateLabel.text"];
}

- (void) dealloc {
	[segments release];
	[header release];
	
	[super dealloc];
}

@end
