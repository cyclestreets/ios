//
//  TBXMLParser.m
//  RacingUK
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 Chroma. All rights reserved.
//

#import "TBXMLParser.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "StringUtilities.h"
#import "TBXML.h"
#import "ValidationVO.h"
#import "NSDate+Helper.h"

@interface TBXMLParser(Private)

-(void)parseXMLForType:(NSString*)type;


@end

@implementation TBXMLParser
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
	validation.returnCode=[[TBXML textForElement:[TBXML childElementNamed:@"ReturnCode" parentElement:response]]intValue];
	validation.returnMessage=[TBXML textForElement:[TBXML childElementNamed:@"ReturnMsg" parentElement:response]];
	
	if([validation isReturnCodeValid]==ValdationValidSuccessCode ){
		NSString *token=[TBXML textForElement:[TBXML childElementNamed:@"Token" parentElement:response]];
		validation.responseDict=[NSDictionary dictionaryWithObject:token forKey:activeResponse.dataid];
	}
	
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
	validation.returnCode=[[TBXML textForElement:[TBXML childElementNamed:@"ReturnCode" parentElement:response]]intValue];
	validation.returnMessage=[TBXML textForElement:[TBXML childElementNamed:@"ReturnMsg" parentElement:response]];
	
	if([validation isReturnCodeValid]==ValdationValidSuccessCode ){
		NSString *token=[TBXML textForElement:[TBXML childElementNamed:@"Token" parentElement:response]];
		validation.responseDict=[NSDictionary dictionaryWithObject:token forKey:activeResponse.dataid];
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



@end
