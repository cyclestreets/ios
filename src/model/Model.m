//
//  Model.m
//  NagMe
//
//  Created by neil on 23/11/2009.
//  Copyright 2009 Chroma. All rights reserved.
//
// Main App Model

#import "Model.h"
#import "GlobalUtilities.h"
#import "ApplicationXMLParser.h"
#import "AppConstants.h"
#import "NetUtilities.h"


@interface Model(Private)

-(void)onComplete;
-(void)onFail:(NSString*)error;
-(void)compactRequestsForDataid:(NSString*)dataid andRequest:(NSString*)requestid;
-(void)initiateModelCacheStoreForType:(NSString*)type;

@end

@implementation Model
SYNTHESIZE_SINGLETON_FOR_CLASS(Model);
@synthesize dataProviders;
@synthesize cachedrequests;
@synthesize xmlparser;
@synthesize activeRequests;
@synthesize delegate;
@synthesize maxMemoryItems;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [dataProviders release], dataProviders = nil;
    [cachedrequests release], cachedrequests = nil;
    [xmlparser release], xmlparser = nil;
    [activeRequests release], activeRequests = nil;
    delegate = nil;
	
    [super dealloc];
}





-(id)init{
	if (self = [super init])
	{
		xmlparser=[[ApplicationXMLParser alloc]init];
		xmlparser.delegate=self;
		dataProviders=[[NSMutableDictionary alloc]init];
		activeRequests=[[NSMutableDictionary alloc]init];
		cachedrequests=[[NSMutableDictionary alloc]init];
		maxMemoryItems=10; // this is per dataid so will normally be c.70 blocks
		
		[[NSNotificationCenter defaultCenter] 
		 addObserver:self
		 selector:@selector(didReceiveMemoryWarning:)
		 name:UIApplicationDidReceiveMemoryWarningNotification  
		 object:nil]; 
	}
	return self;
}




#pragma mark Data Parsing methods

//
/***********************************************
 * @description			passes connection response to XMLParser for parsing
 ***********************************************/
//
-(void)parseData:(NetResponse*)response{
	
	BetterLog(@"");
	
	
	switch(response.dataType){
		
		case DATATYPE_XML:
			
			[self initiateModelCacheStoreForType:response.dataid];
			
			[xmlparser parseData:response];
		
		break;
			
		case DATATYPE_JSON:
			
			
			break;
		
		
	}
	
	
}


-(void)initiateModelCacheStoreForType:(NSString*)type{
	
	if([dataProviders objectForKey:type]==nil){
		[dataProviders setObject:[NSMutableDictionary dictionaryWithCapacity:maxMemoryItems] forKey:type];
		[cachedrequests setObject:[NSMutableArray arrayWithCapacity:maxMemoryItems] forKey:type];
		
	}	
}



//
/***********************************************
 * @description			locates and returns ram cached data for a request 
 ***********************************************/
//
-(BOOL)loadCachedDataForType:(NSString*)dataid withRequestid:(NSString*)requestid{
	
	BetterLog(@"");
	
	
	if([dataProviders objectForKey:dataid]==nil){
		return NO;
	}
	
	if([[dataProviders objectForKey:dataid] objectForKey:requestid]==nil){
		return NO;
	}
	
	
	NetResponse	*response=[[NetResponse alloc]init];
	response.dataid=dataid;
	response.requestid=requestid;
	response.dataProvider=[[dataProviders objectForKey:dataid] objectForKey:requestid];
	
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,@"response", nil];
	[response release];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETEFROMMODEL object:nil userInfo:dict];
	
	
	
	return YES;
	
	
}


//
/***********************************************
 * @description			stores filecached data for this request in ram and notifies views
 ***********************************************/
