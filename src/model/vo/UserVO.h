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
@property (nonatomic, strong)			NSString *username;
@property (nonatomic, strong)			NSString *password;
@property (nonatomic, strong)			NSString *email;
@property (nonatomic, strong)			NSString *visiblename;
@property (nonatomic)			BOOL autoLogin;

@end
