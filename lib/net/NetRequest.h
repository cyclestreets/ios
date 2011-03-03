//
//  Request.h
//  RacingUK
//
//  Created by Neil Edwards on 10/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>

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
	NSMutableDictionary			*parameters; // params to send
	NSString				*requestType; // same as dataid??
	NSString				*requestid; // request id. for cacheing
	int						revisonId; // revision id for update checking
	NSString				*source; // controls refresh logic // can be user or system
	
}
@property(nonatomic,retain)NSDictionary *service;
@property(nonatomic,retain)NSString *dataid;
@property(nonatomic,retain)NSMutableString *url;
@property(nonatomic,assign)requestStatus status;
@property(nonatomic,retain)NSMutableDictionary *parameters;
@property(nonatomic,retain)NSString *requestType;
@property(nonatomic,retain)NSString *requestid;
@property(nonatomic,assign)int revisonId;
@property(nonatomic,retain)NSString *source;




-(NSMutableURLRequest*)requestForType;
-(NSMutableString*)url;
@end
