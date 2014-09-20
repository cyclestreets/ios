//
//  AppConstants.h
//  CycleStreets
//
//  Created by Neil Edwards on 16/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ENABLEDEBUGTRACE 1
#define ENABLEOS6ACTIVITYMODE 0

enum  {
	
	CSRoutePlanTypeFastest=0,
	CSRoutePlanTypeBalanced=1,
	CSRoutePlanTypeQuietest=2,
	CSRoutePlanTypeShortest=3,
	CSRoutePlanTypeNone=-1
};
typedef int CSRoutePlanType;


typedef NS_ENUM(int, ValidationStatusCode){

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
	
	ValidationSuccessMIN=ValidationLoginSuccess,
	ValidationSuccessMAX=ValidationCategoriesSuccess,
	
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
	
	ValidationCalculateRouteFailedOffNetwork=122711,
	
	ValidationFailureMIN=ValidationLoginFailed,
	ValidationFailureMAX=ValidationCalculateRouteFailedOffNetwork,
	
	// checking
	ValdationInvalidCode=9997,
	ValdationValidFailureCode=9998,
	ValdationValidSuccessCode=9999
	
};


extern NSString *const DEVICETYPE;

// mapping

extern NSString *const MAPPING_BASE_OPENCYCLEMAP;
extern NSString *const MAPPING_BASE_OSM;
extern NSString *const MAPPING_BASE_OS;
extern NSString *const MAPPING_BASE_APPLE;


extern NSString *const MAPPING_ATTRIBUTION_OPENCYCLEMAP;
extern NSString *const MAPPING_ATTRIBUTION_OSM;
extern NSString *const MAPPING_ATTRIBUTION_OS;

extern NSString *const MAPPING_TILETEMPLATE_APPLE;



// data ids

//search
extern NSString *const QUICKSEARCHDATAID;
extern NSString *const SEARCHDATAID;
extern NSString *const CSROUTESELECTED;
extern NSString *const CSLASTLOCATIONLOAD;

extern NSString *const CSMAPSTYLECHANGED;

extern NSString *const LOGINRESPONSE;
extern NSString *const REGISTERRESPONSE;
extern NSString *const PASSWORDRETRIEVALRESPONSE;

// OUTGOING
extern NSString *const CALCULATEROUTE;
extern NSString *const RETRIEVEROUTEBYID;
extern NSString *const UPDATEROUTE;
extern NSString *const LOCATIONSEARCH;
extern NSString *const RETREIVELOCATIONPHOTOS;
extern NSString *const RETREIVEROUTEPHOTOS;
extern NSString *const UPLOADUSERPHOTO;
extern NSString *const LOCATIONFEATURES;
extern NSString *const POILISTING;
extern NSString *const POICATEGORYLOCATION;
extern NSString *const PHOTOCATEGORIES;
extern NSString *const WAYPOINTMETADATA;


// INTERNAL
extern NSString *const CALCULATEROUTERESPONSE;
extern NSString *const RETRIEVEROUTEBYIDRESPONSE;
extern NSString *const LOCATIONSEARCHRESPONSE;
extern NSString *const RETREIVELOCATIONPHOTOSRESPONSE;
extern NSString *const RETREIVEROUTEPHOTOSRESPONSE;
extern NSString *const UPLOADUSERPHOTORESPONSE;
extern NSString *const LOCATIONFEATURESRESPONSE;
extern NSString *const NEWROUTEBYIDRESPONSE;
extern NSString *const POILISTINGRESPONSE;
extern NSString *const POICATEGORYLOCATIONRESPONSE;
extern NSString *const SAVEDROUTEUPDATE;
extern NSString *const MAPSTYLECHANGED;
extern NSString *const USERACCOUNTLOGINSUCCESS;
extern NSString *const USERACCOUNTREGISTERSUCCESS;

extern NSString *const GPSLOCATIONUPDATE;
extern NSString *const GPSLOCATIONFAILED;
extern NSString *const GPSLOCATIONCOMPLETE;
extern NSString *const GPSSYSTEMLOCATIONCOMPLETE;
extern NSString *const GPSLOCATIONDISABLED;
extern NSString *const REVERSEGEOLOCATIONCOMPLETE;

extern NSString *const EVENTMAPROUTEPLAN;
extern NSString *const PHOTOWIZARDCATEGORYUPDATE;

extern NSString *const CSPLANTYPE_FASTEST;
extern NSString *const CSPLANTYPE_SHORTEST;
extern NSString *const CSPLANTYPE_BALANCED;
extern NSString *const CSPLANTYPE_QUIETEST;
extern NSString *const CSPLANTYPE_NONE;


// Tab bar ids: must be ket in sync with UI naming via the plist

extern NSString *const TABBAR_MAP;
extern NSString *const TABBAR_ITINERARY;
extern NSString *const TABBAR_ROUTES;
extern NSString *const TABBAR_REPORT;
extern NSString *const TABBAR_WIZARD;
extern NSString *const TABBAR_ACCOUNT;
extern NSString *const TABBAR_CREDITS;
extern NSString *const TABBAR_SETTINGS;




extern NSString *const MILES;
extern NSString *const KM;


extern NSString *const SAVEDROUTE_FAVS;
extern NSString *const SAVEDROUTE_RECENTS;

extern NSString *const CYCLESTREETSURLSCHEME;

 

@interface AppConstants : NSObject {
	
}

+(NSString*)authenticationForRequest:(NSString*)dataid ofType:(NSString*)type;

+ (CSRoutePlanType)planStringTypeToConstant:(NSString*)stringType;
+ (NSString*)planConstantToString:(CSRoutePlanType)parserType;
+ (NSArray*)planArray;

@end
