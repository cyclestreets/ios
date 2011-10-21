//
//  TBXMLParser.m
//  RacingUK
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import "ApplicationXMLParser.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "StringUtilities.h"
#import "TBXML.h"
#import "ValidationVO.h"
#import "NSDate+Helper.h"
#import "LoginVO.h"
#import "POICategoryVO.h"
#import "POILocationVO.h"
#import "NSString+HTML.h"

@interface ApplicationXMLParser(Private)

-(void)parseXMLForType:(NSString*)type;


// user account
-(void)LoginXMLParser:(TBXML*)parser;
-(void)RegisterXMLParser:(TBXML*)parser;
-(void)RetrievePasswordXMLParser:(TBXML*)parser;


// routes


// photos
-(void)PhotoUploadXMLParser:(TBXML*)parser;
-(void)RetrievePhotosXMLParser:(TBXML*)parser;


// pois
-(void)POIListingXMLParser:(TBXML*)parser;
-(void)POICategoryXMLParser:(TBXML*)parser;



//


@end

@implementation ApplicationXMLParser
@synthesize parsers;
@synthesize activeResponse;
@synthesize parserMethods;
@synthesize delegate;
@synthesize parserError;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [parsers release], parsers = nil;
    [activeResponse release], activeResponse = nil;
    [parserMethods release], parserMethods = nil;
    delegate = nil;
    [parserError release], parserError = nil;
	
    [super dealloc];
}




-(id)init{
	if (self = [super init])
	{
		parserMethods=[[NSDictionary alloc] initWithObjectsAndKeys:
					   [NSValue valueWithPointer:@selector(LoginXMLParser:)],LOGIN,
					   [NSValue valueWithPointer:@selector(RegisterXMLParser:)],REGISTER,
					   [NSValue valueWithPointer:@selector(RetrievePasswordXMLParser:)],PASSWORDRETRIEVAL,
                       [NSValue valueWithPointer:@selector(RetrievePhotosXMLParser:)],RETREIVELOCATIONPHOTOS,
                       [NSValue valueWithPointer:@selector(PhotoUploadXMLParser:)],UPLOADUSERPHOTO,
					   [NSValue valueWithPointer:@selector(POIListingXMLParser:)],POILISTING,
					   [NSValue valueWithPointer:@selector(POICategoryXMLParser:)],POICATEGORYLOCATION,
					   nil];
		
		parsers=[[NSMutableDictionary alloc]init];
	}
	return self;
}


-(void)parseData:(NetResponse*)response{
	
	BetterLog(@"type=%@",response.dataid);
	
	activeResponse=response;
	
	// NOTE: no more storage of XMLdata in archives as TBXMLElements are structs not Objects
	TBXML	*parser=[[TBXML alloc]initWithXMLData:activeResponse.responseData];
	[parsers setObject:parser forKey:activeResponse.dataid];
	
	[self parseXMLForType:activeResponse.dataid];
	
	[parser release];
}



-(void)XMLParserDidFail:(NSError*)error{
	
	BetterLog(@"");
	
	activeResponse.status=NO;
	activeResponse.error=[NSString stringWithFormat:@"%@%@",XMLPARSER_XMLSYNTAXERROR,[error localizedDescription]];
	
	if([delegate respondsToSelector:@selector(XMLParserDidFail:)]){
		[delegate XMLParserDidFail:activeResponse];
	}
	
}



#pragma mark Section XML Parsering methods



-(void)parseXMLForType:(NSString*)type{
	
	BetterLog(@"");
	
	SEL parserMethod=[[parserMethods objectForKey:type] pointerValue];
	
	if(parserMethod!=nil){
		
		
		TBXML	*parser=[[TBXML alloc]initWithXMLData:activeResponse.responseData];
		[self performSelector:parserMethod withObject:parser];
		[parser release];
		
		if(activeResponse.status==YES){
			
			BetterLog(@"[DEBUG] activeResponse.dataid=%@",activeResponse.dataid);
			BetterLog(@"[DEBUG] activeResponse.requestid=%i",activeResponse.requestid);
			
			if([delegate respondsToSelector:@selector(XMLParserDidComplete:)]){
				[delegate XMLParserDidComplete:activeResponse];
			}
			
		}else {
			
			BetterLog(@"[ERROR] RKXMLParser:XMLParserDidFail");
			
			if([delegate respondsToSelector:@selector(XMLParserDidFail:)]){
				[delegate XMLParserDidFail:activeResponse];
			}
			
		}
		
		
	}else {
		
		BetterLog(@"[ERROR] RKXMLParser:parseXMLForType: parser for type %@ not found!",type);
		
	}
	
	
}



