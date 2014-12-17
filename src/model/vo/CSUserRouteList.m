//
//  CSUserRouteList.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/12/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSUserRouteList.h"

@implementation CSUserRouteList





// getters
-(NSInteger)count{
	return _routes.count;
}

-(BOOL)hasNextPage{
	return _requestpaginationDict[@"nextUrl"]!=nil;
}

-(NSString*)bottomID{
	if([self hasNextPage]){
		return _requestpaginationDict[@"bottom"];
	}
	return nil;
}


@end
