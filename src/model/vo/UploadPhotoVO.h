//
//  UploadPhotoVO.h
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PhotoCategoryVO.h"

@interface UploadPhotoVO : NSObject{
    
    UIImage                     *image;
	CLLocation                  *location; // location from photo
    CLLocation                  *userLocation; // location from user
    
    PhotoCategoryVO                    *category;
    PhotoCategoryVO                    *feature;
	
	NSString					*caption;
    
    NSDate                      *date;
    
    NSMutableDictionary         *responseDict;
    
}
@property (nonatomic, strong) UIImage		* image;
@property (nonatomic, strong) CLLocation		* location;
@property (nonatomic, strong) CLLocation		* userLocation;
@property (nonatomic, strong) PhotoCategoryVO		* category;
@property (nonatomic, strong) PhotoCategoryVO		* feature;
@property (nonatomic, strong) NSString		* caption;
@property (nonatomic, strong) NSDate		* date;
@property (nonatomic, strong) NSMutableDictionary		* responseDict;

// getters
@property (nonatomic, readonly) int		 width;
@property (nonatomic, readonly) int		 height;
@property (nonatomic, readonly) NSString		 *dateString;
@property (unsafe_unretained, nonatomic,readonly) NSString     *dateTime;
@property (nonatomic, readonly) CLLocation		 *activeLocation;
@property (nonatomic, readonly) NSString		 *uploadedPhotoId;

- (id)initWithImage:(UIImage *)newImage;

- (NSData *)fullData;

- (NSData *)uploadData;


@end
