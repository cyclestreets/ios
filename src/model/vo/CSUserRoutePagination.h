//
//  CSUserRoutePagination.h
//  CycleStreets
//
//  Created by Neil Edwards on 15/01/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUserRoutePagination : NSObject

-(instancetype)initWithDictionary:(NSDictionary*)dict;

@property(nonatomic,readonly)  NSInteger			currentCount;
@property(nonatomic,readonly)  NSInteger			total;
@property(nonatomic,readonly)  NSString				*bottomID;
@property(nonatomic,readonly)  NSString				*topID;
@property(nonatomic,readonly)  NSString				*earliestID;
@property(nonatomic,readonly)  BOOL					hasEarlier;

@end
