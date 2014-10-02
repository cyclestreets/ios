//
//  UploadPhotoVO.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "UploadPhotoVO.h"
#import "ImageUtilties.h"
#import "SettingsManager.h"
#import "NSDate+Helper.h"
#import "StringUtilities.h"
#import "Reachability.h"
#import "GlobalUtilities.h"

@implementation UploadPhotoVO


//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
		
		_bearing=0;
		
		
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
    if (_image!=nil) {
        return _image.size.width;
    }
    return 0;
}

-(int)height{
    if (_image!=nil) {
        return _image.size.height;
    }
    return 0;
}

-(NSString*)dateString{
	
	if (_date == nil) {
		self.date = [NSDate date];
	}
	
	return [NSDate stringFromDate:_date withFormat:[NSDate shortFormatString]]; 
	
}


//
/***********************************************
 * @description			
 ***********************************************/
//

-(NSString*)dateTime{
    
	if (_date == nil) {
		self.date = [NSDate date];
	}
	int delta = [[NSNumber numberWithDouble:[_date timeIntervalSince1970]] intValue];
	NSString *time = [NSString stringWithFormat:@"%i", delta];
	
    return time;
    
}


-(CLLocation*)activeLocation{
	
	if(_userLocation!=nil){
		return _userLocation;
	}
	return _location;
}


-(NSString*)uploadedPhotoId{
	
	if(_responseDict!=nil){
		
		NSString *idstring=[StringUtilities pathStringFromURL:[_responseDict objectForKey:@"url"] :@"/"];
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
	if (_image) {
		return UIImagePNGRepresentation( _image);		
	} else {
		return nil;
	}
}


- (NSData *)uploadData {
	if (_image) {
		
		UIImage *scaledImage;
		
		Reachability *reachability=[Reachability reachabilityForLocalWiFi];
		NetworkStatus status=[reachability currentReachabilityStatus];
		
		if(status==ReachableViaWiFi){
			
			scaledImage=_image;
			
		}else{
			
			 NSString *imageSize = [SettingsManager sharedInstance].dataProvider.imageSize;
			if ([imageSize isEqualToString:@"full"]) {
				scaledImage = _image;
			} else {
				scaledImage = [ImageUtilties resizeImage:_image destWidth:640 destHeight:480];
			}
			
		}
        
		return UIImageJPEGRepresentation( scaledImage, 0.8);		
	}
	return nil;
}


#pragma mark - Upload dictionary 

-(NSMutableDictionary*)uploadParams{
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionary];
	
	parameters[@"latitude"]=[NSString stringWithFormat:@"%@", BOX_FLOAT(self.activeLocation.coordinate.latitude)];
	parameters[@"longitude"]=[NSString stringWithFormat:@"%@",BOX_FLOAT(self.activeLocation.coordinate.longitude)];
	parameters[@"caption"]=_caption==nil ? EMPTYSTRING : _caption;
	parameters[@"category"]=_feature.tag;
	parameters[@"metacategory"]=_category.tag;
	parameters[@"datetime"]=self.dateTime;
	parameters[@"bearing"]= [NSString stringWithFormat:@"%i",_bearing];
	parameters[@"imageData"]= [self uploadData];
	
	return parameters;
}



@end
