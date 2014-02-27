//
//  CSRoutePolyLineOverlay.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSRoutePolyLineOverlay.h"
#import "RouteVO.h"
#import "CSPointVO.h"
#import "Segment.h"
#import "GlobalUtilities.h"

#import <pthread.h>

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 1.0

@interface CSRoutePolyLineOverlay()


@property (nonatomic,assign) MKMapPoint	*points;
@property (nonatomic,assign) NSUInteger pointCount;


@end


@implementation CSRoutePolyLineOverlay





+(CLLocationCoordinate2D*)coordinatesForRoute:(RouteVO*)route fromMap:(MKMapView *)mapView{
	
	CLLocationCoordinate2D *points = malloc(sizeof(CLLocationCoordinate2D) * [route coordCount]);
		
	int count=0;
	for (int i = 0; i < [route numSegments]; i++) {
		
		if (i == 0){
			// start of first segment
			//CSPointVO *p = [[CSPointVO alloc] init];
			SegmentVO *segment = [route segmentAtIndex:i];
			CLLocationCoordinate2D pointcoordinate = [segment segmentStart];
			//CGPoint pt = [mapView convertCoordinate:pointcoordinate toPointToView:mapView];
			//p.p = pt;
			//p.isWalking=segment.isWalkingSection;
			
			NSLog(@"%lf,%lf,%f",pointcoordinate.latitude,pointcoordinate.longitude, [GlobalUtilities randomFloatBetween:0.1f and:12.0f]);
			
			points[count]=pointcoordinate;
			count++;
		}
		
		// remainder of all segments
		SegmentVO *segment = [route segmentAtIndex:i];
		NSArray *allPoints = [segment allPoints];
		
		for (int i = 1; i < [allPoints count]; i++) {
			CSPointVO *latlon = [allPoints objectAtIndex:i];
			CLLocationCoordinate2D pointcoordinate;
			pointcoordinate.latitude = latlon.p.y;
			pointcoordinate.longitude = latlon.p.x;
			//CGPoint pt = [mapView convertCoordinate:pointcoordinate toPointToView:mapView];
			//CSPointVO *screen = [[CSPointVO alloc] init];
			//screen.p = pt;
			//screen.isWalking=segment.isWalkingSection;
			points[count]=pointcoordinate;
			
			NSLog(@"%lf,%lf,%f",pointcoordinate.latitude,pointcoordinate.longitude, [GlobalUtilities randomFloatBetween:0.1f and:12.0f]);
			
			count++;
		}
	}
	
	return points;
	
}

@end
