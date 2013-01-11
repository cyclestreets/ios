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

@interface POIManager()



-(void)POIListingDataResponse:(ValidationVO*)validation;
-(void)POICategoryDataResponse:(ValidationVO*)validation;


@end



@implementation POIManager
SYNTHESIZE_SINGLETON_FOR_CLASS(POIManager);
@synthesize dataProvider;
@synthesize categoryDataProvider;


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
	[self addRequestID:POIMAPLOCATION];
	
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
				
			}else if ([response.dataid isEqualToString:POIMAPLOCATION]) {
				
				[self POICategoryMapPointsResponse:response.dataProvider];
				
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
	
	BOOL isRetina=ISRETINADISPLAY;
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key",isRetina==YES ? BOX_INT(64): BOX_INT(32),@"icons", nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=POILISTING;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Retrieving List" andMessage:nil];
	
	
}

-(void)POIListingDataResponse:(ValidationVO*)validation{
	
	
	switch (validation.validationStatus) {
			
		case ValidationPOIListingSuccess:
			
			self.dataProvider=[validation.responseDict objectForKey:POILISTING];
			
			[self.dataProvider insertObject:[POIManager createNoneCategory] atIndex:0];
			
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


//
/***********************************************
 * @description			POI MAP BOUNDS REQUEST
 ***********************************************/
//

-(void)requestPOICategoryMapPointsForCategory:(POICategoryVO*)category withNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se{
	
	if(![category.key isEqualToString:NONE]){
	
		self.selectedCategory=category;
		
		NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
										 [[CycleStreets sharedInstance] APIKey], @"key",
										 category.key,@"type",
										 BOX_FLOAT(nw.latitude),@"n",
										 BOX_FLOAT(nw.longitude),@"w",
										 BOX_FLOAT(se.latitude),@"s",
										 BOX_FLOAT(se.longitude),@"e",
										 BOX_INT(40),@"limit",nil];
		
		NetRequest *request=[[NetRequest alloc]init];
		request.dataid=POIMAPLOCATION;
		request.requestid=ZERO;
		request.parameters=parameters;
		request.revisonId=0;
		request.source=USER;
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:[NSString stringWithFormat:@"Retrieving %@s in area",category.name] andMessage:nil];
		
	}else{
			
			[self.categoryDataProvider removeAllObjects];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
			
	}
	
}


-(void)POICategoryMapPointsResponse:(ValidationVO*)validation{
	
	
	switch (validation.validationStatus) {
			
		case ValidationPOIMapCategorySuccess:
			
			self.categoryDataProvider=[validation.responseDict objectForKey:POIMAPLOCATION];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Retrieved" andMessage:nil];
			
			break;
			
		case ValidationPOIMapCategoryFailed:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"No Points found for this type in the current map" andMessage:nil];
			
			break;
		default:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeServer withTitle:@"Unable to retrieve data" andMessage:nil];
			
			break;
	}
	
	
}



//
/***********************************************
 * @description			POI list for location
 ***********************************************/
//


// request
-(void)requestPOICategoryDataForCategory:(POICategoryVO*)category atLocation:(CLLocationCoordinate2D)location{
	
	
	if(![category.key isEqualToString:NONE]){
		
	
		NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
										 [[CycleStreets sharedInstance] APIKey], @"key", 
										 category.key,@"type",
										 BOX_FLOAT(location.longitude),@"longitude",
										 BOX_FLOAT(location.latitude),@"latitude",
										 BOX_INT(5),@"radius",BOX_INT(40),@"limit",nil];
		
		NetRequest *request=[[NetRequest alloc]init];
		request.dataid=POICATEGORYLOCATION;
		request.requestid=ZERO;
		request.parameters=parameters;
		request.revisonId=0;
		request.source=USER;
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:[NSString stringWithFormat:@"Retrieving %@s in area",category.name] andMessage:nil];
		
	}else{
		
		[self.categoryDataProvider removeAllObjects];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:POICATEGORYLOCATIONRESPONSE object:nil userInfo:nil];
		
	}
	
}


-(void)POICategoryDataResponse:(ValidationVO*)validation{
	
	
	switch (validation.validationStatus) {
			
		case ValidationPOICategorySuccess:
			
			self.categoryDataProvider=[validation.responseDict objectForKey:POICATEGORYLOCATION];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POICATEGORYLOCATIONRESPONSE object:nil userInfo:nil];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Retrieved" andMessage:nil];
			
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

+(POICategoryVO*)createNoneCategory{
	
	POICategoryVO *category=[POICategoryVO new];
	category.name=@"None";
	category.key=NONE;
	category.shortname=@"None";
	category.total=0;
	category.icon=nil;
	
	return category;
}

@end
