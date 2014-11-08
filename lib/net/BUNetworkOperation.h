//
//  BUNetworkOperation.h
//  CycleStreets
//
//  Created by Neil Edwards on 03/03/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BUCodableObject.h"
#import "AppConstants.h"
#import "GenericConstants.h"
#import "BUResponseObject.h"

@class BUNetworkOperation;

typedef void (^BUNetworkOperationCompletionBlock)(BUNetworkOperation *operation, BOOL complete,NSString *error);

typedef void (^BUNetworkOperationProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);


typedef NS_ENUM(int, BUNetworkOperationState)
{
	NetResponseStateInitialised,
    NetResponseStateComplete,
    NetResponseStateFailed,
    NetResponseStateFailedWithError,
    NetResponseStateError
    
};


typedef NS_ENUM(int, BUNetworkOperationError)
{
    NetResponseErrorGeneric,
    NetResponseErrorAuthorisation,
    NetResponseErrorNoResults,
    NetResponseErrorInvalidResponse,
    NetResponseErrorParserFailed,
    NetResponseErrorParserUnknown,
    NetResponseErrorConnection,
    NetResponseErrorNotConnected
};

@interface BUNetworkOperation : BUCodableObject

// request portion
@property (nonatomic, strong) NSMutableDictionary             * parameters;
@property (nonatomic, strong) NSDictionary                    * service;
@property (nonatomic, strong) NSString                        * dataid;
@property (nonatomic, strong) NSString                        * requestType;
@property (nonatomic, strong) NSString                        * requestid;
@property (nonatomic, assign) DataSourceRequestCacheType      source;
@property (nonatomic, assign) DataParserType                  dataType;

// response portion
@property (nonatomic,copy)  BUNetworkOperationCompletionBlock	completionBlock;
@property (nonatomic,copy)  BUNetworkOperationProgressBlock		progressBlock;


@property (nonatomic, strong)	NSMutableData                   * responseData;

@property (nonatomic,assign) BUResponseStatusCode				responseStatus;

// state
@property(nonatomic,assign)  BUNetworkOperationError          operationError;
@property(nonatomic,assign)  BUNetworkOperationState          operationState;
@property(nonatomic,strong)  NSString                         * errorDescription;

// response details
@property(nonatomic,strong)  NSString                         * validationMessage;


@property (nonatomic, assign) BOOL                            trackProgress;


@property (nonatomic,readonly) NSString							* url;
@property (nonatomic,readonly) int								serviceCacheInterval;
@property (nonatomic,readonly) BOOL								serviceShouldBeCached;
@property (nonatomic,readonly) id								responseObject;
@property (nonatomic,readonly) BUResponseObject					*response;



-(void)setResponseWithValue:(id)value;


-(NSMutableURLRequest*)requestForType;

-(NSString*)requestParameterForType:(NSString*)type;


@end
