//
//  GenericConstants.m
//  ChromaAppCore
//
//  Created by Neil Edwards on 18/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "GenericConstants.h"



//
/***********************************************
 * @description			secure udid
 ***********************************************/
//

NSString *const SECUREUDID_DOMAIN = @"com.chromaagency.ios";
NSString *const SECUREUDID_SALT = @"2XRCVktftNnsdpMu2nFs7Ww0DfnpthT";



NSString *const STARTUPERROR_SERVICELOADFAILED=@"STARTUPERROR_SERVICELOADFAILED";
NSString *const STARTUPERROR_CONFIGLOADFAILED=@"STARTUPERROR_CONFIGLOADFAILED";
NSString *const APPSTATE_DEVELOPMENT=@"APPSTATE_DEVELOPMENT";
NSString *const APPSTATE_STAGING=@"APPSTATE_STAGING";
NSString *const APPSTATE_LIVE=@"APPSTATE_LIVE";


//
/***********************************************
 * @description			DATA REQUEST IDS
 ***********************************************/
//

//user
NSString *const LOGIN=@"Login";
NSString *const REGISTER=@"Register"; 
NSString *const PASSWORDRETRIEVAL=@"ForgottenPassword";
NSString *const REMOVEUSERDEVICE=@"RemoveUserDevice"; // remove this device from users account
NSString *const DEACTIVATEPUSHNOTIFICATIONS=@"DeactivatePNS"; 
NSString *const ACTIVATEPUSHNOTIFICATIONS=@"ActivatePNS"; 



//request types
NSString *const POST=@"POST";
NSString *const GET=@"GET";
NSString *const URL=@"URL";
NSString *const POSTJSON=@"POSTJSON";
NSString *const GETPOST=@"GETPOST";
NSString *const IMAGEPOST=@"IMAGEPOST";
NSString *const FILEUPLOADPROGRESS=@"FILEUPLOADPROGRESS";

//data sources
NSString *const LOCALDATA=@"localdata";
NSString *const REMOTEDATA=@"remotedata";
NSString *const REMOTEURL=@"remoteurl";
NSString *const USER=@"user";
NSString *const SYSTEM=@"system";



// string constants
NSString *const DATE=@"date";
NSString *const RESPONSE=@"response";
NSString *const REQUEST=@"request";
NSString *const STATE=@"state";
NSString *const PARAMARRAY=@"parameterarray";
NSString *const CURRENCY=@"currency";
NSString *const DATATYPE=@"dataid";
NSString *const OK=@"OK";
NSString *const ABANDONED=@"Abandoned";
NSString *const CLOSE=@"Close";
NSString *const ERROR=@"error";
NSString *const ZERO=@"0";
NSString *const SUCCESS=@"Success";
NSString *const MESSAGE=@"Message";
NSString *const ALERT=@"Alert";
NSString *const NOTE=@"Note";
NSString *const RESULT=@"Result";
NSString *const SEARCH=@"Search";
NSString *const EMPTYSTRING=@"";
NSString *const EVENTDICT=@"eventdict";
NSString *const NONE=@"none";
NSString *const SHORTDATE=@"SHORTDATE";
NSString *const ERRORTYPE=@"ERRORTYPE";
NSString *const EVENTTYPE=@"EVENTTYPE";


// nav button consts
NSString *const RIGHT=@"RIGHT";
NSString *const LEFT=@"LEFT";
NSString *const NEXT=@"NEXT";
NSString *const PREV=@"PREV";


// viewmodes
NSString *const UITYPE_NAV=@"UITypeNavonly";
NSString *const UITYPE_CONTROLUI=@"UITypeControlNav";
NSString *const UITYPE_CONTROLUI_HIGH=@"UITypeControlNavHigh";
NSString *const UITYPE_CONTROLHEADERUI=@"UITypeControlHeaderNav";
NSString *const UITYPE_MODALUI=@"UITypeModalNav";
NSString *const UITYPE_SELFFRAME=@"UITypeSelfFrame";
NSString *const UITYPE_IPADDETAIL=@"UITypeiPadDetail";




