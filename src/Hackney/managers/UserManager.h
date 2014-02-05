//
//  UserManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 27/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"

@class User;

@interface UserManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserManager);


@property (nonatomic,strong)  User        *user;

@property(nonatomic,readonly)  BOOL       hasUser;
@property(nonatomic,readonly)  BOOL       hasUserData;

-(User*)fetchUser;

@end
