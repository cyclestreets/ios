//
//  BUNetworkOperation.h
//  CycleStreets
//
//  Created by Neil Edwards on 03/03/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenericConstants.h"
#import <AFHTTPRequestOperation.h>

typedef NS_ENUM(int, BUNetworkOperationState)
{

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

@interface BUNetworkOperation : NSObject


@property (nonatomic,strong)  AFHTTPRequestOperation     * networkOperation;

@property (nonatomic, strong) NSDictionary               * service;

@property (nonatomic, strong)	id                         dataProvider;

@property (nonatomic, strong) NSMutableDictionary        * parameters;

@property (nonatomic, strong) NSString                   * dataid;
@property (nonatomic, strong) NSMutableString            * url;


@property (nonatomic, strong) NSString                   * requestType;
@property (nonatomic, strong) NSString                   * requestid;

@property (nonatomic, assign) DataSourceRequestCacheType source;
@property (nonatomic, assign) DataParserType             dataType;

@property (nonatomic, assign) BOOL                       trackProgress;



@property (nonatomic,readonly) int								serviceCacheInterval;
@property (nonatomic,readonly) BOOL								serviceShouldBeCached;


-(NSMutableURLRequest*)requestForType;


@end
