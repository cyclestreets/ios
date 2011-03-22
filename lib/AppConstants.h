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
//user
extern NSString *const LOGIN;
extern NSString *const REGISTER; 
extern NSString *const PASSWORDRETRIEVAL;

//search
extern NSString *const QUICKSEARCHDATAID;
extern NSString *const SEARCHDATAID;

extern NSString *const CSROUTESELECTED;

extern NSString *const LOGINRESPONSE;
extern NSString *const REGISTERRESPONSE;
extern NSString *const PASSWORDRETRIEVALRESPONSE;




// request types
extern NSString *const POST;
extern NSString *const GET;
extern NSString *const URL;
extern NSString *const GETPOST;


// data sources
extern NSString *const LOCALDATA;
extern NSString *const REMOTEDATA;
extern NSString *const REMOTEURL;
extern NSString *const USER;
extern NSString *const SYSTEM;



// string constants
extern NSString *const DATE;
extern NSString *const RESPONSE;
extern NSString *const REQUEST;
extern NSString *const STATE;
extern NSString *const PARAMARRAY;
extern NSString *const CURRENCY;
extern NSString *const DATATYPE;
extern NSString *const OK;
extern NSString *const ABANDONED;
extern NSString *const CLOSE;
extern NSString *const ERROR;
extern NSString *const ZERO;
extern NSString *const SUCCESS;
extern NSString *const MESSAGE;
extern NSString *const MILES;
extern NSString *const KM;

// view modes
extern NSString *const UITYPE_NAV;
extern NSString *const UITYPE_CONTROLUI;
extern NSString *const UITYPE_CONTROLHEADERUI;
extern NSString *const UITYPE_MODALUI;



// events
extern NSString *const XMLPARSERDIDCOMPLETE;
extern NSString *const REQUESTDATAREFRESH;
extern NSString	*const PRODUCTLISTCOMPLETE;
extern NSString *const REMOTEFILELOADED;
extern NSString *const REMOTEFILEFAILED;
extern NSString *const XMLPARSERDIDCOMPLETENOUPDATE;
extern NSString *const REQUESTWASACTIVE; 
extern NSString *const REQUESTDATAREFRESHFROMUSER; 
extern NSString *const REMOTEDATAREQUESTED;
extern NSString *const REQUESTDIDCOMPLETEFROMMODEL;
extern NSString *const REQUESTDIDCOMPLETEFROMCACHE;
extern NSString *const REQUESTDIDCOMPLETEFROMSERVER;
extern NSString *const REQUESTDIDCOMPLETENOENTRIES;
extern NSString *const CONNECTIONVALIDATION;
extern NSString *const CLLOCATIONUPDATE;
extern NSString *const TEXTFIELDEDITFRAME;
extern NSString *const SEARCHDIDCOMPLETE;
extern NSString *const QUICKSEARCHDIDCOMPLETE;
extern NSString *const LOGINRESPONSE;
extern NSString *const REGISTERRESPONSE;
extern NSString *const PASSWORDRETRIEVALRESPONSE;



//errors
extern NSString *const	XMLPARSERDIDFAILPARSING;
extern NSString *const	XMLPARSER_RESPONSENODEMISSING;
extern NSString *const	XMLPARSER_RESPONSEDATAMISSING;
extern NSString *const	XMLPARSER_RESPONSENOENTRIES;
extern NSString *const	XMLPARSER_YTFEEDMISSING;
extern NSString *const	XMLPARSER_XMLSYNTAXERROR;
extern NSString *const	DATAREQUESTFAILED;
extern NSString *const STARTUPERROR_SERVICELOADFAILED;
extern NSString *const STARTUPERROR_SETTINGSFAILED;
extern NSString *const STARTUPERROR_STYLESFAILED;
extern NSString *const STARTUPERROR_DATASOURCE;
extern NSString *const STARTUPERROR_STRINGSFAILED;



// dimensions

extern int const SCREENWIDTH;
extern int const SCREENHEIGHT;
extern int const SCREENHEIGHTWITHCONTROLUI;
extern int const SCREENHEIGHTWITHCONTROLANDHEADERUI;
extern int const SCREENHEIGHTWITHNAVIGATION;
extern int const SCREENHEIGHTWITHNAVANDTAB;
extern int const CONTROLUIHEIGHT;
extern int const UIWIDTH;
extern int const FORMWIDTH;
extern int const NAVIGATIONHEIGHT;
extern int const TABBARHEIGHT;
extern int const NAVTABVIEWHEIGHT;
extern int const NAVCONTROLMODALHEIGHT;
extern int const HEADERCONTROLHEIGHT;
// tables

extern int const SHORTCELLHEIGHT;
extern int const NAVTABLEHEIGHT;
extern int const NEWSCELLHEIGHT;
extern int const STANDARDCELLHEIGHT;
extern int const HALFCELLHEIGHT;

extern int const TABBARMORELIMIT;


// Alert Error Strings
extern NSString *const CONNECTIONERROR;
extern NSString *const XMLPARSERERROR;

// Error Messages
extern NSString *const UNABLETOCONTACT;
extern NSString *const INVALIDRESPONSE;
extern NSString *const CONNECTIONCACHE;


/*
enum  {
	kDataTypeHorse=1,
	kDataTypeTrainer=2,
	kDataTypeJockey=3,
	kDataTypeNone=0
};
typedef int NagMeDataType;

enum  {
	RaceAlertTypeRace=1,
	RaceAlertTypeResult=2,
	RaceAlertTypeResultNone=0
};
typedef int RaceAlertDataType;
*/

@interface AppConstants : NSObject {

}

/*
+ (NSString*)dataTypeToStringType:(NagMeDataType)dataType;
+ (NagMeDataType)stringTypeToDataType:(NSString*)stringType;
*/

@end
