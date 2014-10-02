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

@interface UploadPhotoVO : NSObject
    
// properties
@property (nonatomic, strong) UIImage						* image;
@property (nonatomic, strong) CLLocation					* location;
@property (nonatomic, strong) CLLocation					* userLocation;
@property (nonatomic, strong) PhotoCategoryVO				* category;
@property (nonatomic, strong) PhotoCategoryVO				* feature;
@property (nonatomic, strong) NSString						* caption;
@property (nonatomic, assign) int							bearing;
@property (nonatomic, strong) NSDate						* date;
@property (nonatomic, strong) NSMutableDictionary			* responseDict;


// getters
@property (nonatomic, readonly) int							width;
@property (nonatomic, readonly) int							height;
@property (nonatomic, readonly) NSString					*dateString;
@property (nonatomic,readonly) NSString						*dateTime;
@property (nonatomic, readonly) CLLocation					*activeLocation;
@property (nonatomic, readonly) NSString					*uploadedPhotoId;


// methods
- (id)initWithImage:(UIImage *)newImage; // designated initialiser


- (NSData *)fullData; // full resolution image


- (NSData *)uploadData; // image based on user's settings and network speed


-(NSMutableDictionary*)uploadParams; // upload request parameters


@end
