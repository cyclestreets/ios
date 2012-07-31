//
//  BorderView.h
//
//
//  Created by neil on 03/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewUtilities.h"

#define kBorderStrokeColor         [UIColor redColor]
#define kBorderStrokeWidth         2.0

@interface BorderView : UIView {
	CGFloat stroke;
	UIColor *strokeColor;
	BorderParams params;
	
	// gradiant support
	UIColor     *startColor;
	UIColor     *endColor;
	
}
@property (nonatomic)		CGFloat		stroke;
@property (nonatomic, strong)		UIColor		*strokeColor;
@property (nonatomic)		BorderParams		params;
@property (nonatomic, strong)		UIColor		*startColor;
@property (nonatomic, strong)		UIColor		*endColor;

-(void)drawBorder:(CGContextRef)context;
-(void)drawBorderwithColor:(UIColor*)color andStroke:(CGFloat)line left:(BOOL)left right:(BOOL)right top:(BOOL)top bottom:(BOOL)bottom;
- (void)drawBackGroundGradient:(CGContextRef)currentContext;
@end
