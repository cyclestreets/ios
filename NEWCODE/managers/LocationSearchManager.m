//
//  LocationSearchManager.m
//  CycleStreets
//
//  Created by neil on 06/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "LocationSearchManager.h"s
#import "ValidationVO.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "CycleStreets.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import <CoreLocation/CoreLocation.h>

static NSString *format = @"%@?key=%@&street=%@&%@&clientid=%@";
static NSString *urlPrefix = @"http://www.cyclestreets.net/api/geocoder.xml";


@interface LocationSearchManager(Private)


-(void)searchForLocationWithFilterResponse:(ValidationVO*)validation;
-(void)processUserContacts;

-(void)showProgressHUDWithMessage:(NSString*)message;
-(void)removeHUD;
-(void)hudWasHidden;
@end



@implementation LocationSearchManager
@synthesize HUD;
@synthesize activeFilterType;
@synthesize activeRequestType;
@synthesize requestResultDict;



//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [HUD release], HUD = nil;
    [requestResultDict release], requestResultDict = nil;
	
    [super dealloc];
}



//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
		self.requestResultDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}






//
/***********************************************
 * @description			NOTIFICATION SUPPORT
 ***********************************************/
//

-(void)listNotificationInterests{
	
	
	[notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	
	[super listNotificationInterests];
}



-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	NetResponse		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	
	if([self isRegisteredForRequest:dataid]){
		if([notification.name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
			
			
			
		}
		
	}
	
	
	
}


//
/***********************************************
 * @description			SEARCH LOCATION REQUEST
 ***********************************************/
//

-(void)searchForLocation:(NSString*)searchString withFilter:(LocationSearchFilterType)filterType forRequestType:(LocationSearchRequestType)requestType{
	
	activeFilterType=filterType;
	activeRequestType=requestType;
	 
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	//[cycleStreets.files setMiscValue:self.currentRequestSearchString forKey:@"lastSearch"];
	
	CLLocationDegrees range = 1.0;
	NSInteger zoom = 11;
	BOOL requiresNetWorkLookUp=NO;
	switch(filterType){
		
		case LocationSearchFilterLocal:
		{	
			range = 0.25;
			zoom = 16;
			requiresNetWorkLookUp=YES;
		}
		break;
		
		case LocationSearchFilterNational:
		{
			range = 4.0;
			zoom = 6;
			requiresNetWorkLookUp=YES;
		}
		break;
			
		case LocationSearchFilterRecent:
			
			
		break;
			
		case LocationSearchFilterContacts:
			[self processUserContacts];
		break;
		
	}
	
	CLLocationCoordinate2D centreLocation;
	
	if(requiresNetWorkLookUp==YES){
		
		NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[cycleStreets APIKey],@"key",
										 searchString,@"street",
										 [NSNumber numberWithFloat:centreLocation.longitude - range],@"w",
										 [NSNumber numberWithFloat:centreLocation.latitude + range],@"n",
										 [NSNumber numberWithFloat:centreLocation.longitude + range],@"e",
										 [NSNumber numberWithFloat:centreLocation.latitude - range],@"s",
										 [NSNumber numberWithInt:zoom],@"zoom",
										 cycleStreets.files.clientid,@"clientid",
										 nil];
		
		NetRequest *request=[[NetRequest alloc]init];
		request.dataid=LOCATIONSEARCH;
		request.requestid=ZERO;
		request.parameters=parameters;
		request.revisonId=0;
		request.source=USER;
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
		[dict release];
		[request release];
		
		
		[self showProgressHUDWithMessage:@"Searching..."];
		
	}
	
}


-(void)searchForLocationWithFilterResponse:(ValidationVO*)validation{
	
	switch(validation.validationStatus){
		
		case 1:
		
		break;
		
		
	}
	
	[self removeHUD];
	
}



-(void)processUserContacts{
	
	/*
	ABAddressBook *AB = [ABAddressBook sharedAddressBook];
	ABSearchElement *nameIsSmith =[ABPerson searchElementForProperty:kABLastNameProperty
                                 label:nil
                                   key:nil
                                 value:@"Smith"
                            comparison:kABEqualCaseInsensitive];
	NSArray *peopleFound =[AB recordsMatchingSearchElement:nameIsSmith];
	*/
}




//
/***********************************************
 * @description			HUDSUPPORT
 ***********************************************/
//


-(void)showProgressHUDWithMessage:(NSString*)message{
	
	self.HUD=[[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
    HUD.delegate = self;
	HUD.labelText=message;
	[HUD show:YES];
	
}


-(void)removeHUD{
	
	[HUD hide:YES];
	
}


-(void)hudWasHidden{
	
	[HUD removeFromSuperview];
	[HUD release];
	
}


//
/***********************************************
 * @description			Enum lookups
 ***********************************************/
//

+ (LocationSearchRequestType)locationrequestStringTypeToConstant:(NSString*)stringType {
    
	if([stringType isEqualToString:@"LocationSearchRequestTypeMap"]){
		return LocationSearchRequestTypeMap;
	}else if ([stringType isEqualToString:@"LocationSearchRequestTypePhoto"]){
		return LocationSearchRequestTypePhoto;
	}
	
    return LocationSearchRequestTypeNone;
}


+ (NSString*)locationrequestConstantToString:(LocationSearchRequestType)requestType {
    
	if(requestType==LocationSearchRequestTypeMap){
		return @"LocationSearchRequestTypeMap";
	}else if (requestType==LocationSearchRequestTypePhoto){
		return @"LocationSearchRequestTypePhoto";
	}
	
    return @"LocationSearchRequestTypeNone";
}

@end
