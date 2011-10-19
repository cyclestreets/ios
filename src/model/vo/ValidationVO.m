//
//  ValidationVO.m
//  RacingUK
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import "ValidationVO.h"
#import "GlobalUtilities.h"

@implementation ValidationVO
@synthesize returnMessage;
@synthesize returnCode;
@synthesize responseDict;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [returnMessage release], returnMessage = nil;
    [responseDict release], responseDict = nil;
	
    [super dealloc];
}





-(ValidationStatusCode)validationStatus{
	
	ValidationStatusCode codecheck=[self isReturnCodeValid];
	if(codecheck==ValdationValidSuccessCode || codecheck==ValdationValidFailureCode){
		return returnCode;
	}else {
		BetterLog(@"[ERROR] returnCode %i is out of Range ",returnCode);
		return ValdationInvalidCode;
	}

	
}


-(ValidationStatusCode)isReturnCodeValid{
	
	for (int i=ValidationSuccessMIN; i<=ValidationSuccessMAX; i++) {
		if(returnCode==i){
			return ValdationValidSuccessCode;
		}
	}
	for (int i=ValidationFailureMIN; i<=ValidationFailureMAX; i++) {
		if(returnCode==i){
			return ValdationValidFailureCode;
		}
	}
	
	return ValdationInvalidCode;
}




- (id)init {
    if (self = [super init]) {
		
    }
    return self;
}

@end
