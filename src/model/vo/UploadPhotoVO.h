//
//  UploadPhotoVO.h
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UploadPhotoVO : NSObject{
    
    UIImage *image;
	CLLocation *location;
    
}
@property (nonatomic, retain) UIImage		* image;
@property (nonatomic, assign) CLLocation    *location;

@property (nonatomic, readonly) int		 width;
@property (nonatomic, readonly) int		 height;


- (id)initWithImage:(UIImage *)newImage;

- (NSData *)fullData;

- (NSData *)uploadData;


@end
