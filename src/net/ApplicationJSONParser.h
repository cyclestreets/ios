//
//  ApplicationJSONParser
//  Buffer
//
//  Created by Neil Edwards on 18/02/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetResponse.h"
#import "SynthesizeSingleton.h"


@interface ApplicationJSONParser : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ApplicationJSONParser);

@property (nonatomic,copy) ParserCompletionBlock            successBlock;
@property (nonatomic,copy) ParserErrorBlock                 failureBlock;


-(void)parseDataForResponseData:(NSMutableData* )responseData forRequestType:(NSString*)requestType success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure;


@end
