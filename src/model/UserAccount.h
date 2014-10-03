//
//  UserAccount.h
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "FrameworkObject.h"
#import "UserVO.h"

#define NMUSERSTATEFILE @"NMUserState.user"
#define kUSERSTATEARCHIVEKEY @"UserStateArchiveKey"


enum  {
	kUserAccountLoggedIn=0,
	kUserAccountNotLoggedIn=1,
	kUserAccountPassword=2,
	kUserAccountCredentialsExist=3, // we have username/password but user has not got autologin enabled
	kUserAccountNone=4
};
typedef int UserAccountMode;

@interface UserAccount : FrameworkObject {
	
}
@property (nonatomic, retain)	UserVO		*user;
@property (nonatomic, assign)	UserAccountMode	accountMode;
@property (nonatomic, retain)	NSString	*userPassword;

@property (nonatomic,readonly)  BOOL			isLoggedIn;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserAccount)

-(void)loginUserWithUserName:(NSString*)name andPassword:(NSString*)password;
-(void)registerUserWithUserName:(NSString*)name andPassword:(NSString*)password visibleName:(NSString*)visiblename email:(NSString*)email;
-(void)logoutUser;

-(void)loginExistingUser;
-(void)loginExistingUserSilent;
-(void)retrievePasswordForUser:(NSString*)email;
-(BOOL)hasSessionToken;
-(void)resetUserAccount;
-(void)updateAutoLoginPreference:(BOOL)value;
@end
