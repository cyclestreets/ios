//
//  ImageManipulator.h
//
//  Class for manipulating images.
//
//  Created by Björn Sållarp on 2008-09-11.
//  Copyright 2008 Björn Sållarp. All rights reserved.
//
//  Read my blog @ http://blog.sallarp.com
//
// Updated on 2009-04-05

#import <UIKit/UIKit.h>


@interface ImageManipulator : NSObject {

}

+(UIImage *)newRoundCornerImage:(UIImage*)img :(int) cornerWidth :(int) cornerHeight;
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
+(UIImage *)resizeImage:(UIImage *)itemimage destWidth:(int)imagewidth destHeight:(int)imageheight;
@end