//
-(void)setCachedData:(id)data forType:(NSString*)type withRequestid:(NSString*)requestid{
	
	//NSLog(@"[DEBUG] Model.setCachedData for type: %@",type);
	
	if([dataProviders objectForKey:type]==nil){
		[dataProviders setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:type];
	}
	
	[[dataProviders objectForKey:type] setObject:data forKey:requestid];
	
	[activeRequests setObject:requestid forKey:type];
	
	[self compactRequestsForDataid:type andRequest:requestid];
	
	NetResponse	*response=[[NetResponse alloc]init];
	response.dataid=type;
	response.requestid=requestid;
	response.dataProvider=data;
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE,nil];
	[response release];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETEFROMCACHE object:nil userInfo:dict];
	
	
}


//
/***********************************************
 * checks to see if request is the same as the existing one for this data id, if so sends REQUESTWASACTIVE notification else DSM wil continue as normal
 ***********************************************/
//
-(BOOL)RequestIsExistingRequest:(NSString*)dataid withRequestid:(NSString*)requestid{
	
	BOOL result=[[activeRequests objectForKey:dataid] isEqualToString:requestid];
	
	if(result==YES){
	
		NetResponse	*response=[[NetResponse alloc]init];
		response.dataid=dataid;
		response.requestid=requestid;
		response.dataProvider=nil;
		
		
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE, nil];
		[response release];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTWASACTIVE object:nil userInfo:dict];
		
	}
	
	return NO;
	

}




#pragma  RKXML Parser deleagte methods

//
/***********************************************
 * @description			XML  parser for this request complted and parsed ok. Store data and notify views
 ***********************************************/
//
-(void)XMLParserDidComplete:(NetResponse*)response{
	
	
	BetterLog(@"Model:XMLParserDidComplete for dataid: %@ with requestid: %@",response.dataid,response.requestid);
	
		
	if(response.updated==NO){
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:response,RESPONSE, nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:XMLPARSERDIDCOMPLETENOUPDATE object:nil userInfo:dict];
		[dict release];
		
	}else {
		
		[[dataProviders objectForKey:response.dataid] setObject:response.dataProvider forKey:response.requestid];
		
		// this will always overwrite same named objects
		// so no need to check for duplication request ids
		[activeRequests setObject:response.requestid forKey:response.dataid];
		
		[self compactRequestsForDataid:response.dataid andRequest:response.requestid];
		
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE, nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETEFROMSERVER object:nil userInfo:dict];
		
	}

	
}


-(void)XMLParserDidFail:(NetResponse*)response{
	
	BetterLog(@"");
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE, nil];
	[response release]; 
	[[NSNotificationCenter defaultCenter] postNotificationName:XMLPARSERDIDFAILPARSING object:nil userInfo:dict];
	
	
}



-(id)dataProviderForType:(NSString*)type withRequestid:(NSString*)requestid{
	
	NSMutableDictionary *typedict=[dataProviders objectForKey:type];
	return [typedict objectForKey:requestid];
	
}






#pragma mark Utility methods


//
/***********************************************
 * stores refs to requestids, will remove ref & cached model data if maxMemoryItems per dataid is reached
 ***********************************************/
//
-(void)compactRequestsForDataid:(NSString*)dataid andRequest:(NSString*)requestid{
	
	NSMutableArray *dataarray=[cachedrequests objectForKey:dataid];
	
	// ensure no duplicates inserted
	if(![dataarray containsObject:requestid]){
		[dataarray addObject:requestid];
	}
	
	// if exceeds max, remove oldest item;
	if([dataarray count]>maxMemoryItems){
		NSString *removeablerequest=[dataarray objectAtIndex:0];
		NSMutableDictionary *dict=[dataProviders objectForKey:dataid];
		[dict removeObjectForKey:removeablerequest];
		[dataarray removeObjectAtIndex:0];
	}
	
}




-(void)didReceiveMemoryWarning:(NSNotification*)notification{
	
	[dataProviders removeAllObjects];
	[activeRequests removeAllObjects];
	[cachedrequests removeAllObjects];
	
}



@end
