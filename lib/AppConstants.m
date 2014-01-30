//
//  AppConstants.m
//  CycleStreets
//
//  Created by Neil Edwards on 16/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import "AppConstants.h"

NSString *const DEVICETYPE=@"iPhone";


// map const

NSString *const MAPPING_BASE_OPENCYCLEMAP = @"OpenCycleMap";
NSString *const MAPPING_BASE_OSM = @"OpenStreetMap";
NSString *const MAPPING_BASE_OS = @"OS";

NSString *const MAPPING_ATTRIBUTION_OPENCYCLEMAP = @"(c) OpenStreetMap and contributors, CC-BY-SA; Map images (c) OpenCycleMap";
NSString *const MAPPING_ATTRIBUTION_OSM = @"(c) OpenStreetMap and contributors, CC-BY-SA";
NSString *const MAPPING_ATTRIBUTION_OS = @"Contains Ordnance Survey data (c) Crown copyright and database right 2010";


//
/***********************************************
 * @description			DATA REQUEST IDS
 ***********************************************/
//

//search
NSString *const QUICKSEARCHDATAID=@"QuickSearch";
NSString *const SEARCHDATAID=@"Search";

NSString *const CSMAPSTYLECHANGED=@"NotificationMapStyleChanged";

NSString *const CSROUTESELECTED=@"CSRouteSelected";
NSString *const CSLASTLOCATIONLOAD=@"CSLastLocationLoad";


NSString *const LOGINRESPONSE=@"LOGINRESPONSE";
NSString *const REGISTERRESPONSE=@"REGISTERRESPONSE";
NSString *const PASSWORDRETRIEVALRESPONSE=@"PASSWORDRETRIEVALRESPONSE";

// OUTGOING
NSString *const CALCULATEROUTE=@"CalculateRoute";
NSString *const RETRIEVEROUTEBYID=@"RetrieveRouteById";
NSString *const LOCATIONSEARCH=@"LocationSearch";
NSString *const RETREIVELOCATIONPHOTOS=@"RetrieveLocationPhotos";
NSString *const UPLOADUSERPHOTO=@"UploadUserPhotos";
NSString *const LOCATIONFEATURES=@"LocationFeatures";
NSString *const POILISTING=@"PoiListing";
NSString *const POICATEGORYLOCATION=@"PoiCategoryLocation";
NSString *const PHOTOCATEGORIES=@"PhotoCategories";

NSString *const GPSUPLOAD=@"GPSUpload";
NSString *const RESPONSE_GPSUPLOAD=@"GpsuploadResponse";
NSString *const RESPONSE_GPSUPLOADMULTI=@"GpsuploadMultiResponse";


//INTERNAL
NSString *const CALCULATEROUTERESPONSE=@"CALCULATEROUTERESPONSE";
NSString *const RETRIEVEROUTEBYIDRESPONSE=@"RETRIEVEROUTEBYIDRESPONSE";
NSString *const LOCATIONSEARCHRESPONSE=@"LOCATIONSEARCHRESPONSE";
NSString *const RETREIVELOCATIONPHOTOSRESPONSE=@"RETREIVELOCATIONPHOTOSRESPONSE";
NSString *const UPLOADUSERPHOTORESPONSE=@"UPLOADUSERPHOTORESPONSE";
NSString *const LOCATIONFEATURESRESPONSE=@"LOCATIONFEATURESRESPONSE";
NSString *const NEWROUTEBYIDRESPONSE=@"NEWROUTEBYIDRESPONSE";
NSString *const POILISTINGRESPONSE=@"POILISTINGRESPONSE";
NSString *const POICATEGORYLOCATIONRESPONSE=@"POICATEGORYLOCATIONRESPONSE";
NSString *const SAVEDROUTEUPDATE=@"SAVEDROUTEUPDATE";
NSString *const MAPSTYLECHANGED=@"MAPSTYLECHANGED";
NSString *const USERACCOUNTLOGINSUCCESS=@"USERACCOUNTLOGINSUCCESS";
NSString *const MAPUNITCHANGED=@"MAPUNITCHANGED";

NSString *const GPSLOCATIONUPDATE=@"GPSLOCATIONUPDATE";
NSString *const GPSLOCATIONFAILED=@"GPSLOCATIONFAILED";
NSString *const GPSLOCATIONDISABLED=@"GPSLOCATIONDISABLED";
NSString *const GPSLOCATIONCOMPLETE=@"GPSLOCATIONCOMPLETE";
NSString *const REVERSEGEOLOCATIONCOMPLETE=@"REVERSEGEOLOCATIONCOMPLETE";
NSString *const EVENTMAPROUTEPLAN=@"EVENTMAPROUTEPLAN";
NSString *const PHOTOWIZARDCATEGORYUPDATE=@"PHOTOWIZARDCATEGORYUPDATE";

NSString *const CSPLANTYPE_FASTEST=@"fastest";
NSString *const CSPLANTYPE_SHORTEST=@"shortest";
NSString *const CSPLANTYPE_BALANCED=@"balanced";
NSString *const CSPLANTYPE_QUIETEST=@"quietest";
NSString *const CSPLANTYPE_NONE=@"csplan_none";

//
/***********************************************
 * @description			String Constants
 ***********************************************/
//
NSString *const MILES=@"miles";
NSString *const KM=@"kilometers";

NSString *const SAVEDROUTE_FAVS=@"SAVEDROUTE_FAVS";
NSString *const SAVEDROUTE_RECENTS=@"SAVEDROUTE_RECENTS";


NSString *const CYCLESTREETSURLSCHEME=@"cyclestreets";


// Hackney

NSString *const HCSDISPLAYTRIPMAP=@"HCSDISPLAYTRIPMAP";





@implementation AppConstants

// returns username/passwords for requests that require authentication
+(NSString*)authenticationForRequest:(NSString*)dataid ofType:(NSString*)type{
	
//	if([dataid isEqualToString:NEWS] || [dataid isEqualToString:WATCHRUK] || [dataid isEqualToString:TIPSTER]){
//		
//		if ([type isEqualToString:AUTHENTICATION_USERNAME]) {
//			return RACINGUKCMS_USERNAME;
//		}
//		
//		if ([type isEqualToString:AUTHENTICATION_PASSWORD]) {
//			return RACINGUKCMS_PASSWORD;
//		}
//		
//	}
	return nil;
}

+ (CSRoutePlanType)planStringTypeToConstant:(NSString*)stringType{
	
	if([stringType isEqualToString:CSPLANTYPE_FASTEST]){
		return CSRoutePlanTypeFastest;
	}else if ([stringType isEqualToString:CSPLANTYPE_BALANCED]){
		return CSRoutePlanTypeBalanced;
	}else if ([stringType isEqualToString:CSPLANTYPE_SHORTEST]) {
		return CSRoutePlanTypeShortest;
	}else if ([stringType isEqualToString:CSPLANTYPE_QUIETEST]) {
		return CSRoutePlanTypeQuietest;
	}
	return CSRoutePlanTypeNone;
}


+ (NSString*)planConstantToString:(CSRoutePlanType)parserType{
	
	if(parserType==CSRoutePlanTypeFastest){
		return CSPLANTYPE_FASTEST;
	}else if (parserType==CSRoutePlanTypeBalanced){
		return CSPLANTYPE_BALANCED;
	}else if (parserType==CSRoutePlanTypeShortest) {
		return CSPLANTYPE_SHORTEST;
	}else if (parserType==CSRoutePlanTypeQuietest) {
		return CSPLANTYPE_QUIETEST;
	}
	
    return CSPLANTYPE_NONE;
}


@end
