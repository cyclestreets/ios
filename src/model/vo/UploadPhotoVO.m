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
#import "NSDate+Helper.h"
#import "StringUtilities.h"
#import "Reachability.h"

@implementation UploadPhotoVO
@synthesize image;
@synthesize location;
@synthesize userLocation;
@synthesize category;
@synthesize feature;
@synthesize caption;
@synthesize date;
@synthesize responseDict;
@synthesize bearing;


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
    
    self = [self init];
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

-(NSString*)dateString{
	
	if (date == nil) {
		self.date = [NSDate date];
	}
	
	return [NSDate stringFromDate:date withFormat:[NSDate shortFormatString]]; 
	
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


-(CLLocation*)activeLocation{
	
	if(userLocation!=nil){
		return userLocation;
	}
	return location;
}


-(NSString*)uploadedPhotoId{
	
	if(responseDict!=nil){
		
		NSString *idstring=[StringUtilities pathStringFromURL:[responseDict objectForKey:@"url"] :@"/"];
		return idstring;
	}
	return nil;
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
		
		Reachability *reachability=[Reachability reachabilityForLocalWiFi];
		NetworkStatus status=[reachability currentReachabilityStatus];
		
		if(status==ReachableViaWiFi){
			
			scaledImage=image;git
			
		}else{
			
			 NSString *imageSize = [SettingsManager sharedInstance].dataProvider.imageSize;
			if ([imageSize isEqualToString:@"full"]) {
				scaledImage = image;
			} else {
				scaledImage = [ImageManipulator resizeImage:image destWidth:640 destHeight:480];
			}
			
		}
        
		return UIImageJPEGRepresentation( scaledImage, 0.8);		
	}
	return nil;
}



@end
