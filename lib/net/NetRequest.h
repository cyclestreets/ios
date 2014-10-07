//
//  Request.h
//  CycleStreets
//
//  Created by Neil Edwards on 10/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "GenericConstants.h"

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
	NSMutableDictionary		*parameters; // params to send
	NSString				*requestType; // same as dataid??
	NSString				*requestid; // request id. for cacheing
	int						revisonId; // revision id for update checking
	NSString				*source; // controls refresh logic // can be user or system
	DataParserType			dataType; // data parser type of service
	
	BOOL					trackProgress;
	
}
@property (nonatomic, strong) NSDictionary		* service;
@property (nonatomic, strong) NSString		* dataid;
@property (nonatomic, strong) NSMutableString		* url;
@property (nonatomic, assign) requestStatus		 status;
@property (nonatomic, strong) NSMutableDictionary		* parameters;
@property (nonatomic, strong) NSString		* requestType;
@property (nonatomic, strong) NSString		* requestid;
@property (nonatomic, assign) int		 revisonId;
@property (nonatomic, strong) NSString		* source;
@property (nonatomic, assign) DataParserType		 dataType;
@property (nonatomic, assign) BOOL		 trackProgress;


-(NSMutableURLRequest*)requestForType;
-(NSMutableURLRequest*)addRequestHeadersForService:(NSMutableURLRequest*)request;
-(NSMutableString*)url;

- (void)appendFormValues:(NSDictionary*)parameters toPostData:(NSMutableData*)data;

@end
