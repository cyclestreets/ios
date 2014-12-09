//
//  CSUserRouteVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BUCodableObject.h"

@interface CSUserRouteVO : BUCodableObject


@property (nonatomic,readonly)  NSString				*name;
@property (nonatomic,readonly)  NSString				*routeid;
@property (nonatomic,readonly)  NSArray					*plans;
@property (nonatomic,readonly)  NSString				*url;


// getters
@property (nonatomic,readonly)  NSDate					*date;
@property (nonatomic,readonly)  NSString				*dateString;



- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end
