
//
//  CSRoutePolyLineRenderer.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//


#import "CSRoutePolyLineRenderer.h"

#import "CSRoutePolyLineOverlay.h"
#import "CSPointVO.h"

#define MIN_POINT_DELTA 5.0 // controls how close points must be before being culled


@interface CSRoutePolyLineRenderer ()

- (CGPathRef)newPathForPoints:(NSMutableArray*)points clipRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale isDashed:(BOOL)isDashed;

@end

@implementation CSRoutePolyLineRenderer


- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale  inContext:(CGContextRef)context{
	
    CSRoutePolyLineOverlay *crumbs = (CSRoutePolyLineOverlay *)(self.overlay);
    
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale);
    
    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
	
	CGColorRef dashColor=[UIColor redColor].CGColor;
	CGColorRef solidColor=[UIColor blueColor].CGColor;
	
	float dashes[] = { 4/zoomScale, 4/zoomScale };
	//float normal[]={1};
    
    [crumbs lockForReading];
    CGPathRef normalPath = [self newPathForPoints:crumbs.routePoints clipRect:clipRect zoomScale:zoomScale isDashed:NO];
    [crumbs unlockForReading];
    
    if (normalPath != nil)
    {
        CGContextSaveGState(context);
        CGContextAddPath(context, normalPath);
        CGContextSetStrokeColorWithColor(context, solidColor);
        CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
        CGPathRelease(normalPath);
        CGContextRestoreGState(context);
    }
    
    [crumbs lockForReading];
    CGPathRef dashedPath = [self newPathForPoints:crumbs.routePoints clipRect:clipRect zoomScale:zoomScale isDashed:YES];
    [crumbs unlockForReading];
    
    if (dashedPath != nil)
    {
        CGContextSaveGState(context);
        CGContextAddPath(context, dashedPath);
        CGContextSetStrokeColorWithColor(context, dashColor);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineDash(context, 0, dashes, 1);
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
        CGPathRelease(dashedPath);
        CGContextRestoreGState(context);
    }
}


// do these points intersect the curent map visible rect
static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r)
{
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}


// Optimisation method, determines wether poitns should be drawn based on visible map intersection and if they are far enough apart  to be visibly resolveable

- (CGPathRef)newPathForPoints:(NSMutableArray*)points clipRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale isDashed:(BOOL)isDashed{
    
    if (points.count < 2)
        return NULL;
    
    CGMutablePathRef path = NULL;
    
    BOOL needsMove = YES;
    
	#define POW2(a) ((a) * (a))
    
    double minPointDelta = MIN_POINT_DELTA / zoomScale;
    double c2 = POW2(minPointDelta);
    
    MKMapPoint point;
	CSPointVO *firstpoint=points[0];
	MKMapPoint lastPoint = firstpoint.mapPoint;
	int pointCount=points.count;
    NSUInteger i;
    int segmentIndex=0;
	
    for (i = 1; i < pointCount - 1; i++){
		
		CSPointVO *cspoint=points[i];
        point = cspoint.mapPoint;
        double a2b2 = POW2(point.x - lastPoint.x) + POW2(point.y - lastPoint.y);
		
        if (a2b2 >= c2) {
            if (lineIntersectsRect(point, lastPoint, mapRect)){
                
                if (!path)
                    path = CGPathCreateMutable();
                
                if (needsMove){
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                
                BOOL shouldDrawSegment=cspoint.isWalking!=isDashed;
                
                CGPoint cgPoint = [self pointForMapPoint:point];
                
                if(shouldDrawSegment==YES){
                    CGPathMoveToPoint(path, NULL, cgPoint.x, cgPoint.y);
                }else{
                    CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
                }
                
                
				segmentIndex++;
            }
            else
            {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            lastPoint = point;
        }
    }
    
	#undef POW2
    
   
	CSPointVO *lastCSpoint=points.lastObject;
    point = lastCSpoint.mapPoint;
    if (lineIntersectsRect(lastPoint, point, mapRect)) {
		
        if (!path)
            path = CGPathCreateMutable();
		
        if (needsMove) {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
		
        BOOL shouldDrawSegment=lastCSpoint.isWalking!=isDashed;
		
		CGPoint cgPoint = [self pointForMapPoint:point];
		
		if(shouldDrawSegment==YES){
			CGPathMoveToPoint(path, NULL, cgPoint.x, cgPoint.y);
		}else{
			CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
		}
    }
    
    
    return path;
}


@end
