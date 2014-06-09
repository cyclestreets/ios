//
//  UIButton+tintImage.m
//  Jumbler
//
//  Created by Filip Stefansson on 13-10-20.
//  Copyright (c) 2013 Pixby Media AB. All rights reserved.
//

#import "UIButton+tintImage.h"

@implementation UIButton (tintImage)

#pragma mark Image tint

-(void)setImageTintColor:(UIColor *)color forState:(UIControlState)state
{
    if (self.imageView.image)
        [self setImage:[self tintedImageWithColor:color image:[self.imageView image]] forState:state];
    else
        NSLog(@"%@ UIButton does not have any image to tint.", self);
}

+(void)tintButtonImages:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state
{
    for (UIButton *button in buttons)
    {
        [button setImageTintColor:color forState:state];
    }
}

#pragma mark Background tint

-(void)setBackgroundTintColor:(UIColor *)color forState:(UIControlState)state
{
    if ([self backgroundImageForState:state])
        [self setBackgroundImage:[self tintedImageWithColor:color image:[self backgroundImageForState:state]] forState:state];
    else
        NSLog(@"%@ UIButton does not have any background image to tint.", self);
}

+(void)tintButtonBackgrounds:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state
{
    for (UIButton *button in buttons)
    {
        [button setBackgroundTintColor:color forState:state];
    }
}

#pragma mark Tint method

// Mod of @horsejockey's method:
// http://stackoverflow.com/a/19413033

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor image:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}


@end
