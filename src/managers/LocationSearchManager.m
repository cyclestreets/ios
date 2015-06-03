//
//  LocationSearchManager.m
//  CycleStreets
//
//  Created by neil on 06/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "LocationSearchManager.h"
#import "BUResponseObject.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "CycleStreets.h"
#import "BUNetworkOperation.h"
#import "HudManager.h"
#import "BUDataSourceManager.h"
#import "LocationSearchVO.h"
#import "UserLocationManager.h"

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
	[notifications addObject:XMLPARSERDIDFAILPARSING];
	
	[self addRequestID:LOCATIONSEARCH];
	
	[super listNotificationInterests];
}



-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	BUNetworkOperation		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	NSString *name=notification.name;
	
	if([self isRegisteredForRequest:dataid]){
			
		if([name isEqualToString:REMOTEFILEFAILED] || [name isEqualToString:DATAREQUESTFAILED] || [name isEqualToString:REQUESTDIDFAIL] || [name isEqualToString:XMLPARSERDIDFAILPARSING]){
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Network Error" andMessage:@"Unable to contact server"];
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
	BOOL requiresNetWorkLookUp=NO;
	switch(filterType){
		
		case LocationSearchFilterLocal:
		{	
			range = 0.25;
			requiresNetWorkLookUp=YES;
		}
		break;
		
		case LocationSearchFilterNational:
		{
			range = 4.0;
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
										 cycleStreets.files.clientid,@"clientid",
										 @(1),@"bounded",
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


-(void)searchForLocationWithFilterResponse:(BUNetworkOperation*)operation{
	
	self.searchOperation=nil;
	
	switch(operation.responseStatus){
		
		case ValidationSearchSuccess:
		{
			
			NSMutableArray *filteredResults=[self filterDuplicateSearchResults:operation.responseObject];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONSEARCHRESPONSE object:filteredResults];
			
			[[HudManager sharedInstance] removeHUD];
		}
		
		break;
		
		case ValidationSearchFailed:
		{
			
			[[HudManager sharedInstance] removeHUD];
		}
			
		break;
			
		default:
			break;
	}
	
	
}


// filter all results so that they are the min distance apart
// this also stops the MapView treating these as too close when adding to map as it uses the same isSignificantLocationDistance call to determine
-(NSMutableArray*)filterDuplicateSearchResults:(NSMutableArray*)arr{
	
	NSMutableArray *removeArray=[NSMutableArray array];
	
	for(int i=0; i<arr.count; i++){
		for(int j=i + 1; j<arr.count; j++){
			if(i!=j){
				
				LocationSearchVO *firstobject=arr[i];
				LocationSearchVO *secondObject=arr[j];
				
				BOOL result=[UserLocationManager isSignificantLocationChange:firstobject.locationCoords newLocation:secondObject.locationCoords accuracy:MIN_START_FINISH_DISTANCE];
							 
				if(result==NO){
					[removeArray addObject:firstobject];
					break;
				}
				
			}
		}
	}
	
	
	[arr removeObjectsInArray:removeArray];
	
	return arr;
	
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
