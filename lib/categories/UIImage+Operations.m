//
//  UIImage-Rotations.m
//  OCRReader
//
//  Created by Tomasz Krasnyk on 1/21/10.
//  Copyright 2010 Polidea. All rights reserved.
//
//  version 1.0

#import "UIImage+Operations.h"


static int temporaryImageAngle;
static inline CGFloat toRadians (CGFloat degrees) { return degrees * M_PI/180.0f; }

//images on iPhone should be no bigger than 1024, making images bigger than 1024 may cause crashes caused by not enough memory
#define maximumResultImageSize 1024
//indicates how many lines we check, when put 40 in here, 1 line is checked, 40th line, 80th line and so on
//the bigger the number the less concrete the result but faster detection
#define lineCheckingStep 40


@implementation UIImage(Operations)
#pragma mark -
#pragma mark Conversion/detection
//converts each UIImage to UIImage with grayscale palette, 8 bits per pixel wide
+ (UIImage *) convertTo8bppGrayscaleFromImage:(UIImage *) uimage {
	return [UIImage convertTo8bppGrayscaleFromImage:uimage scaleToMaximumSize:-1];
}

//if maxSize
+ (UIImage *) convertTo8bppGrayscaleFromImage:(UIImage *) uimage scaleToMaximumSize:(NSInteger) maxSize {
	int iwidth = uimage.size.width;
	int iheight = uimage.size.height;
	int maxFromHeightAndWidth = MAX(iwidth, iheight);
	float scaleFactor = maxSize / (float)maxFromHeightAndWidth;
	if(maxSize == -1){
		scaleFactor = 1.0f;
		if(maxFromHeightAndWidth > maximumResultImageSize){
			scaleFactor = maximumResultImageSize / (float) maxFromHeightAndWidth;
		}
	}
	
	int newImageWidth = iwidth*scaleFactor;
	int newImageHeight = iheight*scaleFactor;
	NSAssert(newImageWidth != 0 && newImageHeight != 0, @"Attempt to create 0x0 image");
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	uint8_t *pixels = (uint8_t *) malloc(newImageWidth * newImageHeight * sizeof(pixels));
	NSAssert(pixels, @"not enought memory to alloc data for converted image");
	
	CGContextRef context = CGBitmapContextCreate(pixels, newImageWidth, newImageHeight, 8, newImageWidth * sizeof(uint8_t), colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNone);
	CGContextDrawImage(context, CGRectMake(0, 0, newImageWidth, newImageHeight), uimage.CGImage);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
	
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	
    // we're done with image now too
    CGImageRelease(image);
	
	int bitsPerPixel = CGImageGetBitsPerPixel(resultUIImage.CGImage);
	NSAssert(bitsPerPixel == 8, @"Converted image doesn't have 8 bits per pixel size!");
    return resultUIImage;
}
/*
 Returns an array made with Bresenham's algorithm, each cell of the array represents the following line, value is the number of pixels that should be taken from this line
 */
+ (int *) newNumOfPixelsInEachLineForWidth:(NSInteger) w andAngle:(NSInteger) ang {
	int *cntTable = (int *)malloc(sizeof(int)*(ang+1));
	
	
	NSInteger dLong = w; 
	NSInteger dShort = ang; 
	
	NSInteger err = 3*dShort - 2*dLong; 
	NSInteger cLong = 0; 
	NSInteger cShort = 0; 
	cntTable[cShort] = 1;
	
	while (cLong < dLong) { 
		if (err >= 0) { 
			err -= 2*(dLong - dShort); 
			++cShort;
			cntTable[cShort] = 0;
		} else {
			err += 2*dShort; 			
		}
		++cLong;
		++cntTable[cShort];
	}
	
	return cntTable;
}

