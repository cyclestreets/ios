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
							 RETREIVEROUTEPHOTOS:[NSValue valueWithPointer:@selector(RetrievePhotosParser)]};
	}
	return self;
}


-(void)parseDataForOperation:(BUNetworkOperation* )networkOperation success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure{
	
	BetterLog(@"");
    
    NSError *error=nil;
	SEL parserMethod=[[_parserMethods objectForKey:networkOperation.dataid] pointerValue];
	
	 if(parserMethod==nil){
		 BetterLog(@"[ERROR] ApplicationXMLParser:parseXMLForType: parser for type %@ not found!",_activeOperation.dataid);
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
			
			BetterLog(@"[DEBUG] Success activeResponse.dataid=%@ activeResponse.requestid=%@",_activeOperation.dataid,_activeOperation.requestid);
			
			success(_activeOperation);
			
		}else {
			
			BetterLog(@"[ERROR] ApplicationXMLParser:XMLParserDidFail for DataId=%@",_activeOperation.dataid);
			
			failure(_activeOperation,error);
		}
		
		
		
		
	}else{
		
		// parser error
		
		BetterLog(@"[ERROR] Neither JSON decoders able to parse response data");
		_activeOperation.operationState=NetResponseStateFailedWithError;
		_activeOperation.operationError=NetResponseErrorParserFailed;
		failure(_activeOperation,error);
		
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




@end
