//
//  BUFolderView.m
//  Buffer
//
//  Created by Neil Edwards on 10/03/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import "BUFolderViewHeader.h"
#import "GlobalUtilities.h"

@implementation BUFolderViewHeader
@synthesize targetPoint;

/***********************************************************/
// dealloc
/***********************************************************/





- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds=YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
	
	BetterLog(@"");
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
   	
	//CGColorRef shadowColor = UIColorFromRGBAndAlpha(0x000000,0.5).CGColor;
	CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0x333333).CGColor);
	//CGContextSetFillColorWithColor(context, UIColorFromRGBAndAlpha(0x000000,.5).CGColor);
	
	CGContextBeginPath(context); // NE
    CGContextSetLineWidth(context, 0);
    
	CGFloat minx = CGRectGetMinX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
	
	CGContextSaveGState(context);
	//CGContextSetShadowWithColor(context, CGSizeMake(0, 6), 10.0, shadowColor);
	
    CGContextMoveToPoint(context, minx, kBUFOLDERAROWHEIGHT);
	CGContextAddLineToPoint(context, targetPoint-kBUFOLDERAROWHEIGHT,kBUFOLDERAROWHEIGHT);
	CGContextAddLineToPoint(context, targetPoint,miny);
	CGContextAddLineToPoint(context, targetPoint+kBUFOLDERAROWHEIGHT,kBUFOLDERAROWHEIGHT);	
    CGContextAddLineToPoint(context, maxx, kBUFOLDERAROWHEIGHT);
	CGContextAddLineToPoint(context, maxx,maxy);
	CGContextAddLineToPoint(context, minx, maxy);
	CGContextAddLineToPoint(context, minx, kBUFOLDERAROWHEIGHT);
	
	
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	CGContextRestoreGState(context);
	
}

/*
- (void)drawRect:(CGRect)rect{
	
	BetterLog(@"");
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
   	
	CGColorRef shadowColor = UIColorFromRGBAndAlpha(0x000000,0.5).CGColor;
	CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0x333333).CGColor);
	//CGContextSetFillColorWithColor(context, UIColorFromRGBAndAlpha(0x00ff00,.5).CGColor);
	
	CGContextBeginPath(context); // NE
    CGContextSetLineWidth(context, 0);
    
	CGFloat minx = CGRectGetMinX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat maxy = CGRectGetMaxY(rect)-kBUFOLDERAROWHEIGHT;
	
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 6), 10.0, shadowColor);
	
    CGContextMoveToPoint(context, minx, miny);
    CGContextAddLineToPoint(context, maxx, miny);
	CGContextAddLineToPoint(context, maxx,maxy);
	CGContextAddLineToPoint(context, kBUFOLDERAROWWIDTH*2,maxy);
	CGContextAddLineToPoint(context, kBUFOLDERAROWWIDTH+kBUFOLDERAROWWIDTH/2,maxy-kBUFOLDERAROWHEIGHT);
	CGContextAddLineToPoint(context, kBUFOLDERAROWWIDTH,maxy);
	CGContextAddLineToPoint(context, minx, maxy);
	
	CGContextAddLineToPoint(context, minx, miny);
	
	
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	CGContextRestoreGState(context);
		
}
*/


@end
