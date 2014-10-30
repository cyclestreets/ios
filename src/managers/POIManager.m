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
#import "BUDataSourceManager.h"
#import "HudManager.h"
#import "GlobalUtilities.h"
#import "DeviceUtilities.h"
#import "BUNetworkOperation.h"
#import "AppConstants.h"

@interface POIManager()


@property (nonatomic,strong)  NSMutableDictionary					*selectedPOICategories;


@end



@implementation POIManager
SYNTHESIZE_SINGLETON_FOR_CLASS(POIManager);


-(id)init{
	
	if (self = [super init])
	{
		_selectedPOICategories=[NSMutableDictionary dictionary];
		_categoryDataProvider=[NSMutableDictionary dictionary];
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
	[notifications addObject:REQUESTDIDCOMPLETEFROMMODEL];
	[notifications addObject:REQUESTDIDCOMPLETEFROMCACHE];
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
	BUNetworkOperation		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		
		if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED] || [notification.name isEqualToString:REQUESTDIDFAIL]){
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Network Error" andMessage:@"Unable to contact server"];
		}
		
		if([notification.name isEqualToString:XMLPARSERDIDFAILPARSING]){
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Route error" andMessage:@"Unable to load this route, please re-check route number."];
		}
		
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
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key",
									 isRetina==YES ? @(64): @(32),@"icons",
									 @"stoke",@"iconset",
									 nil];
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=POILISTING;
	request.requestid=ZERO;
	request.parameters=parameters;
#warning This is not cacheing
	//TODO: this is not cacheing
	request.source=DataSourceRequestCacheTypeUseNetwork;
	
	__weak __typeof(&*self)weakSelf = self;
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[weakSelf POIListingDataResponse:operation];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	
}

-(void)POIListingDataResponse:(BUNetworkOperation*)response{
	
	
	switch (response.validationStatus) {
			
		case ValidationPOIListingSuccess:
			
			[self updatePOIListingDataProvider:response.dataProvider];
			
			
		break;
		
		case ValidationPOIListingFailure:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Unable to retrieve data" andMessage:nil];
			
		break;
		default:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeServer withTitle:@"Unable to retrieve data" andMessage:nil];
		
		break;
	}
	
	
}

-(void)updatePOIListingDataProvider:(NSMutableArray*)arr{
	
	self.dataProvider=arr;
	[self.dataProvider insertObject:[POIManager createNoneCategory] atIndex:0];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:POILISTINGRESPONSE object:nil userInfo:nil];
	
}


//
/***********************************************
 * @description			POI MAP BOUNDS REQUEST
 ***********************************************/
//

-(void)removePOICategoryMapPointsForCategory:(POICategoryVO*)category{
	
	[_selectedPOICategories removeObjectForKey:category.name];
	
	[_categoryDataProvider removeObjectForKey:category.name];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
	
}

-(void)removeAllPOICategoryMapPoints{
	
	for(POICategoryVO *category in _dataProvider){
		if ([category.key isEqualToString:NONE]) {
			category.selected=YES;
		}else{
			category.selected=NO;
		}
	}
	
	[_selectedPOICategories removeAllObjects];
	
	[_categoryDataProvider removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
	
}



-(void)requestPOICategoryMapPointsForCategory:(POICategoryVO*)category withNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se{
	
	if(![category.key isEqualToString:NONE]){
	
		_selectedPOICategories[category.name]=category;
		
		NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
										 [[CycleStreets sharedInstance] APIKey], @"key",
										 category.key,@"type",
										 BOX_FLOAT(nw.latitude),@"n",
										 BOX_FLOAT(nw.longitude),@"w",
										 BOX_FLOAT(se.latitude),@"s",
										 BOX_FLOAT(se.longitude),@"e",
										 BOX_INT(40),@"limit",nil];
		
		BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
		request.dataid=POIMAPLOCATION;
		request.requestid=ZERO;
		request.parameters=parameters;
		request.source=DataSourceRequestCacheTypeUseNetwork;
		
		__weak __typeof(&*self)weakSelf = self;
		request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
			
			[weakSelf POICategoryMapPointsResponse:operation forCategory:category];
			
		};
		
		[[BUDataSourceManager sharedInstance] processDataRequest:request];
		
	}else{
			
			[_categoryDataProvider removeAllObjects];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
			
	}
	
}


-(void)POICategoryMapPointsResponse:(BUNetworkOperation*)response forCategory:(POICategoryVO*)category{
	
	[[HudManager sharedInstance] removeHUD];
	
	switch (response.validationStatus) {
			
		case ValidationPOIMapCategorySuccess:
		{
			[_categoryDataProvider setObject:response.dataProvider forKey:category.name];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
		}
		break;
			
		case ValidationPOIMapCategorySuccessNoEntries:
			
			//[self.categoryDataProvider removeAllObjects];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
			
			
		break;
			
		case ValidationPOIMapCategoryFailed:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeServer withTitle:@"Unable to retrieve data" andMessage:nil];
			
		break;
			default:
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
		
		BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
		request.dataid=POICATEGORYLOCATION;
		request.requestid=ZERO;
		request.parameters=parameters;
		request.source=DataSourceRequestCacheTypeUseNetwork;
		
		__weak __typeof(&*self)weakSelf = self;
		request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
			
			[weakSelf POICategoryDataResponse:operation];
			
		};
		
		[[BUDataSourceManager sharedInstance] processDataRequest:request];
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:[NSString stringWithFormat:@"Retrieving %@s in area",category.name] andMessage:nil];
		
	}else{
		
		[self.categoryDataProvider removeAllObjects];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:POICATEGORYLOCATIONRESPONSE object:nil userInfo:nil];
		
	}
	
}


-(void)POICategoryDataResponse:(BUNetworkOperation*)response{
	
	
	switch (response.validationStatus) {
			
		case ValidationPOICategorySuccess:
			
			self.categoryDataProvider=response.dataProvider;
			
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
	category.imageName=nil;
	
	return category;
}

@end