// events
NSString *const XMLPARSERDIDCOMPLETE = @"XMLParserDidComplete"; // remote xml parsing did complete new data is available
NSString *const REQUESTDATAREFRESH = @"RequestDataRefresh"; // request a programatic refresh of the data Provider
NSString *const REQUESTDATAREFRESHFROMUSER = @"RequestDataRefreshFromUser"; // request a user refresh of the data Provider
NSString *const	PRODUCTLISTCOMPLETE = @"ProductlistComplete";
NSString *const	REMOTEFILELOADED = @"RemoteFileMangerLoaded";  // the remote connection failed
NSString *const	XMLPARSERDIDCOMPLETENOUPDATE = @"XMLParserDidCompleteWithNoUpdate"; // the remote request returned no update, so use the cached data
NSString *const REQUESTWASACTIVE=@"datarequestwasactive"; // the requested data/request group is the active one do not refresh ui;
NSString *const REMOTEDATAREQUESTED=@"remotedatarequested"; // the request is contacting the server, the ui will need to indicate this.
NSString *const REQUESTDIDCOMPLETEFROMMODEL=@"requestdidcompletewithmodeldata"; // the request competed with data from memory
NSString *const REQUESTDIDCOMPLETEFROMCACHE=@"requestdidcompletewithcacheddata"; // the request competed with data from the file cache
NSString *const REQUESTDIDCOMPLETEFROMSERVER=@"requestdidcompletewithserverdata"; // the request competed with data from the server
NSString *const REQUESTDIDCOMPLETE_NOUPDATE=@"requestcompletednoupdatereceived"; // the request competed with data from the server but our copy is the newest
NSString *const REQUESTDIDCOMPLETENOENTRIES=@"requestcompletednoentries"; // the request competed with data from the server but there are no entries
NSString *const CONNECTIONVALIDATION=@"connectionvalidation"; // generic event for ConectionValidator, note dict contains further info
NSString *const TEXTFIELDEDITFRAME=@"tuitextfieldeditframeupdate"; // generic event for sending the textfield frame so we can adjust the scrollview for the keybaord size
NSString *const BUCELLNOTIFICATION=@"BUCELLNOTIFICATION"; // generic event for embedded cell buttons
NSString *const REQUESTNOTEDELETENAVIGATION=@"REQUESTNOTEDELETENAVIGATION"; // event for ManageVC to pop to correct VC when deleting a note
NSString *const PUSHNOTIFICATIONTOKENAVAILABLE=@"PUSHNOTIFICATIONTOKENAVAILABLE"; // We received a  valid token form Apple, used to notify UserManager for delayed DT responses



//errors
NSString *const	XMLPARSERDIDFAILPARSING = @"XMLParserDidFailParsing";
NSString *const	XMLPARSER_RESPONSENODEMISSING = @"XMLParser_ResponseNodeMissing";
NSString *const	XMLPARSER_RESPONSEDATAMISSING = @"XMLParser_ResponseDataMissing";
NSString *const	XMLPARSER_RESPONSENOENTRIES = @"XMLParser_ResponseNoEntries";
NSString *const	REMOTEFILEFAILED = @"RemoteFileMangerFailed";
NSString *const	SERVERCONNECTIONFAILED = @"SERVERCONNECTIONFAILED";// 404 ERRORS


NSString *const JSONPARSERDIDCOMPLETE = @"JSONParserDidComplete"; // remote xml parsing did complete new data is available
NSString *const	JSONPARSERDIDFAILPARSING = @"JSONParserDidFailParsing";
NSString *const	JSONPARSER_RESPONSENODEMISSING = @"JSONParser_ResponseNodeMissing";
NSString *const	JSONPARSER_RESPONSEDATAMISSING = @"JSONParser_ResponseDataMissing";
NSString *const	JSONPARSER_RESPONSENOENTRIES = @"JSONParser_ResponseNoEntries";



