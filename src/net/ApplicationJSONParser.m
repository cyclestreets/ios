//
//  ApplicationJSONParser
//  Buffer
//
//  Created by Neil Edwards on 18/02/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "ApplicationJSONParser.h"
#import "GlobalUtilities.h"
#import "CJSONDeserializer.h"
#import "GenericConstants.h"

#import "BUNetworkOperation.h"

#import "PhotoMapVO.h"
#import "PhotoMapListVO.h"
#import "CSUserRouteVO.h"
#import "CSUserRouteList.h"
#import "POICategoryVO.h"
#import "POIManager.h"
#import "CSUserRoutePagination.h"

#import <CoreLocation/CoreLocation.h>

@interface ApplicationJSONParser()

@property(nonatomic,strong)NSDictionary *parserMethods;
@property(nonatomic,strong)NSString *parserError;
@property(nonatomic,strong)BUNetworkOperation *activeOperation;
@property(nonatomic,strong)NSDictionary *responseDict;

@end



@implementation ApplicationJSONParser
SYNTHESIZE_SINGLETON_FOR_CLASS(ApplicationJSONParser);



-(instancetype)init{
	if (self = [super init])
	{
        
		self.parserMethods=@{RETREIVELOCATIONPHOTOS:[NSValue valueWithPointer:@selector(RetrievePhotosParser)],
							 RETREIVEROUTEPHOTOS:[NSValue valueWithPointer:@selector(RetrievePhotosParser)],
							 ROUTESFORUSER:[NSValue valueWithPointer:@selector(RoutesForUserParser)],
							 POILISTING:[NSValue valueWithPointer:@selector(POIListingParser)],
							 BINGMAPAUTHENTICATION:[NSValue valueWithPointer:@selector(BingAuthenticationParser)]};
	}
	return self;
}


-(void)parseDataForOperation:(BUNetworkOperation* )networkOperation success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure{
	
	BetterLog(@"");
    
    NSError *error=nil;
	SEL parserMethod=[[_parserMethods objectForKey:networkOperation.dataid] pointerValue];
	
	 if(parserMethod==nil){
		 BetterLog(@"[ERROR] ApplicationJSONParser:parseJSONForType: parser for type %@ not found!",_activeOperation.dataid);
		 return;
	 }
	
    
	if([networkOperation.responseData isKindOfClass:[NSDictionary class]]){
        self.responseDict=(NSDictionary*)networkOperation.responseData;
    }else{
       self.responseDict=[[CJSONDeserializer deserializer] deserializeAsDictionary:networkOperation.responseData error:&error];
    }
	
	
		
	if(error==nil){
		
		self.activeOperation=networkOperation;
		
		[self performSelector:parserMethod];
		
		if(_activeOperation.operationState==NetResponseStateComplete){
			
			BetterLog(@"[DEBUG] ApplicationJSONParser: Success activeResponse.dataid=%@ activeResponse.requestid=%@",_activeOperation.dataid,_activeOperation.requestid);
			
			success(_activeOperation);
			
		}else {
			
			BetterLog(@"[ERROR] ApplicationJSONParser:JSONParserDidFail for DataId=%@",_activeOperation.dataid);
			
			failure(_activeOperation,error);
		}
		
		
		
		
	}else{
		
		// parser error
		
		BetterLog(@"[ERROR]ApplicationJSONParser: Neither JSON decoders able to parse response data");
		_activeOperation.operationState=NetResponseStateFailedWithError;
		_activeOperation.operationError=NetResponseErrorParserFailed;
		failure(networkOperation,error);
		
	}
    
	
	
}




-(BOOL)validateJSON{
	
	BOOL result=YES;
    
    // no validation items
	
	return result;
	
}

//
/***********************************************
 * @description			RESPONSE PARSERS FOR TYPE
 ***********************************************/
//
#pragma mark - PARSERS



-(void)RetrievePhotosParser{
	
	[self validateJSON];
	if(_activeOperation.operationState>NetResponseStateComplete){
		_activeOperation.responseStatus=ValidationRetrievePhotosFailed;
		return;
	}
	
	NSArray *root=_responseDict[@"features"];
	
	if(root!=nil){
		
		PhotoMapListVO *photolist=[[PhotoMapListVO alloc]init];
		NSMutableArray	*arr=[[NSMutableArray alloc]init];
		
		for(NSDictionary *feature in root){
			
			PhotoMapVO *photo=[[PhotoMapVO alloc]init];
			
			[photo updateWithAPIDict:feature];
			
			[arr addObject:photo];
			
		}
		
		photolist.photos=arr;
		
		[_activeOperation setResponseWithValue:photolist];
		
		_activeOperation.responseStatus=ValidationRetrievePhotosSuccess;
		_activeOperation.operationState=NetResponseStateComplete;
		
	}else{
		
		_activeOperation.responseStatus=ValidationRetrievePhotosFailed;
		
	}
	
	
	
}



