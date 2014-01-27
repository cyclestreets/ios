//
//  NetResponse.m
//  Buffer
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "NetResponse.h"
#import "GenericConstants.h"

@implementation NetResponse



-(instancetype)init{
	
	if (self = [super init]){
		_status=YES;
		_updated=YES;
	}
	return self;
}



+ (NSString*)errorTypeToString:(NetResponseError)errorType {
    
	if(errorType==NetResponseErrorInvalidResponse){
		return @"InvalidResponse";
	}else if (errorType==NetResponseErrorNotConnected){
		return @"ConnectionFailed";
	}else if (errorType==NetResponseErrorParserFailed) {
		return @"ParserFailed";
	}else if (errorType==NetResponseErrorNoResults) {
		return @"NoResults";
	}
	
    return NONE;
}


@end
