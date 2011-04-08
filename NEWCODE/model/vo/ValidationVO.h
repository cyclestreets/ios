//
//  ValidationVO.h
//  RacingUK
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 CycleStreets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

typedef struct{
	NSString *name;
	NSString *uuid;
	BOOL selected;
}Device;

enum  {
	// success
	ValidationLoginSuccess=1000,
	ValidationSearchSuccess=1001,
	ValidationRegisterSuccess=1005,
	ValidationRetrivedPasswordSuccess=1008,
	ValidationSuccessMIN=ValidationLoginSuccess,
	ValidationSuccessMAX=ValidationRetrivedPasswordSuccess,
	
	// failures
	ValidationLoginFailed=2000, // 2000
	ValidationEmailInvalid=2006,
	ValidationEmailExists=2007,
	ValidationEmailNotRecognised=2010,
	ValidationRequestParameterInvalid=2013,
	ValidationFailureMIN=ValidationLoginFailed,
	ValidationFailureMAX=ValidationRequestParameterInvalid,
	
	// checking
	ValdationInvalidCode=9997,
	ValdationValidFailureCode=9998,
	ValdationValidSuccessCode=9999
	
};
typedef int ValidationStatusCode;

@interface ValidationVO : NSObject {
	NSString	*returnMessage; // string error
	int			returnCode; // code for response transaction status
	NSData		*receipt; //
	NSString	*email; // user email
	NSString	*password; // user password
	NSString	*userID; // user id
	
	NSMutableDictionary  *responseDict; // dictionary for response specific properties
	
}

@property (nonatomic, retain)		NSString		*returnMessage;
@property (nonatomic)		int		returnCode;
@property (nonatomic, retain)		NSData		*receipt;
@property (nonatomic, retain)		NSString		*email;
@property (nonatomic, retain)		NSString		*password;
@property (nonatomic, retain)		NSString		*userID;
@property (nonatomic, retain)		NSMutableDictionary		*responseDict;


@property (nonatomic,readonly) int validationStatus;

-(ValidationStatusCode)isReturnCodeValid;
@end
