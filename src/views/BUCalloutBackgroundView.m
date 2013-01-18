//
//  BUCalloutBackgroundView.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/12/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "BUCalloutBackgroundView.h"

@implementation BUCalloutBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        super.opaque = NO;
        self.strokeColor = [UIColor clearColor];
        super.backgroundColor = [UIColor clearColor];
        self.fillColor = kDefaultRectColor;
        self.strokeWidth = kDefaultStrokeWidth;
        self.cornerRadius = kDefaultCornerRadius;
		self.arrowPoint=frame.size.width/2;
    }
    return self;
}


- (void)setBackgroundColor:(UIColor *)newBGColor
{
    // Ignore any attempt to set background color - backgroundColor must stay set to clearColor
}


// TODO: support point value for arrow rather than always center

- (void)drawRect:(CGRect)rect
{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
    CGContextSetLineWidth(context, _strokeWidth);
    CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
	CGContextSetShadow(context, CGSizeMake(0, 1), 4);
    
    CGRect rrect = self.bounds;
    
    CGFloat radius = _cornerRadius;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
	CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, maxy);
	CGContextAddArcToPoint(context, minx, miny, _arrowPoint, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxy-10, radius);
	
	// arrow
	CGContextAddArcToPoint(context, maxx, maxy-10, _arrowPoint+5, maxy-10, radius);
	CGContextAddLineToPoint(context, _arrowPoint+5, maxy-10);
	CGContextAddLineToPoint(context, _arrowPoint, maxy);
	CGContextAddLineToPoint(context, _arrowPoint-5, maxy-10);
	//
	
	CGContextAddArcToPoint(context, minx, maxy-10, minx, midy, radius);
	
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
	
	
}


@end
