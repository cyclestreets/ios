//
//  UIImage+ColorImage.h
//  Flotsm
//
//  Created by Neil Edwards on 24/09/2014.
//  Copyright (c) 2014 mohawk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorImage)


+(UIImage*)colorPDFImageForID:(NSString*)imageName atSize:(CGSize)size withTint:(UIColor*)color;



+(UIButton*)styleNavButtonForID:(NSString*)imageName atSize:(CGSize)size;
+(void)styleExistingNavButton:(UIButton*)button forID:(NSString*)imageName atSize:(CGSize)size;


+(UIImage *) nonColorimageWithPDFNamed:(NSString *)resourceName atSize:(CGSize)size;

@end
