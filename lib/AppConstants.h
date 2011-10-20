//
//  AppConstants.h
//  RND
//
//  Created by Neil Edwards on 16/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
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
extern NSString *const LOCATIONSEARCH;
extern NSString *const RETREIVELOCATIONPHOTOS;
extern NSString *const UPLOADUSERPHOTO;
extern NSString *const LOCATIONFEATURES;

// INTERNAL
extern NSString *const LOCATIONSEARCHRESPONSE;
extern NSString *const RETREIVELOCATIONPHOTOSRESPONSE;
extern NSString *const UPLOADUSERPHOTORESPONSE;
extern NSString *const LOCATIONFEATURESRESPONSE;
extern NSString *const ROUTEDATARESPONSE;


extern NSString *const MILES;
extern NSString *const KM;
 

@interface AppConstants : NSObject {
	
}


@end
