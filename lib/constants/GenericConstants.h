//
//  GenericConstants.h
//  ChromaAppCore
//
//  Created by Neil Edwards on 18/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^GenericCompletionBlock)(BOOL complete,NSString *error);


extern NSString *const SECUREUDID_DOMAIN;
extern NSString *const SECUREUDID_SALT;


extern NSString *const STARTUPERROR_SERVICELOADFAILED;
extern NSString *const STARTUPERROR_CONFIGLOADFAILED;
extern NSString *const APPSTATE_DEVELOPMENT;
extern NSString *const APPSTATE_STAGING;
extern NSString *const APPSTATE_LIVE;


//user
extern NSString *const LOGIN;
extern NSString *const REGISTER; 
extern NSString *const PASSWORDRETRIEVAL;
extern NSString *const REMOVEUSERDEVICE;
extern NSString *const DEACTIVATEPUSHNOTIFICATIONS; 
extern NSString *const ACTIVATEPUSHNOTIFICATIONS; 




// request types
extern NSString *const POST;
extern NSString *const GET;
extern NSString *const URL;
extern NSString *const POSTJSON;
extern NSString *const GETPOST;
extern NSString *const IMAGEPOST;
extern NSString *const FILEUPLOADPROGRESS;


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
extern NSString *const ALERT;
extern NSString *const NOTE;
extern NSString *const RESULT;
extern NSString *const SEARCH;
extern NSString *const EMPTYSTRING;
extern NSString *const EVENTDICT;
extern NSString *const NONE;
extern NSString *const SHORTDATE;
extern NSString *const ERRORTYPE;
extern NSString *const EVENTTYPE;
extern NSString *const ID;
extern NSString *const CONTROLLER;
extern NSString *const DATAPROVIDER;
extern NSString *const INDEX;

// nav button consts
extern NSString *const RIGHT;
extern NSString *const LEFT;
extern NSString *const NEXT;
extern NSString *const PREV;




// view modes
extern NSString *const UITYPE_NAV;
extern NSString *const UITYPE_CONTROLUI;
extern NSString *const UITYPE_CONTROLUI_HIGH;
extern NSString *const UITYPE_CONTROLHEADERUI;
extern NSString *const UITYPE_MODALUI;
extern NSString *const UITYPE_SELFFRAME;
extern NSString *const UITYPE_IPADDETAIL;



// events
extern NSString *const XMLPARSERDIDCOMPLETE;
extern NSString *const REQUESTDATAREFRESH;
extern NSString	*const PRODUCTLISTCOMPLETE;
extern NSString *const REMOTEFILELOADED;
extern NSString *const	LOCALFILELOADED;
extern NSString *const REMOTEFILEFAILED;
extern NSString *const SERVERCONNECTIONFAILED;
extern NSString *const XMLPARSERDIDCOMPLETENOUPDATE;
extern NSString *const REQUESTWASACTIVE; 
extern NSString *const REQUESTDATAREFRESHFROMUSER; 
extern NSString *const REMOTEDATAREQUESTED;
extern NSString *const REQUESTDIDCOMPLETEFROMMODEL;
extern NSString *const REQUESTDIDCOMPLETEFROMCACHE;
extern NSString *const REQUESTDIDCOMPLETEFROMSERVER;
extern NSString *const REQUESTDIDCOMPLETENOENTRIES;
extern NSString *const REQUESTDIDCOMPLETE_NOUPDATE;
extern NSString *const CONNECTIONVALIDATION;
extern NSString *const CLLOCATIONUPDATE;
extern NSString *const TEXTFIELDEDITFRAME;
extern NSString *const BUCELLNOTIFICATION;
extern NSString *const REQUESTNOTEDELETENAVIGATION;
extern NSString *const PUSHNOTIFICATIONTOKENAVAILABLE;

extern NSString *const REQUESTDIDCOMPLETE;
extern NSString *const REQUESTDIDFAIL;

extern NSString *const RESPONSESERVER;
extern NSString *const RESPONSEMODEL;
extern NSString *const RESPONSECACHE;



// authentication
extern NSString *const AUTHENTICATION_USERNAME;
extern NSString *const AUTHENTICATION_PASSWORD;





//errors
extern NSString *const	XMLPARSERDIDFAILPARSING;
extern NSString *const	XMLPARSER_RESPONSENODEMISSING;
extern NSString *const	XMLPARSER_RESPONSEDATAMISSING;
extern NSString *const	XMLPARSER_RESPONSENOENTRIES;
extern NSString *const	XMLPARSER_YTFEEDMISSING;
extern NSString *const	XMLPARSER_XMLSYNTAXERROR;
extern NSString *const	DATAREQUESTFAILED;


