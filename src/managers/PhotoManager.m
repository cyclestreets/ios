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

@interface PhotoManager(Private)


-(void)uploadPhotoForUserResponse:(ValidationVO*)validation;



@end



@implementation PhotoManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoManager);


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	
}


#pragma Photo Uploading
-(void)uploadPhotoForUser:(PhotoAsset*)image{
	
	
	
	
	
	
}


-(void)uploadPhotoForUserResponse:(ValidationVO*)validation{
	
	
	switch(validation.validationStatus){
		
		case 0:
		
		break;
		
		
	}
	
}


#pragma Photo Downloading

-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw{
    [self retrievePhotosForLocationBounds:ne withEdge:sw withLimit:25];
}



-(void)retrievePhotosForLocationBounds:(CLLocationCoordinate2D)ne withEdge:(CLLocationCoordinate2D)sw withLimit:(int)limit{

    CLLocationCoordinate2D centre;
    centre.latitude = (ne.latitude + sw.latitude)/2;
    centre.longitude = (ne.longitude + sw.longitude)/2;
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey,@"key",
                                     [NSNumber numberWithFloat:centre.longitude],@"longitude",
                                     [NSNumber numberWithFloat:centre.latitude],@"latitude",
                                     [NSNumber numberWithFloat:ne.latitude],@"n",
                                     [NSNumber numberWithFloat:ne.longitude],@"e",
                                     [NSNumber numberWithFloat:sw.longitude],@"s",
                                     [NSNumber numberWithFloat:sw.latitude],@"w",
                                     [NSNumber numberWithInt:13],@"zoom",
                                     @"1",@"useDom",
                                     @"300",@"thumbnailsize",
                                     [NSNumber numberWithInt:limit],@"limit",
                                      @"1",@"suppressplaceholders",
                                     @"1",@"minimaldata", 
                                     nil];
    
    NetRequest *request=[[NetRequest alloc]init];
    request.dataid=RETREIVEPHOTOS;
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
        case <#constant#>:
            <#statements#>
            break;
            
        default:
            break;
    }
    
    
    
}


@end
