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



+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle
{
	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	/*
	 CGRect imageRect = CGRectMake(0, 0, width,height);
	 UIGraphicsBeginImageContext( imageRect.size );
	 [imgRef drawInRect:CGRectMake(1,1,imageRect.size.width-2,imageRect.size.height-2)];
	 imageRect = UIGraphicsGetImageFromCurrentImageContext();
	 UIGraphicsEndImageContext();
	 */
	
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGBitmapAlphaInfoMask);
	
	
	
	
	CGContextSetAllowsAntialiasing(bmContext, FALSE);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
	CGContextTranslateCTM(bmContext,
						  -(rotatedRect.size.width/2),
						  -(rotatedRect.size.height/2));
	CGContextDrawImage(bmContext, CGRectMake(0, 0,
											 rotatedRect.size.width,
											 rotatedRect.size.height),
					   imgRef);
	
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
	
	return rotatedImage;
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+(UIImage *)newRoundCornerImage : (UIImage*) img : (int) cornerWidth : (int) cornerHeight
{
	UIImage * newImage = nil;
	
	if( nil != img)
	{
		@autoreleasepool {
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGImageRef imageRef = CGImageCreateCopy([img CGImage]);
			
			size_t width = CGImageGetWidth(imageRef);
			size_t height = CGImageGetHeight(imageRef);
			size_t bytesPerRow = 8*width;
			
			CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, (kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst));
			
			CGContextBeginPath(context);
			CGRect rect = CGRectMake(0, 0, width, height);
			addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
			CGContextClosePath(context);
			CGContextClip(context);
			
			CGContextDrawImage(context, CGRectMake(0, 0, width, height), img.CGImage);
			
			CGImageRef imageMasked = CGBitmapContextCreateImage(context);
			CGContextRelease(context);
			CGColorSpaceRelease(colorSpace);
			//[img release];
			
			
			newImage = [UIImage imageWithCGImage:imageMasked];
			CGImageRelease(imageMasked);
			
		}
	}
	
    return newImage;
}


+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	//create a context to do our clipping in
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect( currentContext, clippedRect);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	//draw the image to our clipped context using our offset rect
	CGContextTranslateCTM(currentContext, 0.0, drawRect.size.height);
	CGContextScaleCTM(currentContext, 1.0, -1.0);
	CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

// resizes image to size maintaing aspect ie biases to one dimension
+(UIImage *)resizeImage:(UIImage *)itemimage destWidth:(int)imagewidth destHeight:(int)imageheight {
	int w = itemimage.size.width;
    int h = itemimage.size.height;
	
	CGImageRef imageRef = [itemimage CGImage];
	
	int width, height;
	
	if(w > h){
		width = imagewidth;
		height = h*imagewidth/w;
	} else {
		height = imageheight;
		width = w*imageheight/h;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef bitmap;
	bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGBitmapAlphaInfoMask);
	
	if (itemimage.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, M_PI/2);
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (itemimage.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, -M_PI/2);
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (itemimage.imageOrientation == UIImageOrientationUp) {
		
	} else if (itemimage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, -M_PI);
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;
}

@end
