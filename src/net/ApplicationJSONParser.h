//
//  ApplicationJSONParser
//  Buffer
//
//  Created by Neil Edwards on 18/02/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "AppConstants.h"

@class BUNetworkOperation;

@interface ApplicationJSONParser : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ApplicationJSONParser);



-(void)parseDataForOperation:(BUNetworkOperation* )networkOperation success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure;

@end
