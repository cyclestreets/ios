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
@synthesize coordinate;


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
