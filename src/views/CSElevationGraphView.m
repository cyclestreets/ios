//
//  CSElevationGraphView.m
//  CycleStreets
//
//  Created by Neil Edwards on 07/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "CSElevationGraphView.h"
#import "CSPointVO.h"

@interface CSElevationGraphView()

@end

@implementation CSElevationGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}

-(void)initialise{
	
	
	// draw border/labels
	
	
}


-(void)update{
	
	
	// update labels
	
	// calculate points
	
	
}


- (void)drawRect:(CGRect)rect{
	
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetLineWidth( ctx, 4.0);
	CGContextSetStrokeColorWithColor(ctx, _lineColor.CGColor);
	CGContextSetFillColorWithColor(ctx, _fillColor.CGColor);
    
	NSArray *points = @[];
	
    for (int i=0;i<_dataProvider.count;i++) {
        
        CSPointVO *point=_dataProvider[i];
        CGContextAddLineToPoint(ctx, point.p.x, point.p.y);
         
        
    }
	
	CGContextStrokePath(ctx);
	CGContextClosePath(ctx);
	
}


@end
