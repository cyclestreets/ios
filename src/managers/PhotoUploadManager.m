//
//  PhotoUploadManager.m
//  CycleStreets
//
//  Created by neil on 13/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoUploadManager.h"
#import "UploadPhotoVO.h"
#import "ValidationVO.h"
#import "UserAccount.h"
#import "GlobalUtilities.h"
#import "HudManager.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import "CycleStreets.h"
#import "SettingsManager.h"


@interface PhotoUploadManager(Private)

-(void)UserPhotoUploadResponse:(ValidationVO*)validation;

@end


@implementation PhotoUploadManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoUploadManager);



-(void)listNotificationInterests{
    
    [notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	[self addRequestID:UPLOADUSERPHOTO];
	
	[super listNotificationInterests];
    
    
}

-(void)didReceiveNotification:(NSNotification *)notification{
    
    [super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	NetResponse		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		if([notification.name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
			
			if ([response.dataid isEqualToString:UPLOADUSERPHOTO]) {
				
				[self UserPhotoUploadResponse:response.dataProvider];
				
			}
			
		}
		
		
		
	}
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
	}

    
    
}

//
/***********************************************
 * @description			Upload methods
 ***********************************************/
//

-(void)UserPhotoUploadRequest:(UploadPhotoVO*)photo{
    
   
    NSMutableDictionary *getparameters=[NSMutableDictionary dictionaryWithObject:[CycleStreets sharedInstance].APIKey forKey:@"key"];
										
    NSMutableDictionary *postparameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [UserAccount sharedInstance].user.username, @"username",
                                     [UserAccount sharedInstance].userPassword,@"password",
                                     BOX_FLOAT(photo.location.coordinate.latitude),@"latitude",
                                     BOX_FLOAT(photo.location.coordinate.longitude),@"longitude",
                                     photo.description,@"caption",
                                     photo.metaCategory,@"metaCategory",
                                     photo.category,@"category",
                                     photo.dateTime,@"dateTime",
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
	[dict release];
	[request release];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Uploading Photo" andMessage:nil];
	
                                     
    
    
}


-(void)UserPhotoUploadResponse:(ValidationVO*)validation{
    
    
    
    
}

@end
