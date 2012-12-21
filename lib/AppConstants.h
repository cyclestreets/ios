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


extern NSString *const DEVICETYPE;

// mapping

extern NSString *const MAPPING_BASE_OPENCYCLEMAP;
extern NSString *const MAPPING_BASE_OSM;
extern NSString *const MAPPING_BASE_OS;

extern NSString *const MAPPING_ATTRIBUTION_OPENCYCLEMAP;
extern NSString *const MAPPING_ATTRIBUTION_OSM;
extern NSString *const MAPPING_ATTRIBUTION_OS;




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
extern NSString *const LOCATIONSEARCH;
extern NSString *const RETREIVELOCATIONPHOTOS;
extern NSString *const UPLOADUSERPHOTO;
extern NSString *const LOCATIONFEATURES;
extern NSString *const POILISTING;
extern NSString *const POICATEGORYLOCATION;
extern NSString *const PHOTOCATEGORIES;

// INTERNAL
extern NSString *const CALCULATEROUTERESPONSE;
extern NSString *const RETRIEVEROUTEBYIDRESPONSE;
extern NSString *const LOCATIONSEARCHRESPONSE;
extern NSString *const RETREIVELOCATIONPHOTOSRESPONSE;
extern NSString *const UPLOADUSERPHOTORESPONSE;
extern NSString *const LOCATIONFEATURESRESPONSE;
extern NSString *const NEWROUTEBYIDRESPONSE;
extern NSString *const POILISTINGRESPONSE;
extern NSString *const POICATEGORYLOCATIONRESPONSE;
extern NSString *const SAVEDROUTEUPDATE;
extern NSString *const MAPSTYLECHANGED;

extern NSString *const GPSLOCATIONUPDATE;
extern NSString *const GPSLOCATIONFAILED;
extern NSString *const GPSLOCATIONCOMPLETE;
extern NSString *const GPSLOCATIONDISABLED;

extern NSString *const EVENTMAPROUTEPLAN;
extern NSString *const PHOTOWIZARDCATEGORYUPDATE;

extern NSString *const CSPLANTYPE_FASTEST;
extern NSString *const CSPLANTYPE_SHORTEST;
extern NSString *const CSPLANTYPE_BALANCED;
extern NSString *const CSPLANTYPE_QUIETEST;
extern NSString *const CSPLANTYPE_NONE;


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

@end
