//
//  LocationFeaturesManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 19/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "LocationFeaturesManager.h"
#import "ValidationVO.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import "HudManager.h"
#import "GlobalUtilities.h"
#import "CycleStreets.h"

@interface LocationFeaturesManager(Private)


-(void)retreiveFeaturesForLocationResponse:(ValidationVO*)validation;



@end



@implementation LocationFeaturesManager
SYNTHESIZE_SINGLETON_FOR_CLASS(LocationFeaturesManager);
@synthesize locationDataProvider;
@synthesize curentLocation;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [locationDataProvider release], locationDataProvider = nil;
    [curentLocation release], curentLocation = nil;
	
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
	
	[self addRequestID:LOCATIONFEATURES];
	
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
			
			if([dataid isEqualToString:LOCATIONFEATURES]){
				
				[self retreiveFeaturesForLocationResponse:response.dataProvider];
				
			}
			
		}
		
		
		
	}
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
	}
	
}


-(void)retreiveFeaturesForLocation:(CLLocation*)location{
	
	// api for this?
	
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:getparameters,@"getparameters", nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=LOCATIONFEATURES;
	request.requestid=[GlobalUtilities GUIDString];
	request.parameters=parameters;
	request.revisonId=0;
	request.source=SYSTEM;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Retrieving" andMessage:nil];
	
}


-(void)retreiveFeaturesForLocationResponse:(ValidationVO*)validation{
	
//	
//	switch (validation.validationStatus) {
//			
//		case <#constant#>:
//			<#statements#>
//			break;
//			
//		default:
//			break;
//	}
//	
//	
	
}

@end
