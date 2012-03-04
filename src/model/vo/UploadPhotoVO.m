//
//  UploadPhotoVO.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "UploadPhotoVO.h"

@implementation UploadPhotoVO
@synthesize image;
@synthesize location;


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

//NE:  TODO: should return settings sized image
- (NSData *)uploadData {
	if (image) {
		return UIImageJPEGRepresentation( image, 0.8);		
	}
	return nil;
}



@end
