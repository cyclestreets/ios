//
//  AppConstants.m
//  RacingUK
//
//  Created by Neil Edwards on 16/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "AppConstants.h"

NSString *const DEVICETYPE=@"iPhone";

//
/***********************************************
 * @description			DATA REQUEST IDS
 ***********************************************/
//

// racecards

//user
NSString *const LOGIN=@"Login";
NSString *const REGISTER=@"Register"; 
NSString *const PASSWORDRETRIEVAL=@"ForgottenPassword";
//search
NSString *const QUICKSEARCHDATAID=@"QuickSearch";
NSString *const SEARCHDATAID=@"Search";

NSString *const CSROUTESELECTED=@"CSRouteSelected";

NSString *const LOGINRESPONSE=@"LOGINRESPONSE";
NSString *const REGISTERRESPONSE=@"REGISTERRESPONSE";
NSString *const PASSWORDRETRIEVALRESPONSE=@"PASSWORDRETRIEVALRESPONSE";
NSString *const LOCATIONSEARCH=@"LOCATIONSEARCH";




//request types
NSString *const POST=@"POST";
NSString *const GET=@"GET";
NSString *const URL=@"URL";
NSString *const GETPOST=@"GETPOST";
NSString *const POSTJSON=@"POSTJSON";

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
NSString *const CLOSE=@"Close";
NSString *const ERROR=@"error";
NSString *const ZERO=@"0";
NSString *const SUCCESS=@"Success";
NSString *const MESSAGE=@"Message";
NSString *const MILES=@"miles";
NSString *const KM=@"kilometers";


// viewmodes
NSString *const UITYPE_NAV=@"UITypeNavonly";
NSString *const UITYPE_CONTROLUI=@"UITypeControlNav";
NSString *const UITYPE_CONTROLHEADERUI=@"UITypeControlHeaderNav";
NSString *const UITYPE_MODALUI=@"UITypeModalNav";



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
NSString *const TEXTFIELDEDITFRAME=@"tuitextfieldeditframeupdate"; // generic event for sending the textfield frame so we can adjust the scrollview for the 




//errors
NSString *const	XMLPARSERDIDFAILPARSING = @"XMLParserDidFailParsing";
NSString *const	XMLPARSER_RESPONSENODEMISSING = @"XMLParser_ResponseNodeMissing";
NSString *const	XMLPARSER_RESPONSEDATAMISSING = @"XMLParser_ResponseDataMissing";
NSString *const	XMLPARSER_RESPONSENOENTRIES = @"XMLParser_ResponseNoEntries";
NSString *const	REMOTEFILEFAILED = @"RemoteFileMangerFailed";
NSString *const	XMLPARSER_YTFEEDMISSING = @"XMLParser_YouTubeFeedMissing";
NSString *const	XMLPARSER_XMLSYNTAXERROR = @"XMLParser_XMLSyntaxError: ";
NSString *const DATAREQUESTFAILED=@"DATAREQUESTFAILED";
NSString *const STARTUPERROR_SERVICELOADFAILED=@"The Services plist could not be loaded.";
NSString *const STARTUPERROR_SETTINGSFAILED=@"The Application Settings could not loaded.";
NSString *const STARTUPERROR_STYLESFAILED=@"The Application Styles could not be loaded.";
NSString *const STARTUPERROR_DATASOURCE=@"The Data Source failed startup.";
NSString *const STARTUPERROR_STRINGSFAILED=@"The Application Strings could not be loaded.";



// sizes
int const SCREENWIDTH = 320;
int const UIWIDTH = 280;
int const FORMWIDTH = 280;
int const SCREENHEIGHT = 460;
int const SCREENHEIGHTWITHCONTROLUI = 323;
int const SCREENHEIGHTWITHCONTROLANDHEADERUI = 273;
int const SCREENHEIGHTWITHNAVIGATION = 420;
int const SCREENHEIGHTWITHNAVANDTAB=366;
int const CONTROLUIHEIGHT = 44;
int const NAVIGATIONHEIGHT = 44;
int const TABBARHEIGHT=50;
int const NAVTABVIEWHEIGHT=387;
int const NAVCONTROLMODALHEIGHT=373;
int const HEADERCONTROLHEIGHT=94;
// tables
int const STANDARDCELLHEIGHT=44;
int const HALFCELLHEIGHT=22;
int const SHORTCELLHEIGHT=36;
int const NEWSCELLHEIGHT=58;
int const NAVTABLEHEIGHT=366;

int const TABBARMORELIMIT=4;

// Alert Error Strings
NSString *const CONNECTIONERROR=@"Connection Error";
NSString *const XMLPARSERERROR=@"Response Error";

// Error Messages
NSString *const UNABLETOCONTACT=@"Unable to contact the server currently,\r you may need to check your Network Settings.";
NSString *const CONNECTIONCACHE=@"Unable to contact the server currently. Here is cached data to use in the meantime.\rPlease note: This data may be out of date.";
NSString *const INVALIDRESPONSE=@"No valid data received for this request. \r Please try again later.";


@implementation AppConstants


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
