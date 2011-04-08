//
//  LoginVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 08/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "LoginVO.h"


@implementation LoginVO
@synthesize requestname;
@synthesize username;
@synthesize userid;
@synthesize email;
@synthesize name;
@synthesize validatekey;
@synthesize validatedDate;
@synthesize lastsignin;
@synthesize userIP;
@synthesize deleted;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [requestname release], requestname = nil;
    [username release], username = nil;
    [email release], email = nil;
    [name release], name = nil;
    [validatedDate release], validatedDate = nil;
    [userIP release], userIP = nil;
	
    [super dealloc];
}


@end
