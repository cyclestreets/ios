//
//  LocationSearchManager.m
//  CycleStreets
//
//  Created by neil on 06/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "LocationSearchManager.h"
#import "ValidationVO.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "CycleStreets.h"
#import "BUNetworkOperation.h"
#import "HudManager.h"
#import "BUDataSourceManager.h"

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>

@interface LocationSearchManager()


@property (nonatomic, strong)	NSMutableDictionary			*requestResultDict;
@property (nonatomic, strong)	NSMutableArray				*recentSelectedArray;

@property (nonatomic,strong)  BUNetworkOperation			*searchOperation;

@end



@implementation LocationSearchManager
SYNTHESIZE_SINGLETON_FOR_CLASS(LocationSearchManager);

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
		self.requestResultDict = [[NSMutableDictionary alloc] init];
		self.recentSelectedArray=[[NSMutableArray alloc]init];
    }
    return self;
}






//
/***********************************************
 * @description			NOTIFICATION SUPPORT
 ***********************************************/
//

-(void)listNotificationInterests{
		
	[notifications addObject:REQUESTDIDFAIL];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	[self addRequestID:LOCATIONSEARCH];
	
	[super listNotificationInterests];
}



-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	BUNetworkOperation		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	
	if([self isRegisteredForRequest:dataid]){
		
		if([self isRegisteredForRequest:dataid]){
			
			if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED] || [notification.name isEqualToString:REQUESTDIDFAIL]){
				[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Network Error" andMessage:@"Unable to contact server"];
			}
			
		}
		
	}
	
	
}


//
/***********************************************
 * @description			SEARCH LOCATION REQUEST
 ***********************************************/
//

-(void)searchForLocation:(NSString*)searchString withFilter:(LocationSearchFilterType)filterType forRequestType:(LocationSearchRequestType)requestType atLocation:(CLLocationCoordinate2D)centerLocation{
	
	
	_activeFilterType=filterType;
	_activeRequestType=requestType;
	 
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setMiscValue:searchString forKey:@"lastSearch"];
	
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
			[self searchContactsForLocation:searchString];
		break;
		
	}
	
	// if operation active cancel
	if(_searchOperation!=nil)
		[[BUDataSourceManager sharedInstance] cancelRequestForType:LOCATIONSEARCH];
	
	if(requiresNetWorkLookUp==YES){
		
		
		NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[cycleStreets APIKey],@"key",
										 searchString,@"street",
										 [NSNumber numberWithFloat:(centerLocation.longitude-range)],@"w",
										 [NSNumber numberWithFloat:centerLocation.latitude + range],@"n",
										 [NSNumber numberWithFloat:centerLocation.longitude + range],@"e",
										 [NSNumber numberWithFloat:centerLocation.latitude - range],@"s",
										 [NSNumber numberWithLong:zoom],@"zoom",
										 cycleStreets.files.clientid,@"clientid",
										 nil];
		
		
		self.searchOperation=[[BUNetworkOperation alloc]init];
		_searchOperation.dataid=LOCATIONSEARCH;
		_searchOperation.requestid=ZERO;
		_searchOperation.parameters=parameters;
		_searchOperation.source=DataSourceRequestCacheTypeUseNetwork;
		
		__weak __typeof(&*self)weakSelf = self;
		_searchOperation.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
			
			[weakSelf searchForLocationWithFilterResponse:operation];
			
		};
		
		[[BUDataSourceManager sharedInstance] processDataRequest:_searchOperation];
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Searching..." andMessage:nil];
		
	}
	
}


-(void)searchForLocationWithFilterResponse:(BUNetworkOperation*)response{
	
	self.searchOperation=nil;
	
	switch(response.validationStatus){
		
		case ValidationSearchSuccess:
		{
			
			[[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONSEARCHRESPONSE object:response.dataProvider];
			
			[[HudManager sharedInstance] removeHUD];
		}
		
		break;
		
		case ValidationSearchFailed:
		{
			
			//[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Search failed" andMessage:nil];
		}
			
		break;
			
		default:
			break;
	}
	
	
}



//
/***********************************************
 * @description			logic for AB search 
 ***********************************************/
//
-(void)searchContactsForLocation:(NSString*)searchString{
	
	//ABAddressBookRef AB=ABAddressBookCreate();
	
	// get all persons in AB
	//CFArrayRef personArray=ABAddressBookCopyArrayOfAllPeople(AB);
	
	// use nspredicate to find persons with name / address with searchString
	
	
	// return array
	
}


//
/***********************************************
 * @description			Recent Selected
 ***********************************************/
//

-(void)addUserSelectionToRecents:(NSString*)selectionid{
	
	
	
	
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
