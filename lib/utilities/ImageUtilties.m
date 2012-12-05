//
//  ImageUtilties.m
//  CycleStreets
//
//  Created by Neil Edwards on 06/11/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "ImageUtilties.h"

@implementation ImageUtilties


// Tint the image
- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor {
	
    // Begin drawing
    CGRect aRect = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(aRect.size);
	
    // Get the graphic context
    CGContextRef c = UIGraphicsGetCurrentContext();
	
    // Draw the image
    [image drawInRect:aRect];
	
    // Set the fill color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetFillColorSpace(c, colorSpace);
	
    // Set the fill color
    CGContextSetFillColorWithColor(c, [tintColor colorWithAlphaComponent:0.5f].CGColor);
	
    UIRectFillUsingBlendMode(aRect, kCGBlendModeNormal);
	
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    // Release memory
    CGColorSpaceRelease(colorSpace);
	
    return img;
}

@end
