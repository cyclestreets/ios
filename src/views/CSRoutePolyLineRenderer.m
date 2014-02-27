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
#import "GlobalUtilities.h"

@interface CSRoutePolyLineRenderer()

@property (nonatomic,strong)  CSRoutePolyLineOverlay			* polyline;

@property (nonatomic,strong)  UIColor							*lineColor;
@property (nonatomic,strong)  UIColor							*dashedlineColor;

@property (nonatomic,assign)  CGMutablePathRef					mutablePath;

@end

@implementation CSRoutePolyLineRenderer



- (id)initWithPolyline:(MKPolyline *)polyline
{
	self = [super initWithOverlay:polyline];
	if (self) {
		self.polyline = (CSRoutePolyLineOverlay*)polyline;
		_mutablePath = CGPathCreateMutable();
		
		self.lineColor=UIColorFromRGBAndAlpha(0xFF00FF, 0.8);
		self.dashedlineColor=UIColorFromRGB(0xFF00FF);
		
		//[self createPath];
		
	}
	return self;
}


-(void) createPath{
    
    BOOL pathIsEmpty = YES;
    for (int i=0;i< _polyline.pointCount;i++){
		CGPoint point = [self pointForMapPoint:_polyline.points[i]];

        if (pathIsEmpty){
            CGPathMoveToPoint(_mutablePath, nil, point.x, point.y);
            pathIsEmpty = NO;
        } else {
            CGPathAddLineToPoint(_mutablePath, nil, point.x, point.y);
        }
    }
    
}


-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
	
	BetterLog(@"");
	
	float dashes[] = { 4, 4 };
    float normal[]={1};
	
	CGColorRef dashColor=_dashedlineColor.CGColor;
	CGColorRef solidColor=_lineColor.CGColor;
	
	//CGContextSetRGBFillColor(context, (rand() % 255) / 255.0, 0, 0, 0.1);
	//CGContextFillRect(context, [self rectForMapRect:mapRect]);
    
	
	
