/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  RouteLineView.m
//  CycleStreets
//
//  Created by Alan Paxton on 17/05/2010.
//

#import "RouteLineView.h"
#import "CSPointVO.h"
#import "GlobalUtilities.h"
#import <math.h>

static NSInteger MAX_DIST = 10;

@interface RouteLineView()

@property (nonatomic,strong)  UIColor           *lineColor;
@property (nonatomic,strong)  UIColor           *dashedlineColor;

-(void)initialise;

@end

@implementation RouteLineView

@synthesize pointListProvider;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialise];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		[self initialise];
    }
    return self;
}

-(void)initialise{
	
	self.lineColor=UIColorFromRGBAndAlpha(0xFF00FF, 0.8);
	self.dashedlineColor=UIColorFromRGB(0xFF00FF);
	
}

//estimate on x,y only. sum these. Close enough for our "when to split" purposes.
- (NSInteger) dist:(CGPoint)p1 to:(CGPoint)p2 {
	return abs(p2.x - p1.x) + abs(p2.y - p1.y);
}

//points are far apart, interpolate so we can plot close to the edge.
- (NSArray *) interpolateFrom:(CGPoint)p1 to:(CGPoint)p2 {
	NSInteger dist = [self dist:p1 to:p2];
	NSInteger num =  dist / MAX_DIST;
	NSMutableArray *results = [[NSMutableArray alloc] init];
	for (int i = 0; i < num; i++) {
		CGPoint p;
		p.x = p1.x + i * (p2.x - p1.x) / num;
		p.y = p1.y + i * (p2.y - p1.y) / num;
		CSPointVO *csPoint = [[CSPointVO alloc] init];
		csPoint.point = p;
		[results addObject:csPoint];
	}
	return results;
}

//interpolate when points cross boundaries.
- (NSArray *) interpolate:(NSArray *)points {
	NSMutableArray *result = [[NSMutableArray alloc] init];
	CSPointVO *prev = nil;
	for (CSPointVO *point in points) {
		if (prev != nil) {
			NSArray *between = [self interpolateFrom:prev.point to:point.point];
			[result addObjectsFromArray:between];
		}
		[result addObject:point];
		prev = point;
	}
	return result;
}

// should be able to do multi plan drawing in layers
- (void)drawRect:(CGRect)rect {
	
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth( ctx, 4.0);
	
	float dashes[] = { 4, 4 };
    float normal[]={1};
	
	CGColorRef dashColor=_dashedlineColor.CGColor;
	CGColorRef solidColor=_lineColor.CGColor;
    
	NSArray *points = [pointListProvider pointList];
	int pointCount=points.count;
    for (int i=0;i<pointCount;i++) {
        
        CSPointVO *point=points[i];
        CSPointVO *prevpoint;
        
        if (i>0) {
            
            prevpoint=points[i-1];
            
            if(point.isWalking==YES){
                CGContextSetStrokeColorWithColor(ctx, dashColor);
                CGContextSetLineDash(ctx, 0, dashes, 1);
            }else{
                CGContextSetStrokeColorWithColor(ctx, solidColor);
                CGContextSetLineDash(ctx,0,normal,0);
            }
            
            
            
            CGContextMoveToPoint(ctx, prevpoint.point.x, prevpoint.point.y);
            CGContextAddLineToPoint(ctx, point.point.x, point.point.y);
            
            CGContextStrokePath(ctx);
            
            
        }
        
        
    }
	
	
	
	/*
	 CGContextRef ctx = UIGraphicsGetCurrentContext();
	 
	 CGContextSetLineWidth( ctx, 4.0);
	 CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.8 green:0.2 blue:1.0 alpha:0.8].CGColor);
	 
	 NSArray *points = [pointListProvider pointList];
	 
	 bool first = YES;
	 for (CSPointVO *point in points) {
	 if (first) {
	 CGContextMoveToPoint(ctx, point.p.x, point.p.y);
	 first = NO;
	 } else {
	 CGContextAddLineToPoint(ctx, point.p.x, point.p.y);
	 }
	 }
	 
	 CGContextStrokePath(ctx);
	 */
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
	[self.nextResponder touchesMoved:touches withEvent:event];
}



@end
