//
//  GlossyGradientView.h
//  RacingUK
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultGlossyColor           [UIColor grayColor]

@interface GlossyGradientView : UIView {
	UIColor		*glossyColor;
	int			cornerRadius;
	
}
@property(nonatomic,retain)UIColor *glossyColor;
@property(nonatomic)int cornerRadius;
+ (void)setPathToRoundedRect:(CGRect)rect forInset:(NSUInteger)inset inContext:(CGContextRef)context forRadius:(int)radius;
+ (void)drawGlossyRect:(CGRect)rect withColor:(UIColor*)color inContext:(CGContextRef)context;
//+ (void)setBackgroundToGlossyButton:(UIButton*)button forColor:(UIColor*)color withBorder:(BOOL)border forState:(UIControlState)state;



@end
