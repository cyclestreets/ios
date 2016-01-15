//
//  POIManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POIManager.h"
#import "BUResponseObject.h"
#import "CycleStreets.h"
#import "BUDataSourceManager.h"
#import "HudManager.h"
#import "GlobalUtilities.h"
#import "DeviceUtilities.h"
#import "BUNetworkOperation.h"
#import "AppConstants.h"
#import "BuildTargetConstants.h"
#import "UserSettingsManager.h"
#import "StringUtilities.h"

static NSString *const kPOIValidityValue=@"kPOIVAlidityValue";

@interface POIManager()


@property (nonatomic,strong)  NSMutableDictionary					*selectedPOICategories;

@property (nonatomic,strong)  NSMutableArray						*leisureDataProvider;

@property (nonatomic,strong)  NSMutableDictionary					*activeOperations;


@property (nonatomic,strong) NSDate									*poiValidityDate;


@property (nonatomic,assign,readwrite)  BOOL						hasSelectedPOIs;


// pre selection support


@property (nonatomic,strong)  NSMutableArray						*preSelectionRequestArray;
@property (nonatomic,strong)  NSMutableDictionary					*preSelectionResponseDataProvider;
@property (nonatomic,strong)  BUNetworkOperation					*preSelectionOperation;


@end



@implementation POIManager
SYNTHESIZE_SINGLETON_FOR_CLASS(POIManager);


