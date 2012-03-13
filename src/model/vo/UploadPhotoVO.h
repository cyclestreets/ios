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
	CLLocation *location; // location from photo
    CLLocation *userLocation; // location from user
    
    NSString    *category;
    NSString    *metaCategory;
    
    NSDate      *date;
    
    
}
@property (nonatomic, retain)	UIImage			*image;
@property (nonatomic, retain)	CLLocation			*location;
@property (nonatomic, retain)	CLLocation			*userLocation;
@property (nonatomic, retain)	NSString			*category;
@property (nonatomic, retain)	NSString			*metaCategory;
@property (nonatomic, retain)	NSDate			*date;

@property (nonatomic, readonly) int		 width;
@property (nonatomic, readonly) int		 height;
@property (nonatomic,readonly) NSString     *dateTime;

- (id)initWithImage:(UIImage *)newImage;

- (NSData *)fullData;

- (NSData *)uploadData;


@end
