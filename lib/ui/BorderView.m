//
//  BorderView.m
//  CycleStreets
//
//  Created by neil on 03/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import "BorderView.h"
#import "ViewUtilities.h"
#import "GlobalUtilities.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

@implementation BorderView
@synthesize stroke;
@synthesize strokeColor;
@synthesize params;
@synthesize startColor;
@synthesize endColor;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [strokeColor release], strokeColor = nil;
    [startColor release], startColor = nil;
    [endColor release], endColor = nil;
	
    [super dealloc];
}





- (id)initWithFrame:(CGRect)frame 
{
	
	if (self = [super initWithFrame:frame]) 
    {
		params.top=NO;
		params.left=NO;
		params.right=NO;
		params.bottom=NO;
        stroke=kBorderStrokeWidth;
		strokeColor=kBorderStrokeColor;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	
	[self drawBorder:UIGraphicsGetCurrentContext()];
	
	if(startColor!=nil){
		[self drawBackGroundGradient:UIGraphicsGetCurrentContext()];
	}
	
}


-(void)drawBorderwithColor:(UIColor*)color andStroke:(CGFloat)lineStroke 
				   left:(BOOL)left right:(BOOL)right top:(BOOL)top bottom:(BOOL)bottom{
	// nore self, ensures retention of these ivars
	self.strokeColor=color;
	self.stroke=lineStroke;
	params.top=top;
	params.left=left;
	params.right=right;
	params.bottom=bottom;
	
	[self setNeedsDisplay];

}

-(void)drawBorder:(CGContextRef)context{

	CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
	CGContextSetLineWidth(context, self.stroke);
	
	CGRect rrect=self.frame;
	CGFloat minx = 0.0;
	CGFloat maxx = rrect.size.width;
    CGFloat miny = 0.0;
	CGFloat maxy =rrect.size.height;

	
	
	if (params.top==YES) {
		CGContextMoveToPoint(context, minx,miny);
		CGContextAddLineToPoint(context, maxx,miny);
		CGContextStrokePath(context);
	}
	
	if (params.right==YES) {
		CGContextMoveToPoint(context, maxx,miny);
		CGContextAddLineToPoint(context, maxx,maxy);
		CGContextStrokePath(context);
	}
	
	if (params.bottom==YES) {
		CGContextMoveToPoint(context, minx,maxy);
		CGContextAddLineToPoint(context, maxx,maxy);
		CGContextStrokePath(context);
	}
	
	if (params.left==YES) {
		CGContextMoveToPoint(context, minx,miny);
		CGContextAddLineToPoint(context, minx,maxy);
		CGContextStrokePath(context);
	}
	
	
	
}


- (void)drawBackGroundGradient:(CGContextRef)currentContext {
	
		
	
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	
	// alpha will default to 1.0
	CGFloat components[8] = { startColor.red,startColor.green,startColor.blue, startColor.alpha,  // Start color, ie white
		endColor.red,endColor.green,endColor.blue, endColor.alpha }; // End color
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
	CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace); 
		
	
}




@end
