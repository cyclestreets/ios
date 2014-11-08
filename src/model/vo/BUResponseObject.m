//
//  ValidationVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import "BUResponseObject.h"
#import "GlobalUtilities.h"

@implementation BUResponseObject


- (instancetype)init
{
	self = [super init];
	if (self) {
		
	}
	return self;
}


-(BUResponseStatusCode)responseStatus{
	
	BUResponseStatusCode codecheck=[self isResponseCodeValid];
	if(codecheck==ValdationValidSuccessCode || codecheck==ValdationValidFailureCode){
		return _responseCode;
	}else {
		BetterLog(@"[ERROR] responseCode %i is out of Range ",_responseCode);
		return ValdationInvalidCode;
	}

	
}


-(BUResponseStatusCode)isResponseCodeValid{
	
	for (int i=ValidationSuccessMIN; i<=ValidationSuccessMAX; i++) {
		if(_responseCode==i){
			return ValdationValidSuccessCode;
		}
	}
	for (int i=ValidationFailureMIN; i<=ValidationFailureMAX; i++) {
		if(_responseCode==i){
			return ValdationValidFailureCode;
		}
	}
	
	return ValdationInvalidCode;
}




@end
