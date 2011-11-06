//
//  PhotoManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 13/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "PhotoManager.h"
#import "UserAccount.h"
#import "PhotoAsset.h"
#import "ValidationVO.h"
#import "CycleStreets.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import "UserVO.h"
#import "GlobalUtilities.h"
#import "HudManager.h"

@interface PhotoManager(Private)


-(void)uploadPhotoForUserResponse:(ValidationVO*)validation;
-(void)retrievePhotosForLocationResponse:(ValidationVO*)validation;



@end



@implementation PhotoManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoManager);
@synthesize locationPhotoList;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [locationPhotoList release], locationPhotoList = nil;
	
    [super dealloc];
}



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
				
				[self uploadPhotoForUserResponse:response.dataProvider];
				
			}
			
		}
		
	}
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
	}
	
	
}




#pragma Photo Downloading

-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw{
    [self retrievePhotosForLocationBounds:ne withEdge:sw withLimit:25];
}



-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw withLimit:(int)limit{
	
	BetterLog(@"");

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
    [dict release];
    [request release];


}





-(void)retrievePhotosForLocationResponse:(ValidationVO*)validation{
    
    
    switch (validation.validationStatus) {
            
        case ValidationRetrievePhotosSuccess:
			
			self.locationPhotoList=[validation.responseDict objectForKey:RETREIVELOCATIONPHOTOS];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:RETREIVELOCATIONPHOTOSRESPONSE object:nil userInfo:nil];
            
		break;
          
		case ValidationRetrievePhotosFailed:
            
		break;
        default:
			
		break;
    }
    
    
}


#pragma mark Photo Uploading

-(void)uploadPhotoForUser:(UserVO*)user withImage:(NSData*)imageData andProperties:(NSMutableDictionary*)postparameters{
    
    
    [postparameters setValue:user.username forKey:@"username" ];
    [postparameters setValue:user.password forKey:@"password" ];
    
    NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",imageData,@"imageData", nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=UPLOADUSERPHOTO;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
    
    
}


-(void)uploadPhotoForUserResponse:(ValidationVO*)validation{
	
	
	switch(validation.validationStatus){
            
		case ValidationUserPhotoUploadSuccess:
            
        break;
			
		case ValidationUserPhotoUploadFailed:
            
		break;
            
            
	}
	
}



@end
