//
//  BUDividerView.m
//  RacingUK
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 Chroma. All rights reserved.
//

#import "BUDividerView.h"
#import "ViewUtilities.h"
#import "GlobalUtilities.h"
#import "UIColor-Expanded.h"
#import <QuartzCore/QuartzCore.h>

@implementation BUDividerView
@synthesize stroke;
@synthesize topStrokeColor;
@synthesize bottomStrokeColor;
@synthesize position;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [topStrokeColor release], topStrokeColor = nil;
    [bottomStrokeColor release], bottomStrokeColor = nil;
	
    [super dealloc];
}



- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) 
    {
		[self initialise];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self initialise];
    }
    return self;
}



-(void)initialise{
	
	position.top=YES;
	position.bottom=NO;
	stroke=kBorderStrokeWidth;
	topStrokeColor=kTopBorderStrokeColor;
	bottomStrokeColor=kBottomBorderStrokeColor;
	self.backgroundColor=[UIColor clearColor];
	
}


- (void)drawRect:(CGRect)rect {
	
	[self drawBorder:UIGraphicsGetCurrentContext()];
}


-(void)drawBorderwithColor:(UIColor*)color andStroke:(CGFloat)lineStroke 
					  left:(BOOL)left right:(BOOL)right top:(BOOL)top bottom:(BOOL)bottom{
	// note self, ensures retention of these ivars
	self.topStrokeColor=color;
	self.bottomStrokeColor=color;
	self.stroke=lineStroke;
	position.top=top;
	position.bottom=bottom;
	
	[self setNeedsDisplay];
	
}

-(void)drawBorder:(CGContextRef)context{
	
	CGRect rrect=self.frame;
	CGFloat minx = 0.0;
	CGFloat maxx = rrect.size.width;
    CGFloat miny = 0.0;
	CGFloat maxy =rrect.size.height;
	
	
	CGContextSetLineWidth(context, self.stroke);
	
	if (position.top==YES) {
		CGContextSetStrokeColorWithColor(context, self.topStrokeColor.CGColor);
		CGContextMoveToPoint(context, minx,miny);
		CGContextAddLineToPoint(context, maxx,miny);
		CGContextStrokePath(context);
		CGContextSetStrokeColorWithColor(context, self.bottomStrokeColor.CGColor);
		miny+=1;
		CGContextMoveToPoint(context, maxx,miny);
		CGContextAddLineToPoint(context, minx,miny);
		CGContextStrokePath(context);
	}
	
	if (position.bottom==YES) {
		CGContextSetStrokeColorWithColor(context, self.topStrokeColor.CGColor);
		maxy=maxy-1;
		CGContextMoveToPoint(context, minx,maxy);
		CGContextAddLineToPoint(context, maxx,maxy);
		CGContextStrokePath(context);
		CGContextSetStrokeColorWithColor(context, self.bottomStrokeColor.CGColor);
		maxy+=1;
		CGContextMoveToPoint(context, maxx,maxy);
		CGContextAddLineToPoint(context, minx,maxy);
		CGContextStrokePath(context);
	}
	
	
}




@end
