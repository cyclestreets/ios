//
//  RequestQueueVO.m
//  RacingUK
//
//  Created by Neil Edwards on 09/11/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "RequestQueueVO.h"

@implementation RequestQueueVO
@synthesize request;
@synthesize index;
@synthesize status;


-(id)init{
	
	if (self = [super init]){
		index=-1;
		status=NO;
	}
	return self;
	
	
}


@end
