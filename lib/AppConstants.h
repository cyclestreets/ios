//
//  AppConstants.h
//  CycleStreets
//
//  Created by Neil Edwards on 16/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const DEVICETYPE;

// data ids

//search
extern NSString *const QUICKSEARCHDATAID;
extern NSString *const SEARCHDATAID;
extern NSString *const CSROUTESELECTED;

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


extern NSString *const MILES;
extern NSString *const KM;


extern NSString *const SAVEDROUTE_FAVS;
extern NSString *const SAVEDROUTE_RECENTS;
 

@interface AppConstants : NSObject {
	
}


@end
