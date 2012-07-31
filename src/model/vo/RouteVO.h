//
//  RouteVO.h
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

// new NScoding compliant RouteVO, use in conjunction with new XMLParser logic only

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SegmentVO.h"

@interface RouteVO : NSObject <NSCoding>{
	
	NSMutableArray			*segments;
	NSString				*routeid; // this is itineary in old VO
	
	CLLocation				*northEast;
	CLLocation				*southWest;
	
	NSString				*name;
	NSInteger				speed;
	NSNumber				*length;
	NSString				*plan;
	NSInteger				time;
	NSString				*date;
	NSString				*userRouteName; // user editable route name, displayed if set
	
}
@property (nonatomic, strong)	NSMutableArray		*segments;
@property (nonatomic, strong)	NSString		*routeid;
@property (nonatomic, strong)	CLLocation		*northEast;
@property (nonatomic, strong)	CLLocation		*southWest;
@property (nonatomic, strong)	NSString		*name;
@property (nonatomic)	NSInteger		speed;
@property (nonatomic, strong)	NSNumber		*length;
@property (nonatomic, strong)	NSString		*plan;
@property (nonatomic)	NSInteger		time;
@property (nonatomic, strong)	NSString		*date;
@property (nonatomic, strong)	NSString		*userRouteName;

// getters
@property (unsafe_unretained, nonatomic, readonly)	NSString	*timeString;
@property (unsafe_unretained, nonatomic, readonly)	NSString	*lengthString;
@property (unsafe_unretained, nonatomic, readonly)	NSString	*speedString;
@property (unsafe_unretained, nonatomic, readonly)	NSString	*dateString;
@property (unsafe_unretained, nonatomic, readonly)	NSString	*dateOnlyString;
@property (unsafe_unretained, nonatomic, readonly)	NSString	*planString;
@property (unsafe_unretained, nonatomic, readonly)	NSString	*nameString;
@property (nonatomic, readonly)	int					numSegments;
@property (nonatomic, readonly)	CLLocationCoordinate2D					basicNorthEast;
@property (nonatomic, readonly)	CLLocationCoordinate2D					basicSouthWest;
@property (nonatomic, readonly)	CLLocationCoordinate2D					insetNorthEast;
@property (nonatomic, readonly)	CLLocationCoordinate2D					insetSouthWest;

@property (unsafe_unretained, nonatomic, readonly)	NSString	*fileid;

@property (nonatomic, readonly)	NSDate							*dateObject;


- (SegmentVO *) segmentAtIndex:(int)index;

// returns max bounding locations for self compared to location
-(CLLocationCoordinate2D)maxSouthWestForLocation:(CLLocation*)comparelocation;
-(CLLocationCoordinate2D)maxNorthEastForLocation:(CLLocation*)comparelocation;


@end