//gives number of black pixels in skewed line with angle == [array count], for values given by bres array
+ (NSInteger) getBlackPixelsInLine:(NSInteger) lineNumber forImage:(UIImage *) image withBresArray:(int *) array andTreshold:(unsigned char) blackTreshold negativeAngle:(BOOL)negative {
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
	NSInteger bytesPerLine = CGImageGetBytesPerRow(image.CGImage);
	unsigned char *rawData = (unsigned char *)CFDataGetBytePtr(data);
	
	NSInteger blacks = 0;
	NSInteger offsetInLine = 0;
	unsigned char *ptrToStartLine = (rawData + bytesPerLine*lineNumber);
	NSInteger linesSkewNumber = temporaryImageAngle;
	for(NSInteger i = 0; i < linesSkewNumber; ++i){	//lines
		NSInteger pixelsToTake = array[i];
		for(NSInteger j = 0; j < pixelsToTake && offsetInLine < CGImageGetWidth(image.CGImage); ++j, ++offsetInLine){
			NSInteger lineOffsetFromStartLine = bytesPerLine*i;
			if(negative){
				lineOffsetFromStartLine = bytesPerLine * (linesSkewNumber-1-i);
			}
			NSAssert(lineOffsetFromStartLine >= 0, @"line offset can't be negative!");
			unsigned char pixelValue = *(ptrToStartLine + lineOffsetFromStartLine + offsetInLine);
			if(pixelValue < blackTreshold){
				++blacks;
			}
		}
	}
	if(data != NULL){
		CFRelease(data);
	}
	return blacks;
}

//image that is given here has to be 8bpp in greyscale colorSpace
//function counts black pixels for given angle MODULE(it checks for -ang and +ang) and returned value(its module: abs(...)) gives u the number of blacks that have been found(maximum)
//if returned value is positive than, maximum blacks number returned are counted for positive angle otherwise for negative
+ (NSInteger) getBlackPercentageForAngle:(NSInteger) ang forImageData:(UIImage *)image andBlackTreshold:(unsigned char) blackTreshold {
	
	NSInteger iwidth = CGImageGetWidth(image.CGImage);
	NSInteger iheight = CGImageGetHeight(image.CGImage);
	NSInteger blackPixels = 0;
	NSInteger blackPixelsForNegative = 0;
	NSInteger numberOfLineChecked = 0;
	
	//get array with number of pixels in each line that should be taken to account - Bresenham's algorithm
	int *bresArray = [UIImage newNumOfPixelsInEachLineForWidth:iwidth andAngle:ang];
	temporaryImageAngle = ang;
	NSInteger lineStep = 40;
	
	for(NSInteger i = 0; i < iheight - ang; i += lineStep){
		NSInteger blacksInSkeyLine = [UIImage getBlackPixelsInLine:i forImage:image withBresArray:bresArray andTreshold:blackTreshold negativeAngle:NO];
		blackPixels += pow(blacksInSkeyLine, 2);
		blacksInSkeyLine = [UIImage getBlackPixelsInLine:i forImage:image withBresArray:bresArray andTreshold:blackTreshold negativeAngle:YES];
		blackPixelsForNegative += pow(blacksInSkeyLine, 2);
		++numberOfLineChecked;
	}
	free(bresArray);
	NSAssert(numberOfLineChecked, @"Division by zero is not allowed!");
	NSInteger maximumPixels = MAX(blackPixels, blackPixelsForNegative);
	if(blackPixelsForNegative > blackPixels){
		maximumPixels = -maximumPixels;
	}
	
	return (maximumPixels / numberOfLineChecked);
}

+ (NSInteger) degrees:(CGFloat) degrees inPixelsForImage:(UIImage *) image {
	return image.size.width * tanf(toRadians(degrees));
}

