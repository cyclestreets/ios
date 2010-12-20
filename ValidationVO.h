//
//  ValidationVO.h
//  RacingUK
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 Chroma. All rights reserved.
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
	ValidationHorseFound=1002,
	ValidationJockeyFound=1003,
	ValidationTrainerFound=1004,
	ValidationRegisterSuccess=1005,
	ValidationCreateAlertSuccess=1006,
	ValidationUpdateAlertSuccess=1007,
	ValidationRetrivedPasswordSuccess=1008,
	ValidationRaceAlertsSuccess=1009,
	ValidationNewRaceAlertsSuccess=1010,
	ValidationResultsAlertsSuccess=1011,
	ValidationRemoveRaceAlertSucess=1012,
	ValidationGetAlertsSuccess=1013,
	ValidationDeleteAlertSuccess=1014,
	ValidationGetNotesSuccess=1015,
	ValidationUpdateNoteSuccess=1016,
	ValidationDeleteNotesuccess=1017,
	ValidationShareNoteSuccess=1018,
	ValidationSuccessMIN=ValidationLoginSuccess,
	ValidationSuccessMAX=ValidationShareNoteSuccess,
	
	// failures
	ValidationLoginFailed=2000, // 2000
	ValidationSessionTokenExpired=2001, //2001
	ValidationSessionTokenInvalid=2002, //2
	ValidationHorseNotFound=2003, //3
	ValidationJockeyNotFound=2004, //4
	ValidationTrainerNotFound=2005,
	ValidationEmailInvalid=2006,
	ValidationEmailExists=2007,
	ValidationUnknownSubject=2008,
	ValidationAlertNotFound=2009,
	ValidationEmailNotRecognised=2010,
	ValidationRaceAlertNotFound=2011,
	ValidationNoteNotFound=2012,
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
