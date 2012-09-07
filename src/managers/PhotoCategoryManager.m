//
//  PhotoCategoryManager.m
//  CycleStreets
//
//  Created by Gaby Jones on 17/04/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoCategoryManager.h"
#import "ValidationVO.h"
#import "CycleStreets.h"
#import "NetRequest.h"
#import "PhotoCategoryVO.h"
#import "NetRequest.h"
#import "NetResponse.h"
#import "GlobalUtilities.h"


@interface PhotoCategoryManager()

@property (nonatomic,assign)  BOOL legacyConversionRequired;

-(void)convertLegacyDataProvider;

-(void)requestRemoteCategories;
-(void)requestRemoteCategoriesResponse:(ValidationVO*)validation;

-(void)createDefaultCategoryDataProvider;

@end


@implementation PhotoCategoryManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoCategoryManager);
@synthesize dataProvider;
@synthesize validUntilTimeStamp;
@synthesize legacyConversionRequired;


-(id)init{
	
	self = [super init];
	
    if (self) {
		
		// load local cache
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		self.dataProvider = [cycleStreets.files photoCategories];
		
		legacyConversionRequired=YES;
		
		// check validaty of cache, note shite legacy dict storage!
		NSString *validuntil = [[[dataProvider objectForKey:@"validuntil"] objectAtIndex:0] valueForKey:@"validuntil"];
		if(validuntil==nil){
			validuntil=[dataProvider objectForKey:@"validUntilTimeStamp"];
			if(validuntil!=nil)
				legacyConversionRequired=NO;
		}
		
		
		
		BOOL expired = NO;
		if (validuntil == nil || [validuntil length] == 0) {
			expired = YES;
		}
		if (!expired) {
			NSDate *expiry = [[NSDate alloc] initWithTimeIntervalSince1970:[validuntil doubleValue]];
			NSDate *now = [[NSDate alloc] init];
			if ([now compare:expiry] != NSOrderedAscending) {
				expired = YES;
			}
		}
		
		if (expired) {
			legacyConversionRequired=NO;
			[self requestRemoteCategories];
		}else {
			
			self.validUntilTimeStamp=validuntil;
			if(legacyConversionRequired==YES)
				[self convertLegacyDataProvider];
			
			
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
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	[self addRequestID:PHOTOCATEGORIES];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	NetResponse		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		if ([response.dataid isEqualToString:PHOTOCATEGORIES]) {
			
			if([notification.name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
				[self requestRemoteCategoriesResponse:response.dataProvider];
			}
			
			
			if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED] ){
				// only overwrite the dp with a default if we dont have one, otherwise we need to convert
				if(dataProvider==nil){ 
					[self createDefaultCategoryDataProvider];
				}else{
					if(legacyConversionRequired==YES)
						[self convertLegacyDataProvider];
				}
			}
			
		}
		
	}
	
	
}



-(void)requestRemoteCategories{
	
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObject:[CycleStreets sharedInstance].APIKey forKey:@"key"];
									 
	NetRequest *request=[[NetRequest alloc]init];
    request.dataid=PHOTOCATEGORIES;
    request.requestid=ZERO;
    request.parameters=parameters;
    request.revisonId=0;
    request.source=USER;
    
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	
	
}


-(void)requestRemoteCategoriesResponse:(ValidationVO*)validation{
	
	
	switch (validation.validationStatus) {
			
		case ValidationCategoriesSuccess:
		{
			
			self.dataProvider=validation.responseDict;
			
			CycleStreets *cycleStreets = [CycleStreets sharedInstance];
			[cycleStreets.files setPhotoCategories:dataProvider];
			
			
		}

		break;
		
		case ValidationCategoriesFailed: // can be server down or general failure
		{
			[self createDefaultCategoryDataProvider];
		}	
		break;
			
	}
	
}


//
/***********************************************
Note: old mc=c  old c=f
 ***********************************************/
//
-(void)convertLegacyDataProvider{
	
	
	NSArray *catarr=[dataProvider objectForKey:@"category"];
	NSMutableArray *newcatarr=[NSMutableArray array];
	for(NSDictionary *dict in catarr){
		PhotoCategoryVO *vo=[[PhotoCategoryVO alloc]init];
		vo.name=[dict objectForKey:@"name"];
		vo.tag=[dict objectForKey:@"tag"];
		[newcatarr addObject:vo];
	}
	
	
	NSArray *feaarr=[dataProvider objectForKey:@"metacategory"];
	NSMutableArray *newfeaarr=[NSMutableArray array];
	for(NSDictionary *dict in feaarr){
		PhotoCategoryVO *vo=[[PhotoCategoryVO alloc]init];
		vo.name=[dict objectForKey:@"name"];
		vo.tag=[dict objectForKey:@"tag"];
		[newfeaarr addObject:vo];
	}
	
	[dataProvider setObject:newcatarr forKey:@"feature"];
	[dataProvider setObject:newfeaarr forKey:@"category"];
	[dataProvider removeObjectForKey:@"validuntil"];
	[dataProvider setObject:validUntilTimeStamp forKey:@"validUntilTimeStamp"];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setPhotoCategories:dataProvider];
	
}



-(PhotoCategoryVO*)valueObjectForType:(NSString*)type atIndex:(int)index{
	
	return [[dataProvider objectForKey:type] objectAtIndex:index];
	
}


-(void)createDefaultCategoryDataProvider{
	
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	
	PhotoCategoryVO *feat=[[PhotoCategoryVO alloc]init];
	feat.name=@"Any";
	feat.tag=@"any";
	
	PhotoCategoryVO *cat=[[PhotoCategoryVO alloc]init];
	cat.name=@"General";
	cat.tag=@"general";
	
	[dict setObject:[NSMutableArray arrayWithObject:feat] forKey:@"feature"];
	[dict setObject:[NSMutableArray arrayWithObject:cat] forKey:@"category"];
	
	self.dataProvider=dict;
	
	
}




@end