+ (CGFloat) detectSkewOfTheImage:(UIImage *) image withDegreesRangeMinimum:(CGFloat) degMinimum andDegreesMaximum:(CGFloat) degMaximum degreesStep:(CGFloat) degStep { 
	if(CGImageGetBitsPerPixel(image.CGImage) != 8){
		image = [UIImage convertTo8bppGrayscaleFromImage:image];
	}
	unsigned char blackTreshold = 0xFF >> 1;	//half of the 256 will be used as the border between black and white
	
	
	NSInteger detectedAngleInPixels = 0;
	NSInteger percentOfBlacksForDetectedAngle = 0;
	
	NSInteger currentCheckingAngleInPixels = [UIImage degrees:degMinimum inPixelsForImage:image];
	NSInteger maximumCheckingAngleInPixels = [UIImage degrees:degMaximum inPixelsForImage:image];
	
	NSInteger stepAngle = [UIImage degrees:degStep inPixelsForImage:image];
	for(; currentCheckingAngleInPixels < maximumCheckingAngleInPixels && currentCheckingAngleInPixels < image.size.height; currentCheckingAngleInPixels += stepAngle){
		NSInteger blackPercentageForGivenAngle = [UIImage getBlackPercentageForAngle:currentCheckingAngleInPixels forImageData:image andBlackTreshold:blackTreshold];
		if(abs(blackPercentageForGivenAngle) > percentOfBlacksForDetectedAngle){
			percentOfBlacksForDetectedAngle = abs(blackPercentageForGivenAngle);
			detectedAngleInPixels = currentCheckingAngleInPixels;
			if(blackPercentageForGivenAngle < 0){
				detectedAngleInPixels = -detectedAngleInPixels;
			}
		}
		//can be enabled so that we stop searching the skew when we experience decreasing numbers of black pixels
		/*if(blackPercentageForGivenAngle < percentOfBlacksForDetectedAngle){
		 break;
		 }*/
	}
	CGFloat imageWidth = CGImageGetWidth(image.CGImage);
	CGFloat angle = atanf((CGFloat)detectedAngleInPixels / imageWidth)* 180 /M_PI;
	return angle;
}


#pragma mark -
#pragma mark Rotation
+ (unsigned char) avarageColorOfThe8bppImageBorder:(UIImage *) image {
	NSAssert(image, @"can't find average color of nil image");
	NSInteger bpp = CGImageGetBitsPerPixel(image.CGImage);
	if(bpp != 8){
		//NSLog(@"WARNING: average color of the image border can't be calculated for images having more than 8bpp(yours is %dbpp). Converting to grayscale first.", bpp);
		image = [UIImage convertTo8bppGrayscaleFromImage:image];
	}
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
	unsigned char *rawData = (unsigned char *) CFDataGetBytePtr(data);
	NSInteger height = image.size.height;
	NSInteger width = image.size.width;
	NSInteger bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
	
	NSInteger avarageColor = 0;
	NSInteger samplesTakenInHorizontal = width  >> 1;
	NSInteger samplesTakenInVertical = height  >> 1;
	
	NSInteger w, h; //random
	h = 0;
	unsigned char c;
	for(NSInteger i = 0; i < samplesTakenInHorizontal; i+=2){
		//top line border
		h = 0;
		w = arc4random() % width;
		c = *(rawData + bytesPerRow*h + w);
		avarageColor += c;
		//bottom line
		h = height - 1;
		w = arc4random() % width;
		c = *(rawData + bytesPerRow*h + w);
		avarageColor += c;
	}
	for(NSInteger i = 0; i < samplesTakenInVertical; i += 2){
		//left line
		w = 0;
		h = arc4random() % height;
		c = *(rawData + bytesPerRow*h + w);
		avarageColor += c;
		//right line
		w = width - 1;
		h = arc4random() % height;
		c = *(rawData + bytesPerRow*h + w);
		avarageColor += c;
	}
	avarageColor = avarageColor / (samplesTakenInVertical+samplesTakenInHorizontal);
	if(data != NULL){
		CFRelease(data);
	}
	return avarageColor;
}

