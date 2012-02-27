//
//  TBXMLParser.h
//  CycleStreets
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//	// Prelim implemnetation of new TB XML parser

#import <Foundation/Foundation.h>
#import "NetResponse.h"

@protocol ApplicationXMLParserDelegate<NSObject>

-(void)XMLParserDidComplete:(NetResponse*)response;
-(void)XMLParserDidFail:(NetResponse*)response;

@end



@interface ApplicationXMLParser : NSObject {
	NSMutableDictionary			*parsers;
	NetResponse					*activeResponse;
	NSDictionary				*parserMethods;
	//delegate
	id<ApplicationXMLParserDelegate>		delegate;
	
	NSString					*parserError;
}
@property(nonatomic,retain)NSMutableDictionary *parsers;
@property(nonatomic,retain)NetResponse *activeResponse;
@property(nonatomic,retain)NSDictionary *parserMethods;
@property(nonatomic,assign)id<ApplicationXMLParserDelegate> delegate;
@property(nonatomic,retain)NSString *parserError;



-(void)parseData:(NetResponse*)response;

-(NSDictionary*)parseXML:(NSData*)data forType:(NSString*)datatype;

@end
