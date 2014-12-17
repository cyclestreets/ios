//
//  CSUserRouteList.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUserRouteList : NSObject


@property (nonatomic,strong)  NSDictionary			*requestpaginationDict;

@property (nonatomic, strong)	NSMutableArray		*routes;

// getter

@property(nonatomic,readonly)  NSInteger			count;
@property(nonatomic,readonly)  BOOL					hasNextPage;
@property(nonatomic,readonly)  NSString				*bottomID;


@end
