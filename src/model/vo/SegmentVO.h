//
//  SegmentVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 24/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SegmentVO : NSObject <NSCoding>{
	
	NSString			*roadName;
	NSString			*provisionName;
	NSString			*turnType;
	
	NSInteger			segmentTime;
	NSInteger			segmentDistance;
	NSInteger			startBearing;
	NSInteger			segmentBusynance;
	
	
	NSInteger			startTime;
	NSInteger			startDistance;
	
	NSArray				*pointsArray; // array of points in 2d groups
	
	
}
@property (nonatomic, retain)	NSString		*roadName;
@property (nonatomic, retain)	NSString		*provisionName;
@property (nonatomic, retain)	NSString		*turnType;
@property (nonatomic)	NSInteger		segmentTime;
@property (nonatomic)	NSInteger		segmentDistance;
@property (nonatomic)	NSInteger		startBearing;
@property (nonatomic)	NSInteger		segmentBusynance;
@property (nonatomic)	NSInteger		startTime;
@property (nonatomic)	NSInteger		startDistance;
@property (nonatomic, retain)	NSArray		*pointsArray;


@property (nonatomic, readonly)	NSString	*timeString;
@property (nonatomic, readonly)	CLLocationCoordinate2D	segmentStart;
@property (nonatomic, readonly)	CLLocationCoordinate2D	segmentEnd;


// return array of allpoints for this segment
- (NSArray *)allPoints;


- (NSString *) infoString;
-(NSDictionary*)infoStringDictionary;



+ (NSString *)provisionIcon:(NSString *)provisionName;


@end

