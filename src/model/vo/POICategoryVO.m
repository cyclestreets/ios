//
//  POITypeVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICategoryVO.h"

@implementation POICategoryVO


- (instancetype)init
{
	self = [super init];
	if (self) {
		
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [[[self class] allocWithZone:zone] init];  
    
	for (NSString *key in [self codableProperties]){
		
		id value = [self valueForKey:key];
		[theCopy setValue:[value copy] forKey:key];
		
	}
	
    return theCopy;
}


@end
