//
//  GradientView.h
//  evilrockhopper
//
//  Created by Daniel Wichett on 10/12/2009.
//

#import <UIKit/UIKit.h>

enum  {
	BUGradiantDirectionVertical,
	BUGradiantDirectionHorizontal
};
int typedef BUGradiantDirection;

@interface GradientView : UIView
{
    float startRed;
    float startGreen;
    float startBlue;
	
    float endRed;
    float endGreen;
    float endBlue;
	
	float startAlpha;
	float endAlpha;
	CGColorRef start;
	CGColorRef end;
	
    BOOL mirrored;
	
	BUGradiantDirection		direction;
}

@property (nonatomic)		BOOL		 mirrored;
@property (nonatomic)		BUGradiantDirection		 direction;

- (void) setColoursWithCGColors:(CGColorRef)color1 :(CGColorRef)color2;
- (void) setColours:(float)startRed :(float)startGreen :(float)startBlue :(float)endRed :(float)endGreen :(float)endBlue;

@end