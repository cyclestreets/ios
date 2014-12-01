//
//  TBXMLParser.h
//  CycleStreets
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//	// Prelim implemnetation of new TB XML parser

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "SynthesizeSingleton.h"

@class BUNetworkOperation;


@interface ApplicationXMLParser : NSObject {
	
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ApplicationXMLParser);


-(void)parseDataForOperation:(BUNetworkOperation* )networkOperation success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure;


-(id)parseXML:(NSData*)data forType:(NSString*)datatype;

@end
