//
//  CSUserRouteList.h
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSUserRoutePagination;

@interface CSUserRouteList : NSObject


@property (nonatomic,strong)  CSUserRoutePagination			*requestpagination;

@property (nonatomic, strong)	NSMutableArray				*routes;

// getter




@end
