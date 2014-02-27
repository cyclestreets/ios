/*
     File: CrumbPath.m 
 Abstract: CrumbPath is an MKOverlay model class representing a path that changes over time. 
  Version: 1.6 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "CrumbPath.h"

#import "RouteVO.h"
#import "CSPointVO.h"

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 10.0

@interface CrumbPath()

@property (nonatomic,assign) MKMapPoint *points;
@property (nonatomic,assign)NSUInteger pointCount;
@property (nonatomic,assign)NSUInteger pointSpace;
@property (nonatomic,assign)MKMapRect boundingMapRect;
@property (nonatomic,assign) pthread_rwlock_t rwLock;


@property (nonatomic,strong)  RouteVO						*dataProvider;
@property (nonatomic,readwrite)  NSMutableArray				*routePoints;

+(NSMutableArray*)coordinatesForRoute:(RouteVO*)route;


@end

@implementation CrumbPath

@synthesize points, pointCount;

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord
{
	self = [super init];
    if (self)
	{
        // initialize point storage and place this first coordinate in it
        _pointSpace = INITIAL_POINT_SPACE;
        points = malloc(sizeof(MKMapPoint) * _pointSpace);
        points[0] = MKMapPointForCoordinate(coord);
        pointCount = 1;
        
        // bite off up to 1/4 of the world to draw into.
        MKMapPoint origin = points[0];
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        _boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        _boundingMapRect = MKMapRectIntersection(_boundingMapRect, worldRect);
        
        // initialize read-write lock for drawing and updates
        pthread_rwlock_init(&_rwLock, NULL);
    }
    return self;
}


-(id) initWithPoints:(CLLocationCoordinate2D*)_points count:(NSUInteger)_count{
    self = [super init];
    if (self){
        pointCount = _count;
        points = malloc(sizeof(MKMapPoint)*pointCount);
        for (NSUInteger i=0; i<_count; i++){
            self.points[i] = MKMapPointForCoordinate(_points[i]);
        }
        
        //bite off up to 1/4 of the world to draw into
        MKMapPoint origin = points[0];
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
    return self;
}


#pragma mark - CS compatible init

-(id) initWithRoute:(RouteVO*)route {
	
	self = [super init];
	
	if (self){
		
		_dataProvider=route;
		self.routePoints=[CrumbPath coordinatesForRoute:_dataProvider];
		        
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
    return self;
	
	
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









#pragma mark - Apple code, may be deprecated


- (void)dealloc
{
    free(points);
    pthread_rwlock_destroy(&_rwLock);
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

- (void)lockForReading
{
    pthread_rwlock_rdlock(&_rwLock);
}

- (void)unlockForReading
{
    pthread_rwlock_unlock(&_rwLock);
}


- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord
{
    // Acquire the write lock because we are going to be changing the list of points
    pthread_rwlock_wrlock(&_rwLock);
        
    // Convert a CLLocationCoordinate2D to an MKMapPoint
    MKMapPoint newPoint = MKMapPointForCoordinate(coord);
    MKMapPoint prevPoint = points[pointCount - 1];
    
    // Get the distance between this new point and the previous point.
    CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
    MKMapRect updateRect = MKMapRectNull;
    
    if (metersApart > MINIMUM_DELTA_METERS)
    {
        // Grow the points array if necessary
        if (_pointSpace == pointCount)
        {
            _pointSpace *= 2;
            points = realloc(points, sizeof(MKMapPoint) * _pointSpace);
        }    
        
        // Add the new point to the points array
        points[pointCount] = newPoint;
        pointCount++;
        
        // Compute MKMapRect bounding prevPoint and newPoint
        double minX = MIN(newPoint.x, prevPoint.x);
        double minY = MIN(newPoint.y, prevPoint.y);
        double maxX = MAX(newPoint.x, prevPoint.x);
        double maxY = MAX(newPoint.y, prevPoint.y);
        
        updateRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    
    pthread_rwlock_unlock(&_rwLock);
    
    return updateRect;
}

@end
