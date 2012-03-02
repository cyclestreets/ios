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
	CLLocationCoordinate2D coordinate;
    
}
@property (nonatomic, retain) UIImage		* image;
@property (nonatomic, assign) CLLocationCoordinate2D		 coordinate;

- (id)initWithImage:(UIImage *)newImage;

- (NSData *)fullData;

- (NSData *)uploadData;


@end
