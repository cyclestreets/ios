//
//  ImageManipulator.m
//
//  Class for manipulating images.
//
//  Created by Björn Sållarp on 2008-09-11.
//  Copyright 2008 Björn Sållarp. All rights reserved.
//
//  Read my blog @ http://blog.sallarp.com
//
// Updated on 2009-04-05

#import "ImageManipulator.h"


@implementation ImageManipulator

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
			int w = img.size.width;
			int h = img.size.height;
    
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
			CGContextBeginPath(context);
			CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
			addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
			CGContextClosePath(context);
			CGContextClip(context);
    
			CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
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
	bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
	
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
