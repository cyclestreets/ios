//
//  ValidationVO.h
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 CycleStreets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"



@interface ValidationVO : NSObject {
	NSString	*returnMessage; // string error
	int			returnCode; // code for response transaction status
	NSMutableDictionary  *responseDict; // dictionary for response data
	
}

@property (nonatomic, strong)		NSString		*returnMessage;
@property (nonatomic)		int		returnCode;
@property (nonatomic, strong)		NSMutableDictionary		*responseDict;


@property (nonatomic,readonly) int validationStatus;

-(ValidationStatusCode)isReturnCodeValid;
@end
