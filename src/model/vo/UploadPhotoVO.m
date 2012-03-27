//
//  UploadPhotoVO.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "UploadPhotoVO.h"
#import "ImageManipulator.h"
#import "SettingsManager.h"

@implementation UploadPhotoVO
@synthesize image;
@synthesize location;
@synthesize userLocation;
@synthesize category;
@synthesize metaCategory;
@synthesize date;
@synthesize responseDict;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [image release], image = nil;
    [location release], location = nil;
    [userLocation release], userLocation = nil;
    [category release], category = nil;
    [metaCategory release], metaCategory = nil;
    [date release], date = nil;
    [responseDict release], responseDict = nil;
    
    [super dealloc];
}




//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}




- (id)initWithImage:(UIImage *)newImage{
    
    [self init];
    self.image=newImage;
    
    return self;
}


//
/***********************************************
 * @description			getters
 ***********************************************/
//

-(int)width{
    if (image!=nil) {
        return image.size.width;
    }
    return 0;
}

-(int)height{
    if (image!=nil) {
        return image.size.height;
    }
    return 0;
}


//
/***********************************************
 * @description			
 ***********************************************/
//

-(NSString*)dateTime{
    
	if (date == nil) {
		self.date = [NSDate date];
	}
	int delta = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] intValue];
	NSString *time = [NSString stringWithFormat:@"%i", delta];
	
    return time;
    
}

//
/***********************************************
 * @description			Image data
 ***********************************************/
//

- (NSData *)fullData {
	if (image) {
		return UIImagePNGRepresentation( image);		
	} else {
		return nil;
	}
}


- (NSData *)uploadData {
	if (image) {
        
        UIImage *scaledImage;
        NSString *imageSize = [SettingsManager sharedInstance].dataProvider.imageSize;
        if ([imageSize isEqualToString:@"full"]) {
            scaledImage = image;
        } else {
            scaledImage = [ImageManipulator resizeImage:image destWidth:640 destHeight:480];
        }
		return UIImageJPEGRepresentation( scaledImage, 0.8);		
	}
	return nil;
}



@end
