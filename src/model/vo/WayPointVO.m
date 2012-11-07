//
//  WayPointVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 05/11/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "WayPointVO.h"

@implementation WayPointVO




-(NSString*)coordinateString{
	
	return [NSString stringWithFormat:@"%f, %f",_coordinate.latitude,_coordinate.longitude];
	
}

@end
