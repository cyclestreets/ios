//
//  UserVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//

#import "UserVO.h"


@implementation UserVO
@synthesize username;
@synthesize password;
@synthesize email;
@synthesize visiblename;
@synthesize autoLogin;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [username release], username = nil;
    [password release], password = nil;
    [email release], email = nil;
    [visiblename release], visiblename = nil;
	
    [super dealloc];
}

static NSString *kcustom_USERNAME = @"username";
static NSString *kcustom_PASSWORD = @"password";
static NSString *kcustom_EMAIL = @"email";
static NSString *kcustom_VISIBLENAME = @"visiblename";
static NSString *kcustom_AUTO_LOGIN = @"autoLogin";



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:[self username] forKey:kcustom_USERNAME];
    [encoder encodeObject:[self password] forKey:kcustom_PASSWORD];
    [encoder encodeObject:[self email] forKey:kcustom_EMAIL];
    [encoder encodeObject:[self visiblename] forKey:kcustom_VISIBLENAME];
    [encoder encodeBool:[self autoLogin] forKey:kcustom_AUTO_LOGIN];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        [self setUsername:[decoder decodeObjectForKey:kcustom_USERNAME]];
        [self setPassword:[decoder decodeObjectForKey:kcustom_PASSWORD]];
        [self setEmail:[decoder decodeObjectForKey:kcustom_EMAIL]];
        [self setVisiblename:[decoder decodeObjectForKey:kcustom_VISIBLENAME]];
        [self setAutoLogin:[decoder decodeBoolForKey:kcustom_AUTO_LOGIN]];
    }
    return self;
}

@end