#pragma mark - User routes (v2 api)

-(void)RoutesForUserParser{
	
	[self validateJSON];
	if(_activeOperation.operationState>NetResponseStateComplete){
		_activeOperation.responseStatus=ValidationUserRoutesFailed;
		return;
	}
	
	NSDictionary *root=_responseDict;
	
	if(root!=nil){
		
		CSUserRouteList *list=[[CSUserRouteList alloc]init];
		list.requestpagination=[[CSUserRoutePagination alloc]initWithDictionary:root[@"pagination"]];
		
		NSMutableArray	*arr=[[NSMutableArray alloc]init];
		
		NSDictionary *journeys=root[@"journeys"];
		for(NSString *routekey in journeys){
			
			NSDictionary *routedict=journeys[routekey];
			
			CSUserRouteVO *userroute=[[CSUserRouteVO alloc]initWithDictionary:routedict];
			
			[arr addObject:userroute];
			
		}
		
		list.routes=arr;
		
		[_activeOperation setResponseWithValue:list];
		
		_activeOperation.responseStatus=VaidationUserRoutesSuccess;
		_activeOperation.operationState=NetResponseStateComplete;
		
	}else{
		
		_activeOperation.responseStatus=ValidationUserRoutesFailed;
		
	}
	
}




-(void)POIListingParser{
	
	BetterLog(@"");
	
	[self validateJSON];
	if(_activeOperation.operationState>NetResponseStateComplete){
		_activeOperation.responseStatus=ValidationPOIListingFailure;
		return;
	}
	
	NSDictionary *root=_responseDict;
	
	
	if(root[@"types"]!=nil){
 
		NSMutableArray *dataProvider=[[NSMutableArray alloc]init];
 
		for(NSString *key in root[@"types"]){
 
			NSDictionary *dict=root[@"types"][key];
			
			POICategoryVO *poicategory=[[POICategoryVO alloc]init];
			[poicategory updateWithAPIDict:dict];
			
			[dataProvider addObject:poicategory];
			
			
		}
		
		[dataProvider insertObject:[POIManager createNoneCategory] atIndex:0];
		
		[_activeOperation setResponseWithValue:@{@"validuntil":root[@"validuntil"],DATAPROVIDER:dataProvider}];
		
		_activeOperation.operationState=NetResponseStateComplete;
		_activeOperation.responseStatus=ValidationPOIListingSuccess;
		
	}else{
		_activeOperation.responseStatus=ValidationPOIListingFailure;
	}
	
	
}

/*{
 authenticationResultCode = ValidCredentials;
 brandLogoUri = "http://dev.virtualearth.net/Branding/logo_powered_by.png";
 copyright = "Copyright \U00a9 2015 Microsoft and its suppliers. All rights reserved. This API cannot be accessed and the content and any results may not be used, reproduced or transmitted in any manner without express written permission from Microsoft Corporation.";
 resourceSets =     (
 {
 estimatedTotal = 1;
 resources =             (
 {
 "__type" = "ImageryMetadata:http://schemas.microsoft.com/search/local/ws/rest/v1";
 imageHeight = 256;
 imageUrl = "http://ecn.{subdomain}.tiles.virtualearth.net/tiles/h{quadkey}.jpeg?g=3415&mkt={culture}";
 imageUrlSubdomains =                     (
 t0,
 t1,
 t2,
 t3
 );
 imageWidth = 256;
 imageryProviders = "<null>";
 vintageEnd = "<null>";
 vintageStart = "<null>";
 zoomMax = 21;
 zoomMin = 1;
 }
 );
 }
 );
 statusCode = 200;
 statusDescription = OK;
 traceId = "ec50f2eab249436aa569655135f16c37|DB40061119|02.00.130.2400|";
 }
 
 */


-(void)BingAuthenticationParser{
	
	[self validateJSON];
	if(_activeOperation.operationState>NetResponseStateComplete){
		_activeOperation.responseStatus=ValidationBingAuthenticationFailed;
		return;
	}
	
	NSArray *resourcesets=_responseDict[@"resourceSets"];
	if(resourcesets){
		NSDictionary *resources=resourcesets[0];
		if(resources){
			NSDictionary *responseDict=resources[@"resources"][0];
			
			_activeOperation.operationState=NetResponseStateComplete;
			_activeOperation.responseStatus=ValidationBingAuthenticationSuccess;
			
			[_activeOperation setResponseWithValue:@{DATAPROVIDER:responseDict}];
			
		}else{
			_activeOperation.responseStatus=ValidationBingAuthenticationFailed;
		}
	}else{
		_activeOperation.responseStatus=ValidationBingAuthenticationFailed;
	}
	
	
}


@end