extern NSString *const	JSONPARSERDIDCOMPLETE;
extern NSString *const	JSONPARSERDIDFAILPARSING ;
extern NSString *const	JSONPARSER_RESPONSENODEMISSING ;
extern NSString *const	JSONPARSER_RESPONSEDATAMISSING ;
extern NSString *const	JSONPARSER_RESPONSENOENTRIES ;



extern NSString *const STARTUPERROR_SERVICELOADFAILEDSTRING;
extern NSString *const STARTUPERROR_SETTINGSFAILED;
extern NSString *const STARTUPERROR_STYLESFAILED;
extern NSString *const STARTUPERROR_DATASOURCE;
extern NSString *const STARTUPERROR_STRINGSFAILED;



#define IPHONE5HEIGHT 568
#define IPHONE4HEIGHT 480
#define NAVIGATIONHEIGHT 44
#define CONTROLUIHEIGHT 44
#define TABHEIGHT 50
#define STATUSHEIGHT 20
#define SCREENHEIGHT ( IS_IPHONE_5 ? IPHONE5HEIGHT-STATUSHEIGHT : IPHONE4HEIGHT-STATUSHEIGHT)
#define FULLSCREENHEIGHT ( IS_IPHONE_5 ? IPHONE5HEIGHT : IPHONE4HEIGHT)

#define NAVTABVIEWHEIGHT (SCREENHEIGHT-NAVIGATIONHEIGHT-TABHEIGHT)
#define NAVTABLEHEIGHT ((SCREENHEIGHT)-NAVIGATIONHEIGHT-TABHEIGHT)
#define NAVCONTROLMODALHEIGHT ((SCREENHEIGHT)-NAVIGATIONHEIGHT-NAVIGATIONHEIGHT)
#define SCREENHEIGHTWITHCONTROLUI (NAVTABLEHEIGHT-CONTROLUIHEIGHT)
#define SCREENHEIGHTWITHNAVIGATION (SCREENHEIGHT-NAVIGATIONHEIGHT)
#define SCREENHEIGHTWITHNAVANDTAB (SCREENHEIGHT-NAVIGATIONHEIGHT-TABHEIGHT)
#define SCREENHEIGHTWITHMODALNAV (SCREENHEIGHT-NAVIGATIONHEIGHT)

// dimensions

extern int const SCREENWIDTH;
extern int const IPADSCREENWIDTH;
extern int const IPADMASTERVIEWWIDTH;
extern int const SCREENHEIGHTWITHCONTROLANDHEADERUI;
extern int const SCREENHEIGHTWITHCONTROLANDHEADERUI_IPAD_LANDSCAPE;
extern int const SCREENHEIGHTMANAGE_IPAD_LANDSCAPE;
extern int const NAVTABVIEWHEIGHT_IPAD_LANDSCAPE;
extern int const UIWIDTH;
extern int const WIDEUIWIDTH;
extern int const FORMWIDTH;
extern int const TABBARHEIGHT;
extern int const HEADERCONTROLHEIGHT;
extern int const IPADDETAILVIEWWIDTH;
extern int const IPADDETAILUIVIEWWIDTH;
// tables

extern int const SHORTCELLHEIGHT;
extern int const NEWSCELLHEIGHT;
extern int const STANDARDCELLHEIGHT;
extern int const HALFCELLHEIGHT;

extern int const TABBARMORELIMIT;


// Alert Error Strings
extern NSString *const CONNECTIONERROR;
extern NSString *const XMLPARSERERROR;
extern NSString *const SERVERDOWNERROR;
extern NSString *const JSONPARSERERROR;

// Error Messages
extern NSString *const UNABLETOCONTACT;
extern NSString *const INVALIDRESPONSE;
extern NSString *const CONNECTIONCACHE;
extern NSString *const SERVERDOWN;


extern NSString *const	kUSERSTATEKEY_NAVIGATION;
extern NSString *const	kUSERSTATEKEY_CONTEXT;
extern NSString *const	kUSERSTATEKEY_LASTOPENEDDATE;


// Utility Tags
#define kTextEntryAlertTag 999111
#define kTextEntryAlertFieldTag 999112


enum{
	DATATYPE_XML,
	DATATYPE_PLIST,
	DATATYPE_JSON,
	DATATYPE_OPTIONAL,
	DATATYPE_NONE
};
typedef int DataParserType;

typedef enum: int{
    
    DataSourceRequestCacheTypeUseCache,
    DataSourceRequestCacheTypeUseNetwork
    
    
}DataSourceRequestCacheType;

@interface GenericConstants : NSObject{
	
}
+ (DataParserType)parserStringTypeToConstant:(NSString*)stringType;
+ (NSString*)parserConstantToString:(DataParserType)parserType;

@end
