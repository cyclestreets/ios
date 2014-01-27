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


@interface ApplicationJSONParser()

@property (nonatomic, retain)		NetResponse                 * activeResponse;
@property (nonatomic, retain)		NSDictionary                * parserMethods;
@property (nonatomic, retain)		NSDictionary                * responseDict;
@property (nonatomic, retain)		NSString                    * parserError;


@end



@implementation ApplicationJSONParser
SYNTHESIZE_SINGLETON_FOR_CLASS(ApplicationJSONParser);



-(instancetype)init{
	if (self = [super init])
	{
        
//		self.parserMethods=@{[AppConstants dataTypeToStringType:SEARequestDataTypeLogin]:[NSValue valueWithPointer:@selector(UserAccountLoginParser)],
//                             [AppConstants dataTypeToStringType:SEARequestDataTypeDeviceInviteSharerEmail]:[NSValue valueWithPointer:@selector(InviteSharerParser)],
//                             [AppConstants dataTypeToStringType:SEARequestDataTypeDeviceInviteSharerSMS]:[NSValue valueWithPointer:@selector(InviteSharerParser)],
//                             [AppConstants dataTypeToStringType:SEARequestDataTypeAppUrl]:[NSValue valueWithPointer:@selector(AppUrlParser)],
//                             [AppConstants dataTypeToStringType:SEARequestDataTypeDeviceStatus]:[NSValue valueWithPointer:@selector(DeviceStatusParser)],
//                             [AppConstants dataTypeToStringType:SEARequestDataTypeUserDevices]:[NSValue valueWithPointer:@selector(UserDevicesParser)]};
	}
	return self;
}


-(void)parseDataForResponseData:(NSMutableData* )responseData forRequestType:(NSString*)requestType success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure{
	
	BetterLog(@"");
    
    NSError *error=nil;
    
    
	if([responseData isKindOfClass:[NSDictionary class]]){
        self.responseDict=(NSDictionary*)responseData;
    }else{
       self.responseDict=[[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:&error];
    }
	
    
    if(error!=nil){
        
        BetterLog(@"[ERROR]: Unable to Deserialise JSON with JSONDecoder, Failing error was: %@",error.userInfo);
        
    }
	
    
    self.activeResponse=[[NetResponse alloc]init];
    _activeResponse.requestType=requestType;
    
    if(error==nil){
        
        SEL parserMethod=[[_parserMethods objectForKey:requestType] pointerValue];
        
        if(parserMethod!=nil){
            
            [self performSelector:parserMethod];
            
            if(_activeResponse.status==YES){
                
                _activeResponse.responseState=NetResponseStateComplete;
                success(_activeResponse);
                
            }else {
                
                _activeResponse.responseState=NetResponseStateFailedWithError;
                _activeResponse.errorType=NetResponseErrorInvalidResponse;
                failure(_activeResponse,error);
                
            }
            
            
        }else {
            
            BetterLog(@"[ERROR] JSONParser:parseJSONForType: parser for type %@ not found!",requestType);
            _activeResponse.responseState=NetResponseStateFailedWithError;
            _activeResponse.errorType=NetResponseErrorParserUnknown;
            failure(_activeResponse,error);
            
        }
        
        
        
        
    }else{
        
        // parser error
        
        BetterLog(@"[ERROR] Neither JSON decoders able to parse response data");
        _activeResponse.responseState=NetResponseStateFailedWithError;
        _activeResponse.errorType=NetResponseErrorParserFailed;
        failure(_activeResponse,error);
        
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
#pragma mark PARSERS



#pragma mark Login




@end
