//
//  UIView+Border.m
//
//
//  Created by neil on 03/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "UIView+Border.h"
#import "ViewUtilities.h"

@implementation UIView (Border)

+(void)drawBorderinView:(UIView*)view withColor:(UIColor*)color andStroke:(int)stroke left:(NSString*)left right:(NSString*)right top:(NSString*)top bottom:(NSString*)bottom{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect rrect = view.frame;
	
	CGContextBeginPath(context); 
    CGContextSetLineWidth(context, stroke);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
	
	CGFloat minx = CGRectGetMinX(rrect);
   // CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
   // CGFloat maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, miny);
	
	CGPoint addLines[] =
	{
		CGPointMake(0.0, 150.0),
		CGPointMake(70.0, 60.0),
		CGPointMake(130.0, 90.0),
		CGPointMake(190.0, 60.0),
		CGPointMake(250.0, 90.0),
		CGPointMake(310.0, 60.0),
	};
	
	// now we can simply add the lines to the context
	CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
	
	// and now draw the Path!
	CGContextStrokePath(context);
	
	//CGContextAddLineToPoint(context, minx, maxx);
//	
//	CGContextClosePath(context);
//	CGContextDrawPath(context, kCGPathStroke);
	
	
}


@end