// authentication
NSString *const AUTHENTICATION_USERNAME=@"AUTHENTICATION_USERNAME";
NSString *const AUTHENTICATION_PASSWORD=@"AUTHENTICATION_PASSWORD";



NSString *const	XMLPARSER_YTFEEDMISSING = @"XMLParser_YouTubeFeedMissing";
NSString *const	XMLPARSER_XMLSYNTAXERROR = @"XMLParser_XMLSyntaxError: ";
NSString *const DATAREQUESTFAILED=@"DATAREQUESTFAILED";
NSString *const STARTUPERROR_SERVICELOADFAILEDSTRING=@"The Services plist could not be loaded.";
NSString *const STARTUPERROR_SETTINGSFAILED=@"The Application Settings could not loaded.";
NSString *const STARTUPERROR_STYLESFAILED=@"The Application Styles could not be loaded.";
NSString *const STARTUPERROR_DATASOURCE=@"The Data Source failed startup.";
NSString *const STARTUPERROR_STRINGSFAILED=@"The Application Strings could not be loaded.";





// sizes
int const SCREENWIDTH = 320;
int const IPADSCREENWIDTH = 1024;
int const IPADMASTERVIEWWIDTH = 255;
int const UIWIDTH = 280;
int const WIDEUIWIDTH = 300;
int const FORMWIDTH = 280;
int const SCREENHEIGHTWITHCONTROLANDHEADERUI = 280;
int const SCREENHEIGHTWITHCONTROLANDHEADERUI_IPAD_LANDSCAPE = 611;
int const SCREENHEIGHTMANAGE_IPAD_LANDSCAPE = 534;
int const NAVTABVIEWHEIGHT_IPAD_LANDSCAPE=655;
int const IPADDETAILVIEWWIDTH=768;
int const IPADDETAILUIVIEWWIDTH=728;
int const TABBARHEIGHT=50;
int const HEADERCONTROLHEIGHT=94;
// tables
int const STANDARDCELLHEIGHT=44;
int const HALFCELLHEIGHT=22;
int const SHORTCELLHEIGHT=36;
int const NEWSCELLHEIGHT=58;

int const TABBARMORELIMIT=4;



// Alert Error Strings
NSString *const CONNECTIONERROR=@"Connection Error";
NSString *const XMLPARSERERROR=@"Response Error";
NSString *const SERVERDOWNERROR=@"Server Error";
NSString *const JSONPARSERERROR=@"Server Response Error";

// Error Messages
NSString *const UNABLETOCONTACT=@"Unable to contact the server currently,\r you may need to check your Network Settings.";
NSString *const SERVERDOWN=@"The Server appears to be down,\r using cached data if available.";
NSString *const CONNECTIONCACHE=@"Unable to contact the server currently. Here is cached data to use in the meantime.\rPlease note: This data may be out of date.";
NSString *const INVALIDRESPONSE=@"No valid data received for this request. \r Please try again later.";


// default user state keys
NSString *const	kUSERSTATEKEY_NAVIGATION=@"navigation";
NSString *const	kUSERSTATEKEY_CONTEXT=@"context";
NSString *const	kUSERSTATEKEY_LASTOPENEDDATE=@"lastOpenedDate";



@implementation GenericConstants

+ (DataParserType)parserStringTypeToConstant:(NSString*)stringType {
    
	if([stringType isEqualToString:@"DATATYPE_XML"]){
		return DATATYPE_XML;
	}else if ([stringType isEqualToString:@"DATATYPE_PLIST"]){
		return DATATYPE_PLIST;
	}else if ([stringType isEqualToString:@"DATATYPE_JSON"]) {
		return DATATYPE_JSON;
	}
	
    return DATATYPE_NONE;
}


+ (NSString*)parserConstantToString:(DataParserType)parserType {
    
	if(parserType==DATATYPE_XML){
		return @"DATATYPE_XML";
	}else if (parserType==DATATYPE_PLIST){
		return @"DATATYPE_PLIST";
	}else if (parserType==DATATYPE_JSON) {
		return @"DATATYPE_JSON";
	}
	
    return @"DATATYPE_NONE";
}

@end
