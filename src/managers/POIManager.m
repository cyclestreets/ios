//
//  POIManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POIManager.h"
#import "ValidationVO.h"
#import "CycleStreets.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import "HudManager.h"
#import "GlobalUtilities.h"
#import "DeviceUtilities.h"

@interface POIManager(Private)

-(void)POIListingDataResponse:(ValidationVO*)validation;
-(void)POICategoryDataResponse:(ValidationVO*)validation;


@end



@implementation POIManager
SYNTHESIZE_SINGLETON_FOR_CLASS(POIManager);
@synthesize dataProvider;
@synthesize categoryDataProvider;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [categoryDataProvider release], categoryDataProvider = nil;
	
    [super dealloc];
}



-(id)init{
	
	if (self = [super init])
	{
		
	}
	return self;
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
	
	[self addRequestID:POILISTING];
	[self addRequestID:POICATEGORYLOCATION];
	
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
			
			if ([response.dataid isEqualToString:POILISTING]) {
				
				[self POIListingDataResponse:response.dataProvider];
				
			}else if ([response.dataid isEqualToString:POICATEGORYLOCATION]) {
				
				[self POICategoryDataResponse:response.dataProvider];
				
			}
			
		}
		
		
		
	}
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
	}
	
}


//
/***********************************************
 * @description			DATA EVENTS
 ***********************************************/
//


// request list of all categories
-(void)requestPOIListingData{
	
	//BOOL isRetina=ISRETINADISPLAY;
	// CS API does not support 64 px icons for Retina dispaly
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key",BOX_INT(32),@"icons", nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=POILISTING;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Retrieving List" andMessage:nil];
	
	
}

-(void)POIListingDataResponse:(ValidationVO*)validation{
	
	
	switch (validation.validationStatus) {
			
		case ValidationPOIListingSuccess:
			
			self.dataProvider=[validation.responseDict objectForKey:POILISTING];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POILISTINGRESPONSE object:nil userInfo:nil];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Retrieved" andMessage:nil];
			
		break;
		
		case ValidationPOIListingFailure:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Unable to retrieve data" andMessage:nil];
			
		break;
		default:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeServer withTitle:@"Unable to retrieve data" andMessage:nil];
		
		break;
	}
	
	
	
}



// request 
-(void)requestPOICategoryDataForCategory:(POICategoryVO*)category atLocation:(CLLocationCoordinate2D)location{
	
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [[CycleStreets sharedInstance] APIKey], @"key", 
									 category.key,@"type",
									 location.longitude,@"longitude",
									 location.latitude,@"latitude",
									 BOX_INT(LOCATIONRADIUS),@"radius",BOX_INT(LOCATIONRESULTSLIMIT),@"limit",nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=POICATEGORYLOCATION;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:[NSString stringWithFormat:@"Retrieving %@s in area",category.name] andMessage:nil];
	
}


-(void)POICategoryDataResponse:(ValidationVO*)validation{
	
	
	switch (validation.validationStatus) {
			
		case ValidationPOICategorySuccess:
			
			self.categoryDataProvider=[validation.responseDict objectForKey:POICATEGORYLOCATION];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POICATEGORYLOCATIONRESPONSE object:nil userInfo:nil];
			
		break;
			
		case ValidationPOICategoryFailure:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Unable to retrieve data" andMessage:nil];
			
		break;
		default:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeServer withTitle:@"Unable to retrieve data" andMessage:nil];
			
		break;
	}
	
	
}


//
/***********************************************
 * @description			UTILITIES
 ***********************************************/
//

@end
