//
//  Request.h
//  CycleStreets
//
//  Created by Neil Edwards on 10/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

typedef enum{
	
	QUEUED,
	INPROGRESS,
	STALLED,
	FAILED
	
}requestStatus;

@interface NetRequest : NSObject {
	NSDictionary			*service; // service dict
	NSString				*dataid; // data id
	NSMutableString			*url;
	requestStatus			status;
	NSDictionary			*parameters; // params to send
	NSString				*requestType; // same as dataid??
	NSString				*requestid; // request id. for cacheing
	int						revisonId; // revision id for update checking
	NSString				*source; // controls refresh logic // can be user or system
	DataParserType			dataType; // data parser type of service
	
}
@property (nonatomic, retain)		NSDictionary		* service;
@property (nonatomic, retain)		NSString		* dataid;
@property (nonatomic, retain)		NSMutableString		* url;
@property (nonatomic)		requestStatus		 status;
@property (nonatomic, retain)		NSDictionary		* parameters;
@property (nonatomic, retain)		NSString		* requestType;
@property (nonatomic, retain)		NSString		* requestid;
@property (nonatomic)		int		 revisonId;
@property (nonatomic, retain)		NSString		* source;
@property (nonatomic)		DataParserType		 dataType;


-(NSMutableURLRequest*)requestForType;
-(NSMutableURLRequest*)addRequestHeadersForService:(NSMutableURLRequest*)request;
-(NSMutableString*)url;
@end