-(BOOL)validateXML:(TBXMLElement*)root{
	
	BetterLog(@"");
	
	BOOL result=YES;
	
	if(root==nil){
			activeResponse.error=XMLPARSER_RESPONSENODEMISSING;
			activeResponse.status=NO;
			return NO;
		}
		
		BOOL hasChildren=[TBXML hasChildrenForParentElement:root];
		
		// capture responses with no response data
		// this is a valid fault
		if(hasChildren==NO){
			activeResponse.error=XMLPARSER_RESPONSEDATAMISSING;
			activeResponse.status=NO;
			return NO;
		}
		
		// capture valid requests with with 0 response entries
		// this is not inherently a fault but is treated as such
		// to trigger the no results logic
		if ([TBXML childElementNamed:@"NoResults" parentElement:root]!=nil) {
			activeResponse.error=XMLPARSER_RESPONSENOENTRIES;
			activeResponse.status=NO;
			return NO;
		}
		
		
		// check for revision status, will be boolean node if sent revision is same as current server one
		// wil return NO but status is kept to YES as its not an error but will trigger the  XMLPARSERDIDCOMPLETENOUPDATE notification
		//XMLTreeNode *revisionstatus=[response findChild:@"Status"];
		//		if(revisionstatus!=nil){
		//			activeResponse.updated=NO;
		//			return NO;
		//		}
		
	
	
	return result;
	
}





//
/***********************************************
 * @description			USER ACCOUNT METHODS
 ***********************************************/
//

-(void)LoginXMLParser:(TBXML*)parser{
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(activeResponse.status==NO){
		return;
	}
	
	ValidationVO *validation=[[ValidationVO alloc]init];
	
	LoginVO		*loginResponse=[[LoginVO alloc]init];
	loginResponse.requestname=[TBXML textForElement:[TBXML childElementNamed:@"request" parentElement:response]];
	
	TBXMLElement *resultelement=[TBXML childElementNamed:@"result" parentElement:response];
	
	if([TBXML hasChildrenForParentElement:resultelement]==YES){
		
		validation.returnCode=ValidationLoginSuccess;
		
		loginResponse.username=[TBXML textForElement:[TBXML childElementNamed:@"username" parentElement:resultelement]];
		loginResponse.userid=[[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:resultelement]] intValue];
		loginResponse.email=[TBXML textForElement:[TBXML childElementNamed:@"email" parentElement:resultelement]];
		loginResponse.name=[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:resultelement]];
		loginResponse.validatedDate=[TBXML textForElement:[TBXML childElementNamed:@"validated" parentElement:resultelement]];
		loginResponse.userIP=[TBXML textForElement:[TBXML childElementNamed:@"ip" parentElement:resultelement]];
		
		loginResponse.validatekey=[[TBXML textForElement:[TBXML childElementNamed:@"validatekey" parentElement:resultelement]] boolValue];
		loginResponse.deleted=[[TBXML textForElement:[TBXML childElementNamed:@"deleted" parentElement:resultelement]] boolValue];
		loginResponse.lastsignin=[[TBXML textForElement:[TBXML childElementNamed:@"lastsignin" parentElement:resultelement]] intValue];
		
	}else {
		
		validation.returnCode=ValidationLoginFailed;
		
	}

	validation.responseDict=[NSDictionary dictionaryWithObject:loginResponse forKey:activeResponse.dataid];
	[loginResponse release];
	
	activeResponse.dataProvider=validation;
	[validation release];
	
}



-(void)RegisterXMLParser:(TBXML*)parser{
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(activeResponse.status==NO){
		return;
	}
	
	
	ValidationVO *validation=[[ValidationVO alloc]init];
	
	TBXMLElement *resultelement=[TBXML childElementNamed:@"result" parentElement:response];
	
	if([TBXML hasChildrenForParentElement:resultelement]==YES){
		
		int code=[[TBXML textForElement:[TBXML childElementNamed:@"code" parentElement:resultelement]]intValue];
		if(code==1){
			validation.returnCode=ValidationRegisterSuccess;
		}else {
			validation.returnCode=ValidationRegisterFailed;
		}

		validation.returnMessage=[TBXML textForElement:[TBXML childElementNamed:@"message" parentElement:resultelement]];
		
	}else {
		
		validation.returnCode=ValidationRegisterFailed;
		
	}

	
	activeResponse.dataProvider=validation;
	[validation release];
	
}

