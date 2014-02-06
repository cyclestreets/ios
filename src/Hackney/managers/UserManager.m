//
//  UserManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "UserManager.h"

#import "User.h"

#import <CoreLocation/CoreLocation.h>

@interface UserManager()<CLLocationManagerDelegate>


@end

@implementation UserManager
SYNTHESIZE_SINGLETON_FOR_CLASS(UserManager);


- (id)init
{
    self = [super init];
    if (self) {
		[self fetchUser];
    }
    return self;
}


-(User*)fetchUser{
	
	NSArray *users=[User all];
	
	if(users.count==0){
		
		if(_user==nil){
			self.user=[User create];
		}
		
	}else{
		
		self.user=users[0];
		
	}
	
	return _user;
	
}

-(BOOL)hasUser{
	return _user!=nil;
}

-(BOOL)hasUserData{
	return _user.gender!=nil && _user.age!=nil;
}



@end
