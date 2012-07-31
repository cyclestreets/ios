//
//  NetResponse.m
//  Buffer
//
//  Created by Neil Edwards on 14/01/2010.
//  Copyright 2010 Buffer. All rights reserved.
//

#import "NetResponse.h"


@implementation NetResponse
@synthesize dataid;
@synthesize requestid;
@synthesize requestType;
@synthesize dataProvider;
@synthesize updated;
@synthesize responseData;
@synthesize revisionId;
@synthesize error;
@synthesize status;
@synthesize dataType;

//=========================================================== 
// dealloc
//=========================================================== 



-(id)init{
	
	if (self = [super init]){
		status=YES;
		updated=YES;
	}
	return self;
}



@end
