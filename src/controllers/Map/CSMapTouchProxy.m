//
//  CSMapTouchProxy.m
//  CycleStreets
//
//  Created by Neil Edwards on 06/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "CSMapTouchProxy.h"
#import "RMMapView.h"

@interface CSMapTouchProxy()

@property(nonatomic,strong)  RMMapView         *sv;



@end

@implementation CSMapTouchProxy



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}



-(void)addProxy:(RMMapView*)mapView{
	
	self.sv=mapView;
	
}

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong
{
	[super moveToLatLong:latlong];
	[[self sv] moveToLatLong:latlong];
}

/// recenter the map on #aPoint, expressed in projected meters
- (void)moveToProjectedPoint: (RMProjectedPoint)aPoint
{
	[super moveToProjectedPoint:aPoint];
	[[self sv] moveToProjectedPoint:aPoint];
}

- (void)moveBy: (CGSize) delta
{
	[super moveBy:delta];
	[[self sv] moveBy:delta];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint
{
	[super zoomByFactor:zoomFactor near:aPoint];
	[[self sv] zoomByFactor:zoomFactor near:aPoint];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint
			animated:(BOOL)animated
{
	[super zoomByFactor:zoomFactor near:aPoint animated:animated];
	[[self sv] zoomByFactor:zoomFactor near:aPoint animated:animated];
}

-(BOOL) enableDragging
{
	BOOL r=super.enableDragging;
	assert(r==[self sv].enableDragging);
	return r;
}
-(void)setEnableDragging:(BOOL)d
{
	super.enableDragging=d;
	[self sv].enableDragging=d;
}


-(BOOL) enableZoom
{
	BOOL r=super.enableZoom;
	assert(r==[self sv].enableZoom);
	return r;
}
-(void)setEnableZoom:(BOOL)d
{
	super.enableZoom=d;
	[self sv].enableZoom=d;
}

-(BOOL) enableRotate
{
	BOOL r=super.enableRotate;
	assert(r==[self sv].enableRotate);
	return r;
}
-(void)setEnableRotate:(BOOL)d
{
	super.enableRotate=d;
	[self sv].enableRotate=d;
}


-(float)decelerationFactor
{
	float r=super.decelerationFactor;
	assert(r==[self sv].decelerationFactor);
	return r;
}
-(void)setDecelerationFactor:(float)d
{
	super.decelerationFactor=d;
	[self sv].decelerationFactor=d;
}

-(BOOL) deceleration
{
	BOOL r=super.deceleration;
	assert(r==[self sv].deceleration);
	return r;
}
-(void)setDeceleration:(BOOL)d
{
	super.deceleration=d;
	[self sv].deceleration=d;
}

-(CGFloat)rotation
{
	float r=super.rotation;
	assert(r==[self sv].rotation);
	return r;
}

- (void)setRotation:(CGFloat)angle
{
	[super setRotation:angle];
	[[self sv] setRotation:angle];
}
@end

