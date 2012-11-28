//
//  PhotoManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoManager.h"
#import "UserAccount.h"
#import "ValidationVO.h"
#import "CycleStreets.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import "UserVO.h"
#import "GlobalUtilities.h"
#import "HudManager.h"

@interface PhotoManager(Private)

-(void)UserPhotoUploadResponse:(ValidationVO*)validation;

-(void)uploadPhotoForUserResponse:(ValidationVO*)validation;


-(void)retrievePhotosForLocationResponse:(ValidationVO*)validation;

-(void)stopRetreivingPhotos;

@end



@implementation PhotoManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoManager);
@synthesize uploadPhoto;
@synthesize autoLoadLocation;
@synthesize locationPhotoList;
@synthesize showingHUD;
@synthesize retreiveTimer;


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	[self addRequestID:RETREIVELOCATIONPHOTOS];
	[self addRequestID:UPLOADUSERPHOTO];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	NetResponse		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		if([notification.name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
			
			if ([response.dataid isEqualToString:RETREIVELOCATIONPHOTOS]) {
				
				[self retrievePhotosForLocationResponse:response.dataProvider];
				
			}else if ([response.dataid isEqualToString:UPLOADUSERPHOTO]) {
				
				[self UserPhotoUploadResponse:response.dataProvider];
				
			}
			
		}
		
	}
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
		
		if([dataid isEqualToString:RETREIVELOCATIONPHOTOS]){
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:ERROR,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:dict userInfo:nil];
		}
	}
	
	
}




#pragma Photo Downloading

-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw{
    [self retrievePhotosForLocationBounds:ne withEdge:sw withLimit:25];
}



-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw withLimit:(int)limit{
	
	BetterLog(@"");
	
	if(showingHUD==NO){
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"" andMessage:nil andDelay:0 andAllowTouch:NO];
		showingHUD=YES;
	}

    CLLocationCoordinate2D centre;
    centre.latitude = (ne.latitude + sw.latitude)/2;
    centre.longitude = (ne.longitude + sw.longitude)/2;
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey,@"key",
                                     [NSNumber numberWithFloat:centre.longitude],@"longitude",
                                     [NSNumber numberWithFloat:centre.latitude],@"latitude",
                                     [NSNumber numberWithFloat:ne.latitude],@"n",
                                     [NSNumber numberWithFloat:ne.longitude],@"e",
                                     [NSNumber numberWithFloat:sw.latitude],@"s",
                                     [NSNumber numberWithFloat:sw.longitude],@"w",
                                     [NSNumber numberWithInt:13],@"zoom",
                                     @"1",@"useDom",
                                     @"300",@"thumbnailsize",
                                     [NSNumber numberWithInt:limit],@"limit",
                                      @"1",@"suppressplaceholders",
                                     @"1",@"minimaldata", 
                                     nil];
    
    NetRequest *request=[[NetRequest alloc]init];
    request.dataid=RETREIVELOCATIONPHOTOS;
    request.requestid=ZERO;
    request.parameters=parameters;
    request.revisonId=0;
    request.source=USER;
    
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];


}





-(void)retrievePhotosForLocationResponse:(ValidationVO*)validation{
	
	if(showingHUD==YES){
		if(retreiveTimer!=nil){
			[retreiveTimer invalidate];
			retreiveTimer=nil;
		}
		
		self.retreiveTimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(assesRetrievedComplete) userInfo:nil repeats:NO];
	}
	
	    
    switch (validation.validationStatus) {
            
        case ValidationRetrievePhotosSuccess:
		{	
			self.locationPhotoList=[validation.responseDict objectForKey:RETREIVELOCATIONPHOTOS];
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:SUCCESS,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:dict userInfo:nil];
		}   
		break;
          
		case ValidationRetrievePhotosFailed:
		{	
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:ERROR,@"status", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:dict userInfo:nil];
        
		}
		break;
        default:
			
		break;
    }
    
    
}

-(void)assesRetrievedComplete{
	
	if(showingHUD==YES){
		[retreiveTimer invalidate];
		[[HudManager sharedInstance]removeHUD:NO];
		showingHUD=NO;
	}
}

//
/***********************************************
 * @description			Upload methods
 ***********************************************/
//

-(void)UserPhotoUploadRequest:(UploadPhotoVO*)photo{
    
    self.uploadPhoto=photo;
	CLLocation *location=photo.activeLocation;
    
    NSMutableDictionary *getparameters=[NSMutableDictionary dictionaryWithObject:[CycleStreets sharedInstance].APIKey forKey:@"key"];
    
    NSMutableDictionary *postparameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [UserAccount sharedInstance].user.username, @"username",
                                         [UserAccount sharedInstance].userPassword,@"password",
										 [NSString stringWithFormat:@"%@", BOX_FLOAT(location.coordinate.latitude)],@"latitude",
                                         [NSString stringWithFormat:@"%@",BOX_FLOAT(location.coordinate.longitude)],@"longitude",
                                         photo.caption,@"caption",
                                         photo.feature.tag,@"category", // note: conversion to serverside types
                                         photo.category.tag,@"metacategory", //
                                         photo.dateTime,@"datetime",
										 photo.bearing,@"bearing",
                                         [photo uploadData],@"imageData",
										 nil];
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:getparameters,@"getparameters",postparameters,@"postparameters", nil];
    
    NetRequest *request=[[NetRequest alloc]init];
	request.dataid=UPLOADUSERPHOTO;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	request.trackProgress=YES;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Uploading Photo" andMessage:nil];
	
    
    
    
}


-(void)UserPhotoUploadResponse:(ValidationVO*)validation{
	
	BetterLog(@"");
    
    switch(validation.validationStatus){
            
		case ValidationUserPhotoUploadSuccess:
		{
            uploadPhoto.responseDict=validation.responseDict;
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:UPLOADUSERPHOTORESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Photo uploaded" andMessage:nil];
         
		}
		break;
			
		case ValidationUserPhotoUploadFailed:
		{	
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,validation.returnMessage,MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:UPLOADUSERPHOTORESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Photo upload failed" andMessage:nil];
		}   
		break;
			
		default:
			[[HudManager sharedInstance]removeHUD];
		break;
            
            
	}

}



-(BOOL)isUserPhoto:(PhotoMapVO*)photo{
	
	if(uploadPhoto==nil)
		return NO;
	
	if(uploadPhoto.responseDict!=nil){
		
		NSString *uploadid=uploadPhoto.uploadedPhotoId;
		
		if([photo.csid isEqualToString:uploadid]){
			return YES;
		}
	}
	
	return NO;
}



@end