-(id)init{
	
	if (self = [super init])
	{
		_selectedPOICategories=[NSMutableDictionary dictionary];
		_categoryDataProvider=[NSMutableDictionary dictionary];
		_activeOperations=[NSMutableDictionary dictionary];
		
		id poilistvalidity=[[UserSettingsManager sharedInstance] fetchObjectforKey:kPOIValidityValue forType:kSTATESYSTEMCONTROLLEDSETTINGSKEY];
		if(poilistvalidity!=nil){
			self.poiValidityDate=[NSDate dateWithTimeIntervalSince1970:[poilistvalidity integerValue]];
		}
		
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


#pragma mark - request list of all categories
-(void)requestPOIListingData{
	
	BOOL isRetina=ISRETINADISPLAY;
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key",
									 isRetina==YES ? @(64): @(32),@"icons",
									 nil];
	
	// cns
	if(APIREQUIRESIDENTIFIER){
		[parameters setObject:API_IDENTIFIER forKey:@"iconset"];
	}
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=POILISTING;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseCache;
	
	if(_poiValidityDate!=nil){
		
		NSDate *now=[NSDate date];
		if([now compare:_poiValidityDate]==NSOrderedDescending){
			request.source=DataSourceRequestCacheTypeUseNetwork;
		}
	}
	
	__weak __typeof(&*self)weakSelf = self;
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[weakSelf POIListingDataResponse:operation];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
}

-(void)POIListingDataResponse:(BUNetworkOperation*)operation{
	
	
	switch (operation.responseStatus) {
			
		case ValidationPOIListingSuccess:
		{
			NSDictionary *repsonseObject=operation.responseObject;
			NSInteger validityValue=[repsonseObject[@"validuntil"] integerValue];
			self.poiValidityDate=[NSDate dateWithTimeIntervalSince1970:validityValue];
			[[UserSettingsManager sharedInstance] saveObject:@(validityValue) forKey:kPOIValidityValue forType:kSTATESYSTEMCONTROLLEDSETTINGSKEY];
			
			[self updatePOIListingDataProvider:repsonseObject[DATAPROVIDER]];
		}
			
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
	
	self.leisureDataProvider=[[NSMutableArray alloc] initWithArray:arr copyItems:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:POILISTINGRESPONSE object:nil userInfo:nil];
	
}


#pragma mark - POI Map bounds changes
//
/***********************************************
 * @description			POI MAP BOUNDS REQUEST
 ***********************************************/
//

-(void)removePOICategoryMapPointsForCategory:(POICategoryVO*)category{
	
	if(_activeOperations[category.name]!=nil){
		[[BUDataSourceManager sharedInstance] cancelRequestForType:POIMAPLOCATION];
		[_activeOperations removeObjectForKey:category.name];
	}
	
	[_selectedPOICategories removeObjectForKey:category.name];
	
	[_categoryDataProvider removeObjectForKey:category.name];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
	
}

-(void)removeAllPOICategoryMapPoints{
	
	if(_activeOperations.count>0){
		[[BUDataSourceManager sharedInstance] cancelRequestForType:POIMAPLOCATION];
		[_activeOperations removeAllObjects];
	}
	
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



#pragma mark - POI individual selection

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
		
		_activeOperations[category.name]=request;
		
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
	
	[_activeOperations removeObjectForKey:category.name];
	
	switch (response.responseStatus) {
			
		case ValidationPOIMapCategorySuccess:
		{
			[_categoryDataProvider setObject:response.responseObject forKey:category.name];
			
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



#pragma mark - map change poi refresh

-(void)refreshPOICategoryMapPointswithNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se{
	
	if(_preSelectionRequestArray.count>0 && _activeOperations.count>0){
		[[BUDataSourceManager sharedInstance] cancelRequestForType:POIMAPLOCATION];
		[_activeOperations removeAllObjects];
	}
	
	
	self.preSelectionRequestArray=[NSMutableArray array];
	for(POICategoryVO *poi in _dataProvider){
		if(poi.selected)
			[_preSelectionRequestArray addObject:poi];
	}
	
	POICategoryVO *firstCategory=_preSelectionRequestArray.firstObject;
	if([firstCategory.key isEqualToString:NONE])
		return;
	
	if(_preSelectionRequestArray.count==0)
		return;
	
	self.preSelectionResponseDataProvider=[NSMutableDictionary dictionary];
	
	[self appendPOICategoryMapPointsRequest:_preSelectionRequestArray.firstObject withNWBounds:nw andSEBounds:se];
	
	
}




#pragma mark - POI pre-selected list
//
/***********************************************
 * @description			POI list for preselected array
 ***********************************************/
//


-(void)requestPOICategoryMapPointsForList:(NSArray*)categoryList withNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se{
	
	
	POICategoryVO *firstCategory=categoryList.firstObject;
	if([firstCategory.key isEqualToString:NONE])
		return;
	
	
	if(_preSelectionRequestArray.count>0 && _activeOperations.count>0){
		[[BUDataSourceManager sharedInstance] cancelRequestForType:POIMAPLOCATION];
		[_activeOperations removeAllObjects];
	}
	
	self.preSelectionRequestArray=[categoryList mutableCopy];
	self.preSelectionResponseDataProvider=[NSMutableDictionary dictionary];
	
	[self appendPOICategoryMapPointsRequest:_preSelectionRequestArray.firstObject withNWBounds:nw andSEBounds:se];
	
}


-(void)appendPOICategoryMapPointsRequest:(POICategoryVO*)category withNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se{
	
	
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
	request.requestid=[StringUtilities stringWithUUID];
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	
	_activeOperations[category.name]=request;
	
	__weak __typeof(&*self)weakSelf = self;
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[weakSelf appendPOICategoryMapPointsResponse:operation forCategory:category withNWBounds:nw andSEBounds:se];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];

	
	
}



-(void)appendPOICategoryMapPointsResponse:(BUNetworkOperation*)response forCategory:(POICategoryVO*)category withNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se{
	
	
	[_activeOperations removeObjectForKey:category.name];
	
	switch (response.responseStatus) {
			
		case ValidationPOIMapCategorySuccess:
		case ValidationPOIMapCategorySuccessNoEntries:
		{
			
			[_preSelectionRequestArray removeObject:category];
			
			if(response.responseObject!=nil)
				[_preSelectionResponseDataProvider setObject:response.responseObject forKey:category.name];
			
			if(_preSelectionRequestArray.count>0){
				
				[self appendPOICategoryMapPointsRequest:_preSelectionRequestArray.firstObject withNWBounds:nw andSEBounds:se];
				
			}else{
				
				self.categoryDataProvider=_preSelectionResponseDataProvider;
				
				[[NSNotificationCenter defaultCenter] postNotificationName:POIMAPLOCATIONRESPONSE object:nil userInfo:nil];
				
			}
			
		}
		break;
		
			
		case ValidationPOIMapCategoryFailed:
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeServer withTitle:@"Unable to retrieve data" andMessage:nil];
			
			break;
		default:
			break;
	}
	
	
}





#pragma mark - Not used
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
	
	
	switch (response.responseStatus) {
			
		case ValidationPOICategorySuccess:
			
			self.categoryDataProvider=response.responseObject;
			
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


#pragma mark - Utilities
//
/***********************************************
 * @description			UTILITIES
 ***********************************************/
//

-(NSMutableArray*)newLeisurePOIArray{
	
	return [[NSMutableArray alloc]initWithArray:_leisureDataProvider copyItems:YES];
	
}



+(POICategoryVO*)createNoneCategory{
	
	POICategoryVO *category=[POICategoryVO new];
	category.name=@"None";
	category.key=NONE;
	category.shortname=@"None";
	category.total=0;
	category.imageName=nil;
	
	return category;
}


#pragma mark - getters


-(BOOL)hasSelectedPOIs{
	
	if(_dataProvider==nil)
		return NO;
	
	for(POICategoryVO *category in _dataProvider){
		if(category.selected){
			if([category.key isEqualToString:NONE]){
				return NO;
			}else{
				return YES;
			}
		}
			
	}
	return NO;
	
}



@end