//	CGContextSetStrokeColorWithColor(context, solidColor);
//	CGContextSetLineWidth( context, 4.0/zoomScale);
//	
//	CGContextStrokePath(context);
//
	
	CGMutablePathRef fullPath = CGPathCreateMutable();
	
	BOOL pathIsEmpty = YES;
    for (int i=0;i< _polyline.pointCount;i++){
		CGPoint point = [self pointForMapPoint:_polyline.points[i]];
		
        if (pathIsEmpty){
            CGPathMoveToPoint(fullPath, nil, point.x, point.y);
            pathIsEmpty = NO;
        } else {
            CGPathAddLineToPoint(fullPath, nil, point.x, point.y);
        }
    }
	
	//CGContextAddPath(context, _mutablePath);
	
	CGRect pointsRect = CGPathGetBoundingBox(fullPath);
    CGRect mapRectCG = [self rectForMapRect:mapRect];
    if (!CGRectIntersectsRect(pointsRect, mapRectCG))return;
	
	CGPoint prevPoint;
    for (int i = 0; i < self.polyline.pointCount; i++) {
		
		CGMutablePathRef path = CGPathCreateMutable();
        CGPoint point = [self pointForMapPoint:self.polyline.points[i]];
		
		BetterLog(@"i=%i mappoint=%f,%f",i, point.x,point.y);
		
        if (i>0) {
			
            
            prevPoint=[self pointForMapPoint:self.polyline.points[i-1]];
			
			//CGPathMoveToPoint(path, nil, prevPoint.x, prevPoint.y);
           // CGPathAddLineToPoint(path, nil, point.x, point.y);
			
			//CGContextSaveGState(context);
			
			//CGPathRef pathToFill = CGPathCreateCopyByStrokingPath(path, NULL, 2, self.lineCap, self.lineJoin, self.miterLimit);
           // CGContextAddPath(context, path);
			//CGContextReplacePathWithStrokedPath(context);
			//CGContextSetStrokeColorWithColor(context, solidColor);
			//CGContextSetLineDash(context,0,normal,0);
			
			//CGContextStrokePath(context);
			
			CGContextSaveGState(context);
			CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGContextSetLineDash(context, 0, dashes, 1);
            CGContextSetLineWidth(context, 2);
            //CGContextAddPath(context, path);
            
            CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
            CGContextAddLineToPoint(context, point.x, point.y);
			CGContextRestoreGState(context);
//			
//			CGMutablePathRef path = CGPathCreateMutable();
//			CGPathMoveToPoint(path, nil, prevPoint.x, prevPoint.y);
//            CGPathAddLineToPoint(path, nil, point.x, point.y);
//			
//			CGPathCloseSubpath(path);
//			CGContextAddPath(context, path);
//			CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//			CGContextStrokePath(context);
//			CGPathRelease(path);
			
			
			//CGContextRestoreGState(context);
			
			/*
            CGFloat lineWidth = CGContextConvertSizeToUserSpace(context, (CGSize){self.lineWidth,self.lineWidth}).width;
            CGPathRef pathToFill = CGPathCreateCopyByStrokingPath(path, NULL, lineWidth, self.lineCap, self.lineJoin, self.miterLimit);
            CGContextAddPath(context, pathToFill);
            CGContextClip(context);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColors, gradientLocation, 2);
            CGColorSpaceRelease(colorSpace);
            CGPoint gradientStart = prevPoint;
            CGPoint gradientEnd = point;
            CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            CGContextRestoreGState(context);
			*/
//            
////            if(point.isWalking==YES){
////                CGContextSetStrokeColorWithColor(context, dashColor);
////                CGContextSetLineDash(context, 0, dashes, 1);
////            }else{
//                CGContextSetStrokeColorWithColor(context, solidColor);
//                CGContextSetLineDash(context,0,normal,0);
//            //}
//            
			
            
            //CGContextStrokePath(context);
            
            
        }else{
			CGPathMoveToPoint(path, nil, point.x, point.y);
		}
        
        
    }
	
    /*
    CGMutablePathRef fullPath = CGPathCreateMutable();
    BOOL pathIsEmpty = YES;
    for (int i=0;i< _polyline.pointCount;i++){
        CGPoint point = [self pointForMapPoint:_polyline.points[i]];
        if (pathIsEmpty){
            CGPathMoveToPoint(fullPath, nil, point.x, point.y);
            pathIsEmpty = NO;
        } else {
            CGPathAddLineToPoint(fullPath, nil, point.x, point.y);
        }
    }
    
    CGRect pointsRect = CGPathGetBoundingBox(fullPath);
    CGRect mapRectCG = [self rectForMapRect:mapRect];
    if (!CGRectIntersectsRect(pointsRect, mapRectCG))return;
    UIColor* pcolor,*ccolor;
    for (int i=0;i< _polyline.pointCount;i++){
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint point = [self pointForMapPoint:_polyline.points[i]];
        ccolor = [UIColor colorWithHue:hues[i] saturation:1.0f brightness:1.0f alpha:1.0f];
        if (i==0){
            CGPathMoveToPoint(path, nil, point.x, point.y);
        } else {
            CGPoint prevPoint = [self pointForMapPoint:_polyline.points[i-1]];
            CGPathMoveToPoint(path, nil, prevPoint.x, prevPoint.y);
            CGPathAddLineToPoint(path, nil, point.x, point.y);
            CGFloat pc_r,pc_g,pc_b,pc_a,
            cc_r,cc_g,cc_b,cc_a;
            [pcolor getRed:&pc_r green:&pc_g blue:&pc_b alpha:&pc_a];
            [ccolor getRed:&cc_r green:&cc_g blue:&cc_b alpha:&cc_a];
            CGFloat gradientColors[8] = {pc_r,pc_g,pc_b,pc_a,
				cc_r,cc_g,cc_b,cc_a};
            
            CGFloat gradientLocation[2] = {0,1};
            CGContextSaveGState(context);
            CGFloat lineWidth = CGContextConvertSizeToUserSpace(context, (CGSize){self.lineWidth,self.lineWidth}).width;
            CGPathRef pathToFill = CGPathCreateCopyByStrokingPath(path, NULL, lineWidth, self.lineCap, self.lineJoin, self.miterLimit);
            CGContextAddPath(context, pathToFill);
            CGContextClip(context);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColors, gradientLocation, 2);
            CGColorSpaceRelease(colorSpace);
            CGPoint gradientStart = prevPoint;
            CGPoint gradientEnd = point;
            CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            CGContextRestoreGState(context);
        }
        pcolor = [UIColor colorWithCGColor:ccolor.CGColor];
    }
	 */
	
}

@end
