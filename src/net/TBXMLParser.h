//
//  TBXMLParser.h
//  RacingUK
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 Chroma. All rights reserved.
//	// Prelim implemnetation of new TB XML parser

#import <Foundation/Foundation.h>
#import "NetResponse.h"

@protocol TBXMLParserDelegate<NSObject>

-(void)XMLParserDidComplete:(NetResponse*)response;
-(void)XMLParserDidFail:(NetResponse*)response;

@end



@interface TBXMLParser : NSObject {
	NSMutableDictionary			*parsers;
	NetResponse					*activeResponse;
	NSDictionary				*parserMethods;
	//delegate
	id<TBXMLParserDelegate>		delegate;
	
	NSString					*parserError;
}
@property(nonatomic,retain)NSMutableDictionary *parsers;
@property(nonatomic,retain)NetResponse *activeResponse;
@property(nonatomic,retain)NSDictionary *parserMethods;
@property(nonatomic,assign)id<TBXMLParserDelegate> delegate;
@property(nonatomic,retain)NSString *parserError;



-(void)parseData:(NetResponse*)response;

@end
