//
//  TBXMLParser.h
//  CycleStreets
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//	// Prelim implemnetation of new TB XML parser

#import <Foundation/Foundation.h>
#import "NetResponse.h"
#import "TBXML.h"

@protocol ApplicationXMLParserDelegate<NSObject>

-(void)XMLParserDidComplete:(NetResponse*)response;
-(void)XMLParserDidFail:(NetResponse*)response;

@end



@interface ApplicationXMLParser : NSObject {
	NSMutableDictionary			*parsers;
	NetResponse					*activeResponse;
	NSDictionary				*parserMethods;
	//delegate
	id<ApplicationXMLParserDelegate>		__unsafe_unretained delegate;
	
	NSString					*parserError;
}
@property(nonatomic,strong)NSMutableDictionary *parsers;
@property(nonatomic,strong)NetResponse *activeResponse;
@property(nonatomic,strong)NSDictionary *parserMethods;
@property(nonatomic,unsafe_unretained)id<ApplicationXMLParserDelegate> delegate;
@property(nonatomic,strong)NSString *parserError;



-(void)parseData:(NetResponse*)response;

-(NSDictionary*)parseXML:(NSData*)data forType:(NSString*)datatype;

@end
