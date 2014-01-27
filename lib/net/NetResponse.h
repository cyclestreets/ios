//
//  NetResponse.h
//  Buffer
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericConstants.h"

typedef enum: int{
    
    NetResponseStateComplete,
    NetResponseStateFailed,
    NetResponseStateFailedWithError
    
}NetResponseState;


typedef NS_ENUM(int, NetResponseError)
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



@interface NetResponse : NSObject


@property (nonatomic, strong)	NSString                            *dataid;
@property (nonatomic, strong)	NSString                            *requestid;
@property (nonatomic, strong)	NSString                            *requestType;
@property (nonatomic, strong)	id                                  dataProvider;
@property (nonatomic)	BOOL                                        updated;
@property (nonatomic, strong)	NSMutableData                       *responseData;
@property (nonatomic, strong)	NSString                            *revisionId;
@property (nonatomic, strong)	NSString                            *error;
@property (nonatomic)	BOOL                                        status;
@property (nonatomic)	NetResponseState                            responseState;
@property (nonatomic)	NetResponseError                            errorType;
@property (nonatomic)	DataParserType                              dataType;


+ (NSString*)errorTypeToString:(NetResponseError)errorType;

@end
