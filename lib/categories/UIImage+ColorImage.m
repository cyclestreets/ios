//
//  UIImage+ColorImage.m
//  Flotsm
//
//  Created by Neil Edwards on 24/09/2014.
//  Copyright (c) 2014 mohawk. All rights reserved.
//

#import "UIImage+ColorImage.h"
#import "UIImage+PDF.h"
#import "UIImage+Additions.h"
#import "UIColor+AppColors.h"

@implementation UIImage (ColorImage)


+(UIImage*)colorPDFImageForID:(NSString*)imageName atSize:(CGSize)size withTint:(UIColor*)color{
    
    UIImage *pdfImage=nil;
    
    // allow aspect correct images
    if(size.height==0){
        pdfImage=[UIImage imageWithPDFNamed:imageName atWidth:size.width];
    }else if(size.width==0){
        pdfImage=[UIImage imageWithPDFNamed:imageName atHeight:size.height];
    }else{
        pdfImage=[UIImage imageWithPDFNamed:imageName atSize:size];
    }
    
    
    pdfImage=[pdfImage tintedImageWithColor:color style:UIImageTintedStyleKeepingAlpha];
    
    return pdfImage;
    
}


+(UIImage *) nonColorimageWithPDFNamed:(NSString *)resourceName atSize:(CGSize)size{
    return [UIImage imageWithPDFNamed:resourceName atSize:size];
}


+(UIButton*)styleNavButtonForID:(NSString*)imageName atSize:(CGSize)size{
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, size.width,size.height)];
    [button setImage:[UIImage colorPDFImageForID:imageName atSize:size withTint:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button setImage:[UIImage colorPDFImageForID:imageName atSize:size withTint:[UIColor grayColor]] forState:UIControlStateHighlighted];
    
    return button;
    
}


+(void)styleExistingNavButton:(UIButton*)button forID:(NSString*)imageName atSize:(CGSize)size{
	
	[button setImage:[UIImage colorPDFImageForID:[NSString stringWithFormat:@"%@.pdf",imageName] atSize:size withTint:[UIColor whiteColor]] forState:UIControlStateNormal];
	[button setImage:[UIImage colorPDFImageForID:[NSString stringWithFormat:@"%@.pdf",imageName] atSize:size withTint:[UIColor grayColor]] forState:UIControlStateHighlighted];
	[button setImage:[UIImage colorPDFImageForID:[NSString stringWithFormat:@"%@-selected.pdf",imageName] atSize:size withTint:[UIColor whiteColor]] forState:UIControlStateSelected];
	
	
}

@end
