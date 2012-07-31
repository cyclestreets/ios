/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  PhotoAsset.m
//  CycleStreets
//
//  Created by Alan Paxton on 23/08/2010.
//

#import "PhotoAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAsset+Info.h"
#import "WBImage.h"

@implementation PhotoAsset

- (id)initWithAsset:(ALAsset *)newAsset {
	if (self = [super init]) {
		image = nil;
		asset = newAsset;
	}
	return self;
}

- (id)initWithImage:(UIImage *)newImage withCoordinate:(CLLocationCoordinate2D)newCoordinate {
	if (self = [super init]) {
		asset = nil;
		image = newImage;
		coordinate = newCoordinate;
	}
	return self;	
}
/*
- (CGImageRef)orientImage:(CGImageRef)imageRef orientation:(ALAssetOrientation)orientation {
	int degrees = 0;
	if (orientation == ALAssetOrientationUp) {
		degrees = 0;
	} else if (orientation == ALAssetOrientationLeft) {
		degrees = 90;
	} else if (orientation == ALAssetOrientationDown) {
		degrees = 180;
	} else if (orientation == ALAssetOrientationRight) {
		degrees = 270;
	}
	CGImageRef result = imageRef;
	if (degrees != 0) {
		result = [ImageOperations CGImageRotatedByAngle:imageRef angle:degrees];
	}
	return result;
}
 */

- (UIImage *)orientImage:(UIImage *)original orientation:(ALAssetOrientation)orientation {
	UIImageOrientation imageOrientation = UIImageOrientationUp;
	if (orientation == ALAssetOrientationDown) {
		imageOrientation = UIImageOrientationDown;
	}
	if (orientation == ALAssetOrientationRight) {
		imageOrientation = UIImageOrientationRight;
	}
	if (orientation == ALAssetOrientationLeft) {
		imageOrientation = UIImageOrientationLeft;
	}
	if(orientation!=UIImageOrientationUp){
		UIImage *result = [original rotate:imageOrientation];
		return result;
	}else {
		return original;
	}

}

- (NSData *)fullData {
	if (asset) {
		ALAssetRepresentation *representation = [asset defaultRepresentation];
		CGImageRef imageRef = [representation fullResolutionImage];
		UIImage *rotatedImage = [self orientImage:[UIImage imageWithCGImage:imageRef] orientation:[representation orientation]];
		//CGImageRef imageRef = [self orientImage:[representation fullResolutionImage] orientation:[representation orientation]];
		return UIImageJPEGRepresentation(rotatedImage, 0.95);
	} else if (image) {
		return UIImageJPEGRepresentation( image, 0.95);		
	} else {
		return nil;
	}
}

//NE:  this says 640 in settings but will return 480x320 for none retina, 960x640 for retina?
- (NSData *)screenSizeData {
	if (asset) {
		ALAssetRepresentation *representation = [asset defaultRepresentation];
		CGImageRef imageRef = [representation fullScreenImage];
		UIImage *rotatedImage = [self orientImage:[UIImage imageWithCGImage:imageRef] orientation:[representation orientation]];
		//CGImageRef imageRef = [self orientImage:[representation fullScreenImage] orientation:[representation orientation]];
		return UIImageJPEGRepresentation(rotatedImage, 0.8);
	} else if (image) {
		return UIImageJPEGRepresentation( image, 0.8);		
	}
	return nil;
}

- (UIImage *)screenImage {
	if (asset) {
		ALAssetRepresentation *representation = [asset defaultRepresentation];
		return [UIImage imageWithCGImage:[representation fullScreenImage]
								   scale:[representation scale]
							 orientation:[representation orientation]];
	} else if (image) {
		return image;
	}
	return nil;
}

- (NSDate *)date {
	if (asset) {
		return [asset date];
	} else {
		return [[NSDate alloc] init];
	}
}

- (CLLocationCoordinate2D) coordinate {
	if (asset) {
		return [asset location];
	} else {
		return coordinate;
	}
}

- (void)dealloc {
	asset = nil;
	image = nil;
}

@end
