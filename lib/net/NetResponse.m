//
//  NetResponse.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import "NetResponse.h"


@implementation NetResponse
@synthesize dataid;
@synthesize requestid;
@synthesize dataProvider;
@synthesize updated;
@synthesize responseData;
@synthesize revisionId;
@synthesize error;
@synthesize status;
@synthesize dataType;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [dataid release], dataid = nil;
    [requestid release], requestid = nil;
    [dataProvider release], dataProvider = nil;
    [responseData release], responseData = nil;
    [revisionId release], revisionId = nil;
    [error release], error = nil;
	
    [super dealloc];
}




-(id)init{
	
	if (self = [super init]){
		status=YES;
		updated=YES;
	}
	return self;
}



@end