-(void)RetrievePasswordXMLParser:(TBXML*)parser{
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(activeResponse.status==NO){
		return;
	}
	
	
	ValidationVO *validation=[[ValidationVO alloc]init];
	validation.returnCode=[[TBXML textForElement:[TBXML childElementNamed:@"ReturnCode" parentElement:response]]intValue];
	validation.returnMessage=[TBXML textForElement:[TBXML childElementNamed:@"ReturnMsg" parentElement:response]];
	activeResponse.dataProvider=validation;
	[validation release];
	
	
}


#pragma mark Photos

// photos
-(void)PhotoUploadXMLParser:(TBXML*)parser{
    
    TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(activeResponse.status==NO){
		return;
	}
    
    //ValidationVO *validation=[[ValidationVO alloc]init];
    
    // will be <gml:featureMember>
    //then <cs:photo>
    
    /* use this vo
    for (NSDictionary *photoDictionary in [elements objectForKey:PHOTO_ELEMENT]) {
        PhotoEntry *photo = [[PhotoEntry alloc] initWithDictionary:photoDictionary];
        [photos addObject:photo];
        [photo release];
    }
     */
    
}





-(void)RetrievePhotosXMLParser:(TBXML*)parser{
    
    
    
    
    
    
    
    
}


#pragma mark POIs

// pois
-(void)POIListingXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(activeResponse.status==NO){
		return;
	}
    
    ValidationVO *validation=[[ValidationVO alloc]init];
	
	
	TBXMLElement *poitypes=[TBXML childElementNamed:@"poitypes" parentElement:response];
	TBXMLElement *poitype=[TBXML childElementNamed:@"poitype" parentElement:poitypes];

	if(poitype!=nil){
		
		NSMutableArray *dataProvider=[[NSMutableArray alloc]init];
		
		while (poitype!=nil) {
			
			POICategoryVO *poicategory=[[POICategoryVO alloc]init];
			poicategory.name= [[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:poitype]] stringByDecodingHTMLEntities];
			poicategory.key=[TBXML textForElement:[TBXML childElementNamed:@"key" parentElement:poitype]];
			poicategory.shortname=[TBXML textForElement:[TBXML childElementNamed:@"shortname" parentElement:poitype]];
			poicategory.total=[[TBXML textForElement:[TBXML childElementNamed:@"total" parentElement:poitype]] intValue];
			poicategory.icon=[StringUtilities imageFromString:[TBXML textForElement:[TBXML childElementNamed:@"icon" parentElement:poitype]]];
			
			[dataProvider addObject:poicategory];
			[poicategory release];
			
			poitype=poitype->nextSibling;
			
		}
		
		validation.responseDict=[NSDictionary dictionaryWithObject:dataProvider forKey:activeResponse.dataid];
		[dataProvider release];
		
		validation.returnCode=ValidationPOIListingSuccess;
		
	}else{
		validation.returnCode=ValidationPOIListingFailure;
	}
	
	activeResponse.dataProvider=validation;
	[validation release];
	
}



-(void)POICategoryXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(activeResponse.status==NO){
		return;
	}
    
	ValidationVO *validation=[[ValidationVO alloc]init];
	
	
	TBXMLElement *pois=[TBXML childElementNamed:@"pois" parentElement:response];
	TBXMLElement *poi=[TBXML childElementNamed:@"poi" parentElement:pois];
	
	if(poi!=nil){
		
		NSMutableArray *dataProvider=[[NSMutableArray alloc]init];
		
		while (poi!=nil) {
			
			POILocationVO *poilocation=[[POILocationVO alloc]init];
			poilocation.name= [[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:poi]] stringByDecodingHTMLEntities];
			
			CLLocationCoordinate2D coords;
			coords.longitude=[[TBXML textForElement:[TBXML childElementNamed:@"longitude" parentElement:poi]] floatValue];
			coords.latitude=[[TBXML textForElement:[TBXML childElementNamed:@"latitude" parentElement:poi]] floatValue];
			CLLocation *location=[[CLLocation alloc]initWithLatitude:coords.latitude longitude:coords.longitude];
			poilocation.location=location;
			[location release];
			
			poilocation.website=[TBXML textForElement:[TBXML childElementNamed:@"website" parentElement:poi]];
			poilocation.notes=[TBXML textForElement:[TBXML childElementNamed:@"notes" parentElement:poi]];
						
			[dataProvider addObject:poilocation];
			[poilocation release];
			
			poi=poi->nextSibling;
			
		}
		
		validation.responseDict=[NSDictionary dictionaryWithObject:dataProvider forKey:activeResponse.dataid];
		[dataProvider release];
		
		validation.returnCode=ValidationPOICategorySuccess;
		
	}else{
		validation.returnCode=ValidationPOICategoryFailure;
	}
	
	activeResponse.dataProvider=validation;
	[validation release];
	
	
	
}






@end
