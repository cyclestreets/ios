//
//  CSRoutePolyLineOverlay.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSRoutePolyLineOverlay.h"
#import <pthread.h>

#import "RouteVO.h"
#import "CSPointVO.h"

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 10.0

@interface CSRoutePolyLineOverlay()


@property (nonatomic,assign)MKMapRect           boundingMapRect;
@property (nonatomic,assign) pthread_rwlock_t   rwLock;


@property (nonatomic,strong)  RouteVO           * dataProvider;
@property (nonatomic,readwrite)  NSMutableArray * routePoints;

+(NSMutableArray*)coordinatesForRoute:(RouteVO*)route;


@end

@implementation CSRoutePolyLineOverlay

#pragma mark - CS compatible init

-(id) initWithRoute:(RouteVO*)route {
	
	self = [super init];
	
	if (self){
		
		[self updateForDataProvider:route];
		
    }
    return self;
	
	
}

-(id) initWithSegment:(SegmentVO*)segment {
	
	self = [super init];
	
	if (self){
		
		[self updateForSegment:segment];
		
    }
    return self;
	
	
}




-(void)updateForDataProvider:(RouteVO*)route{
	
	if(route==nil)
		return;
	
	_dataProvider=route;
	self.routePoints=[CSRoutePolyLineOverlay coordinatesForRoute:_dataProvider];
	
	//bite off up to 1/4 of the world to draw into
	CSPointVO *firstPoint=_routePoints[0];
	MKMapPoint origin = firstPoint.mapPoint;
	origin.x -= MKMapSizeWorld.width/8.0;
	origin.y -= MKMapSizeWorld.height/8.0;
	MKMapSize size = MKMapSizeWorld;
	size.width /=4.0;
	size.height /=4.0;
	_boundingMapRect = (MKMapRect) {origin, size};
	MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
	_boundingMapRect = MKMapRectIntersection(_boundingMapRect, worldRect);
	
	// initialize read-write lock for drawing and updates
	pthread_rwlock_init(&_rwLock,NULL);
}


-(void)updateForSegment:(SegmentVO*)segment{
	
	self.routePoints=[CSRoutePolyLineOverlay coordinatesForSegment:segment];
	
	
	CSPointVO *firstPoint=_routePoints[0];
	MKMapPoint origin = firstPoint.mapPoint;
	origin.x -= MKMapSizeWorld.width/8.0;
	origin.y -= MKMapSizeWorld.height/8.0;
	MKMapSize size = MKMapSizeWorld;
	size.width /=4.0;
	size.height /=4.0;
	_boundingMapRect = (MKMapRect) {origin, size};
	MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
	_boundingMapRect = MKMapRectIntersection(_boundingMapRect, worldRect);
	
	// initialize read-write lock for drawing and updates
	pthread_rwlock_init(&_rwLock,NULL);
	
}





-(void)resetOverlay{
	
	[self.routePoints removeAllObjects];
	
}




#pragma mark - Class methods

+(NSMutableArray*)coordinatesForRoute:(RouteVO*)route{
	
	NSMutableArray *arr=[NSMutableArray array];
	
	for (int i = 0; i < [route numSegments]; i++) {
		
		if (i == 0){
			// start of first segment
			CSPointVO *point = [[CSPointVO alloc] init];
			SegmentVO *segment = [route segmentAtIndex:i];
			CLLocationCoordinate2D pointcoordinate = [segment segmentStart];
			point.point=CGPointMake(pointcoordinate.longitude, pointcoordinate.latitude);
			point.isWalking=segment.isWalkingSection;
			
			[arr addObject:point];
		}
		
		// remainder of all segments
		SegmentVO *segment = [route segmentAtIndex:i];
		NSArray *allPoints = [segment allPoints];
		
		for (int i = 1; i < [allPoints count]; i++) {
			CSPointVO *latlon = [allPoints objectAtIndex:i];
			CLLocationCoordinate2D pointcoordinate;
			pointcoordinate.latitude = latlon.point.y;
			pointcoordinate.longitude = latlon.point.x;
			CSPointVO *screen = [[CSPointVO alloc] init];
			screen.point = CGPointMake(pointcoordinate.longitude, pointcoordinate.latitude);
			screen.isWalking=segment.isWalkingSection;
			[arr addObject:screen];
			
		}
	}
	
	return arr;
	
}

+(NSMutableArray*)coordinatesForSegment:(SegmentVO*)segment{
	
	NSMutableArray *arr=[NSMutableArray array];
	
	CSPointVO *startpoint = [[CSPointVO alloc] init];
	startpoint.point=CGPointMake([segment segmentStart].longitude, [segment segmentStart].latitude);
	startpoint.isWalking=segment.isWalkingSection;
	[arr addObject:startpoint];
	
	NSArray *allPoints = [segment allPoints];
	
	for (int i = 1; i < [allPoints count]; i++) {
		CSPointVO *latlon = [allPoints objectAtIndex:i];
		CLLocationCoordinate2D pointcoordinate;
		pointcoordinate.latitude = latlon.point.y;
		pointcoordinate.longitude = latlon.point.x;
		CSPointVO *screen = [[CSPointVO alloc] init];
		screen.point = CGPointMake(pointcoordinate.longitude, pointcoordinate.latitude);
		screen.isWalking=segment.isWalkingSection;
		[arr addObject:screen];
		
	}
	
	return arr;
	
}



- (CLLocationCoordinate2D)coordinate
{
	CSPointVO *firstPoint=_routePoints[0];
    return MKCoordinateForMapPoint(firstPoint.mapPoint);
}

- (MKMapRect)boundingMapRect
{
    return _boundingMapRect;
}



#pragma mark - Apple code, may be deprecated as we dont use the c arrays anymore

- (void)lockForReading
{
    pthread_rwlock_rdlock(&_rwLock);
}

- (void)unlockForReading
{
    pthread_rwlock_unlock(&_rwLock);
}



@end
