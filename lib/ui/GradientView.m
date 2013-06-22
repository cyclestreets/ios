//
//  GradientView.m
//  evilrockhopper
//
//  Created by Daniel Wichett on 10/12/2009.
//
//  Extension of UIView to show a gradient, generally used as a background on other views.
//  Mirrored indicates a gradient that is colour1 -> colour2 -> colour1. Non-mirrored simply goes from colour1 -> colour2.

#import "GradientView.h"

@implementation GradientView
@synthesize mirrored;
@synthesize direction;



- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t numLocations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
	
    //Two colour components, the start and end colour both set to opaque.
    CGFloat components[8] = { startRed, startGreen, startBlue, startAlpha, endRed, endGreen, endBlue, endAlpha };
	
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, numLocations);
	
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds)/2.0);
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
	
	CGPoint leftCenter = CGPointMake( 0.0f, CGRectGetMidY(currentBounds));
    CGPoint rightCenter = CGPointMake(CGRectGetMaxX(currentBounds), CGRectGetMidY(currentBounds));
	
	
	switch(direction){
		
		case BUGradiantDirectionHorizontal:
			
			
			if (!mirrored)
			{
				// draw a gradient from top to bottom centred.
				CGContextDrawLinearGradient(currentContext, glossGradient, leftCenter, rightCenter, 0);
			}
			else
			{
				// draw a gradient from top to middle, then reverse the colours and draw from middle to bottom.
				CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
				CGFloat components2[8] = { endRed, endGreen, endBlue, endAlpha, startRed, startGreen, startBlue, startAlpha };
				CGGradientRelease(glossGradient);
				glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components2, locations, numLocations);
				CGContextDrawLinearGradient(currentContext, glossGradient, midCenter, bottomCenter, 0);
			}
			
			
		
		break;
			
		default:
			
			if (!mirrored)
			{
				// draw a gradient from top to bottom centred.
				CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
			}
			else
			{
				// draw a gradient from top to middle, then reverse the colours and draw from middle to bottom.
				CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
				CGFloat components2[8] = { endRed, endGreen, endBlue, endAlpha, startRed, startGreen, startBlue, startAlpha };
				CGGradientRelease(glossGradient);
				glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components2, locations, numLocations);
				CGContextDrawLinearGradient(currentContext, glossGradient, midCenter, bottomCenter, 0);
			}
			
			
		break;
		
		
	}
	
   
	
    // Release our CG objects.
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

// Set colours as component RGB.
- (void) setColours:(float)_startRed :(float)_startGreen :(float)_startBlue :(float)_endRed :(float)_endGreen :(float)_endBlue
{
	startRed = _startRed;
	startGreen = _startGreen;
	startBlue = _startBlue;
	
	endRed = _endRed;
	endGreen = _endGreen;
	endBlue = _endBlue;
}

// Set colours as CGColorRefs.
- (void) setColoursWithCGColors:(CGColorRef)color1 :(CGColorRef)color2{
	
	startAlpha=CGColorGetAlpha(color1);
	endAlpha=CGColorGetAlpha(color2);
	
	
	const CGFloat *startComponents = CGColorGetComponents(color1);
	const CGFloat *endComponents = CGColorGetComponents(color2);
	
	[self setColours:startComponents[0]:startComponents[1]:startComponents[2]:endComponents[0]:endComponents[1]:endComponents[2]];
}



@end