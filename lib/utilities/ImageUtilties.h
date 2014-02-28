//
//  ImageUtilties.h
//  CycleStreets
//
//  Created by Neil Edwards on 06/11/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtilties : NSObject


- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor;

+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;

+(UIImage *)newRoundCornerImage:(UIImage*)img :(int) cornerWidth :(int) cornerHeight;
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
+(UIImage *)resizeImage:(UIImage *)itemimage destWidth:(int)imagewidth destHeight:(int)imageheight;



@end
