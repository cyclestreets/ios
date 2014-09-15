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

@interface RouteVO : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray              * segments;
@property (nonatomic, strong) NSString                    * routeid;
@property (nonatomic, strong) CLLocation                  * northEast;
@property (nonatomic, strong) CLLocation                  * southWest;
@property (nonatomic, strong) NSString                    * name;
@property (nonatomic, assign) NSInteger                   speed;
@property (nonatomic, strong) NSNumber                    * length;
@property (nonatomic, strong) NSString                    * plan;
@property (nonatomic, assign) NSInteger                   time;
@property (nonatomic, strong) NSString                    * date;
@property (nonatomic, strong) NSString                    * userRouteName;
@property (nonatomic, strong) NSString                    * calorie;
@property (nonatomic, strong) NSString                    * cosaved;

@property (nonatomic, strong) NSMutableArray              * waypoints;


//   getters
@property (nonatomic, readonly)	NSString				  * timeString;
@property (nonatomic, readonly)	NSString                  * lengthString;
@property (nonatomic, readonly)	NSString                  * speedString;
@property (nonatomic, readonly)	NSString                  * dateString;
@property (nonatomic, readonly)	NSString                  * dateOnlyString;
@property (nonatomic, readonly)	NSString                  * planString;
@property (nonatomic, readonly)	NSString                  * nameString;
@property (nonatomic, readonly)	NSString                  * calorieString;
@property (nonatomic, readonly)	NSString                  * coString;

@property (nonatomic, readonly)	NSInteger					numSegments;
@property (nonatomic, readonly)	NSInteger                       coordCount;
@property (nonatomic, readonly)	CLLocationCoordinate2D    basicNorthEast;
@property (nonatomic, readonly)	CLLocationCoordinate2D    basicSouthWest;
@property (nonatomic, readonly)	CLLocationCoordinate2D    insetNorthEast;
@property (nonatomic, readonly)	CLLocationCoordinate2D    insetSouthWest;

@property (nonatomic, readonly)	NSString                  * fileid;
@property (nonatomic, readonly)	BOOL                      containsWalkingSections;

@property (nonatomic, readonly)	BOOL                      hasWaypoints;

@property (nonatomic, readonly)	int										maxElevation;
@property (nonatomic, readonly)	int										elevationsCount;
@property (nonatomic, readonly)	BOOL									hasElevationData;



@property (nonatomic, readonly)	NSURL                     * csrouteurl;
@property (nonatomic, readonly)	NSString                  * csBrowserRouteurlString;
@property (nonatomic, readonly)	NSString                  * csiOSRouteurlString;


@property (nonatomic, readonly)	NSDate                    * dateObject;


- (SegmentVO *) segmentAtIndex:(NSInteger)index;
-(NSMutableArray*)createCorrectedWaypointArray;

// returns max bounding locations for self compared to location
-(CLLocationCoordinate2D)maxSouthWestForLocation:(CLLocation*)comparelocation;
-(CLLocationCoordinate2D)maxNorthEastForLocation:(CLLocation*)comparelocation;

-(NSString*)lengthPercentStringForPercent:(float)percent;

@end


