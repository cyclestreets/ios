//
//  UIImage+RoundCorners.m
//  ImageCacheTest
//
//  Created by Adrian on 1/28/09.
//  Copyright 2009 Adrian Kosmaczewski. All rights reserved.
//

#import "UIImage+AKLoadingExtension.h"

@implementation UIImage (AKLoadingExtension)

+ (UIImage *)newImageFromResource:(NSString *)filename
{
    NSString *imageFile = [[NSString alloc] initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageFile];
    return image;
}

@end
