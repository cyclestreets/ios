//
//  AppConstants.h
//  CycleStreets
//
//  Created by Neil Edwards on 16/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class BUNetworkOperation;

#if defined (CONFIGURATION_Debug)
#define ENABLEDEBUGTRACE 1
#else
#define ENABLEDEBUGTRACE 0
#endif

#define ENABLEOS6ACTIVITYMODE 0

enum  {
	
	CSRoutePlanTypeFastest=0,
	CSRoutePlanTypeBalanced=1,
	CSRoutePlanTypeQuietest=2,
	CSRoutePlanTypeShortest=3,
	CSRoutePlanTypeNone=-1
};
typedef int CSRoutePlanType;


typedef void (^ParserCompletionBlock)(BUNetworkOperation *operation);
typedef void (^ParserErrorBlock)(BUNetworkOperation *operation, NSError *error);




typedef NS_ENUM(int, BUResponseStatusCode){

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
	ValidationPOIMapCategorySuccessNoEntries=1017,
	
	
	
	ValidationSuccessMIN=ValidationLoginSuccess,
	ValidationSuccessMAX=ValidationPOIMapCategorySuccessNoEntries,
	
	// failures
	ValidationLoginFailed=2000, // 2000
	ValidationSearchFailed=2001,
	ValidationRegisterFailed=2005,
	ValidationEmailInvalid=2006,
	ValidationUserNameExists=2007,
	ValidationEmailNotRecognised=2008,
	ValidationRetrievePhotosFailed=2009,
	ValidationUserPhotoUploadFailed=2010,
	ValidationRequestParameterInvalid=2013,
	ValidationPOIListingFailure=2011,
	ValidationPOICategoryFailure=2016,
    ValidationCalculateRouteFailed=2017,
    ValidationRetrieveRouteByIdFailed=2018,
	ValidationCategoriesFailed=2019,
	ValidationPOIMapCategoryFailed=2020,
	
	ValidationCalculateRouteFailedOffNetwork=122711,
	
	ValidationFailureMIN=ValidationLoginFailed,
	ValidationFailureMAX=ValidationPOIMapCategoryFailed,
	
	// checking
	ValdationInvalidCode=9997,
	ValdationValidFailureCode=9998,
	ValdationValidSuccessCode=9999
	
};


typedef NS_ENUM(NSUInteger, ApplicationBuildTarget) {
	ApplicationBuildTarget_CycleStreets,
	ApplicationBuildTarget_CNS
};



extern NSString *const DEVICETYPE;

// mapping

extern NSString *const MAPPING_BASE_OPENCYCLEMAP;
extern NSString *const MAPPING_BASE_OSM;
extern NSString *const MAPPING_BASE_OS;
extern NSString *const MAPPING_BASE_APPLE_VECTOR;
extern NSString *const MAPPING_BASE_APPLE_SATELLITE;
extern NSString *const MAPPING_BASE_CYCLENORTH;


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
extern NSString *const POIMAPLOCATION;
extern NSString *const PHOTOCATEGORIES;
extern NSString *const WAYPOINTMETADATA;
extern NSString *const LEISUREROUTE;


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
extern NSString *const POIMAPLOCATIONRESPONSE;
extern NSString *const LEISUREROUTERESPONSE;

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

extern CLLocationDistance const MIN_START_FINISH_DISTANCE;

 

@interface AppConstants : NSObject {
	
}

+(NSString*)authenticationForRequest:(NSString*)dataid ofType:(NSString*)type;

+ (CSRoutePlanType)planStringTypeToConstant:(NSString*)stringType;
+ (NSString*)planConstantToString:(CSRoutePlanType)parserType;
+ (NSArray*)planArray;

@end
