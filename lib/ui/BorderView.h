//
//  BorderView.h
//  CycleStreets
//
//  Created by neil on 03/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBorderStrokeColor         [UIColor redColor]
#define kBorderStrokeWidth         2.0

typedef struct
{
	BOOL left;
	BOOL right;
	BOOL top;
	BOOL bottom;
} BorderParams;

@interface BorderView : UIView {
	CGFloat stroke;
	UIColor *strokeColor;
	BorderParams params;
	
	// gradiant support
	UIColor     *startColor;
	UIColor     *endColor;
	
}
@property (nonatomic)		CGFloat		stroke;
@property (nonatomic, retain)		UIColor		*strokeColor;
@property (nonatomic)		BorderParams		params;
@property (nonatomic, retain)		UIColor		*startColor;
@property (nonatomic, retain)		UIColor		*endColor;

-(void)drawBorder:(CGContextRef)context;
-(void)drawBorderwithColor:(UIColor*)color andStroke:(CGFloat)line left:(BOOL)left right:(BOOL)right top:(BOOL)top bottom:(BOOL)bottom;
- (void)drawBackGroundGradient:(CGContextRef)currentContext;
@end