//if degrees < 0 than rotation is clockWise, otherwise CounterClockWise
+ (CGPoint) rotatePoint:(CGPoint)point byDegrees:(CGFloat) degrees aroundOriginPoint:(CGPoint) origin {
	CGPoint rotated = CGPointMake(0.0f, 0.0f);
	CGFloat radians = toRadians(degrees);
	rotated.x = cos(radians) * (point.x-origin.x) - sin(radians) * (point.y-origin.y) + origin.x;
	rotated.y = sin(radians) * (point.x-origin.x) + cos(radians) * (point.y-origin.y) + origin.y;
	return rotated;
}


+ (CGPoint) getPointAtIndex:(NSUInteger) index ofRect:(CGRect) rect {
	NSAssert1(index >= 0 && index < 4, @"Rectangle has 4 corners, index should be between [0,3], u passed %lu", index);
	CGPoint point = rect.origin;
	if(index == 1){
		point.x += CGRectGetWidth(rect);
	} else if(index == 2){
		point.y += CGRectGetHeight(rect);
	} else if(index == 3){
		point.y += CGRectGetHeight(rect);
		point.x += CGRectGetWidth(rect);
	}
	
	return point;
}

+ (CGSize) imageSizeForRect:(CGRect) rect rotatedByDegreees:(CGFloat) degrees {
	CGPoint rotationOrigin = CGPointMake(0.0f, 0.0f);
	CGFloat maxX = 0, minX = INT_MAX, maxY = 0, minY = INT_MAX;
	
	for(NSInteger i = 0; i < 4; ++i){
		CGPoint toRotate = [UIImage getPointAtIndex:i ofRect:rect];
		CGPoint rotated = [UIImage rotatePoint:toRotate byDegrees:degrees aroundOriginPoint:rotationOrigin];
		minX = MIN(minX, rotated.x);
		minY = MIN(minY, rotated.y);
		maxX = MAX(maxX, rotated.x);
		maxY = MAX(maxY, rotated.y);
	}
	CGSize newSize = CGSizeMake(maxX - minX, maxY - minY);
	return newSize;
}

//clockwise when degrees < 0 ok?
+ (UIImage *) rotateImage:(UIImage *) image byDegrees:(CGFloat) degrees {
	
	
	CGSize newImageSize = [UIImage imageSizeForRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height) rotatedByDegreees:degrees];
	//if the new ImageSize will be bigger than 1024 then we need to scale the image
	CGFloat maximum = MAX(newImageSize.width, newImageSize.height);
	CGFloat scaleFactor = 1.0f;
	if(maximum > maximumResultImageSize){
		scaleFactor = maximumResultImageSize/maximum;
	}
	
	UIGraphicsBeginImageContext(CGSizeMake(newImageSize.width*scaleFactor, newImageSize.height*scaleFactor));
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	CGRect drawingRect = CGRectMake(0.0f, 0.0f, newImageSize.width*scaleFactor, newImageSize.height*scaleFactor);
	
	//unsigned char midColor = [UIImage avarageColorOfThe8bppImageBorder:image];
	
	//[[UIColor colorWithRed:midColor/255.0 green:midColor/255.0 blue:midColor/255.0 alpha:1.0f] set];
	//CGContextFillRect(context, CGRectInset(drawingRect, -2, -2));
	
	CGContextTranslateCTM(context, drawingRect.size.width/2, drawingRect.size.height/2);
	CGContextRotateCTM(context, toRadians(degrees));
	
	[image drawInRect:CGRectMake((-image.size.width*scaleFactor)/2, (-image.size.height*scaleFactor)/2, image.size.width*scaleFactor, image.size.height*scaleFactor)];
	UIGraphicsPopContext();
    UIImage *copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return copy;
}

+ (UIImage *) rotateImage:(UIImage *) src andRotateAngle:(UIImageOrientation) orientation {
    UIGraphicsBeginImageContext(src.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, toRadians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, toRadians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
		CGContextTranslateCTM(context, src.size.width, 0.0f);
        CGContextRotateCTM (context, toRadians(90));
    }
	
    [src drawAtPoint:CGPointMake(0, 0)];
	UIGraphicsPopContext();
    return UIGraphicsGetImageFromCurrentImageContext();
}
@end
