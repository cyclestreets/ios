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
@property (nonatomic, retain)	NSMutableArray		*segments;
@property (nonatomic, retain)	NSString		*routeid;
@property (nonatomic, retain)	CLLocation		*northEast;
@property (nonatomic, retain)	CLLocation		*southWest;
@property (nonatomic, retain)	NSString		*name;
@property (nonatomic)	NSInteger		speed;
@property (nonatomic, retain)	NSNumber		*length;
@property (nonatomic, retain)	NSString		*plan;
@property (nonatomic)	NSInteger		time;
@property (nonatomic, retain)	NSString		*date;
@property (nonatomic, retain)	NSString		*userRouteName;

// getters
@property (nonatomic, readonly)	NSString	*timeString;
@property (nonatomic, readonly)	NSString	*lengthString;
@property (nonatomic, readonly)	NSString	*speedString;
@property (nonatomic, readonly)	NSString	*dateString;
@property (nonatomic, readonly)	NSString	*dateOnlyString;
@property (nonatomic, readonly)	NSString	*planString;
@property (nonatomic, readonly)	NSString	*nameString;
@property (nonatomic, readonly)	int					numSegments;
@property (nonatomic, readonly)	CLLocationCoordinate2D					basicNorthEast;
@property (nonatomic, readonly)	CLLocationCoordinate2D					basicSouthWest;
@property (nonatomic, readonly)	CLLocationCoordinate2D					insetNorthEast;
@property (nonatomic, readonly)	CLLocationCoordinate2D					insetSouthWest;



- (SegmentVO *) segmentAtIndex:(int)index;


@end


