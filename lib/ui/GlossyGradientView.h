//
//  GlossyGradientView.h
//
//
//  Created by Neil Edwards on 09/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultGlossyColor           [UIColor grayColor]

@interface GlossyGradientView : UIView {
	UIColor		*glossyColor;
	int			cornerRadius;
	
	UIImageView	*imageView;
	
}
@property (nonatomic, strong)	UIColor		*glossyColor;
@property (nonatomic)	int		cornerRadius;
@property (nonatomic, strong)	UIImageView		*imageView;
+ (void)setPathToRoundedRect:(CGRect)rect forInset:(NSUInteger)inset inContext:(CGContextRef)context forRadius:(int)radius;
+ (void)drawGlossyRect:(CGRect)rect withColor:(UIColor*)color inContext:(CGContextRef)context;
//+ (void)setBackgroundToGlossyButton:(UIButton*)button forColor:(UIColor*)color withBorder:(BOOL)border forState:(UIControlState)state;



@end
