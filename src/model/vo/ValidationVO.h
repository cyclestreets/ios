//
//  ValidationVO.h
//
//  Created by Neil Edwards on 16/02/2010.
//  Copyright 2010 CycleStreets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"


enum  {
	// success
	ValidationLoginSuccess=1000,
	ValidationSearchSuccess=1001,
	ValidationRegisterSuccess=1005,
	ValidationRetrivedPasswordSuccess=1008,
	ValidationRetrievePhotosSuccess=1009,
	ValidationUserPhotoUploadSuccess=1010,
	ValidationPOIListingSuccess=1011,
	ValidationPOICategorySuccess=1012,
    ValidationCalculateRouteSuccess=1013,
    ValidationRetrieveRouteByIdSuccess=1014,
	ValidationCategoriesSuccess=1015,
	ValidationPOIMapCategorySuccess=1016,
	
	ValidationSuccessMIN=ValidationLoginSuccess,
	ValidationSuccessMAX=ValidationPOIMapCategorySuccess,
	
	// failures
	ValidationLoginFailed=2000, // 2000
	ValidationEmailInvalid=2006,
	ValidationUserNameExists=2007,
	ValidationEmailNotRecognised=2008,
	ValidationRetrievePhotosFailed=2009,
	ValidationUserPhotoUploadFailed=2010,
	ValidationRequestParameterInvalid=2013,
	ValidationRegisterFailed=2014,
	ValidationPOIListingFailure=2015,
	ValidationPOICategoryFailure=2016,
    ValidationCalculateRouteFailed=2017,
    ValidationRetrieveRouteByIdFailed=2018,
	ValidationCategoriesFailed=2019,
	ValidationPOIMapCategoryFailed=2020,
	
	ValidationCalculateRouteFailedOffNetwork=122711,
	
	ValidationFailureMIN=ValidationLoginFailed,
	ValidationFailureMAX=ValidationCalculateRouteFailedOffNetwork,
	
	// checking
	ValdationInvalidCode=9997,
	ValdationValidFailureCode=9998,
	ValdationValidSuccessCode=9999
	
};
typedef int ValidationStatusCode;

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
