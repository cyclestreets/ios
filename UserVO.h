//
//  UserVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserVO : NSObject {
	NSString			*username;
	NSString			*password;
	NSString			*email;
	NSString			*visiblename;
	BOOL				autoLogin;
}
@property (nonatomic, retain)			NSString *username;
@property (nonatomic, retain)			NSString *password;
@property (nonatomic, retain)			NSString *email;
@property (nonatomic, retain)			NSString *visiblename;
@property (nonatomic)			BOOL autoLogin;

@end
