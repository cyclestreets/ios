//
//  UserAccount.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//
//
//  UserManger.m
//  NagMe
//
//  Created by Neil Edwards on 12/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "UserAccount.h"
#import "NetUtilities.h"
#import "SFHFKeychainUtils.h"
#import "DeviceUtilities.h"
#import "Utiltities.h"
#import "MBProgressHUD.h"
#import "CycleStreets.h"
#import "Files.h"


@interface UserAccount(Private)

-(void)registerUserResponse:(ValidationVO*)validation;
-(void)retrievePasswordForUserResponse:(ValidationVO*)validation;
-(void)loginUserResponse:(ValidationVO*)validation;
-(void)removeUserState;
-(BOOL)saveUser;
-(void)loadUser;
-(void)createUser;
-(NSString*)filepath;

@end

@implementation UserAccount
SYNTHESIZE_SINGLETON_FOR_CLASS(UserAccount);
@synthesize user;
@synthesize userPassword;
@synthesize userName;
@synthesize userEmail;
@synthesize userVisibleName;
@synthesize isRegistered;
@synthesize sessionToken;
@synthesize deviceID;
@synthesize accountMode;
@synthesize HUD;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [user release], user = nil;
    [userPassword release], userPassword = nil;
    [userName release], userName = nil;
    [userEmail release], userEmail = nil;
    [userVisibleName release], userVisibleName = nil;
    [sessionToken release], sessionToken = nil;
    [deviceID release], deviceID = nil;
    [HUD release], HUD = nil;
	
    [super dealloc];
}




-(id)init{
	
	if (self = [super init])
	{
		isRegistered=YES;
		userPassword=@"";
		userName=@"";
		deviceID=[[[UIDevice currentDevice] uniqueIdentifier] retain];
		accountMode=kUserAccountNotLoggedIn;
		
		[self loadUser];
	}
	return self;
}



//
/***********************************************
 * @description			NOTIFICATION SUPPORT
 ***********************************************/
//

-(void)listNotificationInterests{
	
	
	[notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	[self addRequestID:REGISTER];
	[self addRequestID:LOGIN];
	[self addRequestID:PASSWORDRETRIEVAL];
	
	[super listNotificationInterests];
}



-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	NetResponse		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	
	if([self isRegisteredForRequest:dataid]){
		if([notification.name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
			
			if ([response.dataid isEqualToString:REGISTER]) {
				
				[self registerUserResponse:response.dataProvider];
				
			}else if ([response.dataid isEqualToString:LOGIN]) {
				
				[self loginUserResponse:response.dataProvider];
				
			}else if ([response.dataid isEqualToString:PASSWORDRETRIEVAL]){
				
				[self retrievePasswordForUserResponse:response.dataProvider];
			}
			
		}
		
	}
	
	
	
}



//
/***********************************************
 * @description			USER REGISTRATION
 ***********************************************/
//

-(void)registerUserWithUserName:(NSString*)name andPassword:(NSString*)password visibleName:(NSString*)visiblename email:(NSString*)email{
	
	userName=[email retain];
	userPassword=[password retain];
	userVisibleName=[visiblename retain];
	userEmail=[email retain];
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:userName, @"username",
									 userPassword,@"password", 
									 userEmail,@"email",
									 userVisibleName,@"name",nil];
	
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=REGISTER;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
	
	
}

-(void)registerUserResponse:(ValidationVO*)validation{
	
	switch(validation.validationStatus){
			
		case ValidationRegisterSuccess:
		{
			[self createUser];
			[self saveUser];
			
			isRegistered=YES;
			accountMode=kUserAccountLoggedIn;
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			[dict release];
		}	
			break;	
		case ValidationEmailExists:
		{
			user.email=@"";
			userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_register",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			[dict release];
		}
			break;
		case ValidationEmailInvalid:
		{
			user.email=@"";
			userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_email",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			[dict release];
		}	
			break;
			
	}
	
	
}




//
/***********************************************
 * @description			LOGIN USER
 ***********************************************/
//


-(void)loginExistingUser{
	if(accountMode==kUserAccountCredentialsExist){
		[self loginUserWithUserName:user.email andPassword:userPassword];
		[self showProgressHUDWithMessage:@"Logging in"];
	}
}


-(void)loginUserWithUserName:(NSString*)name andPassword:(NSString*)password{
	
	userName=[name retain];
	userPassword=[password retain];
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:userName, @"username",
									 userPassword,@"password", nil];
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=LOGIN;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
	
}

-(void)loginUserResponse:(ValidationVO*)validation{
	
	switch(validation.validationStatus){
			
		case ValidationLoginSuccess:
		{
			isRegistered=YES;
			accountMode=kUserAccountLoggedIn;
			[self createUser];
			[self saveUser];
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			[dict release];
		}
			break;
			
		case ValidationLoginFailed:
		{
			user.email=@"";
			userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_login",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			[dict release];
			
		}	
			break;
			
		default:
			
			
			break;
			
	}
	
	[self removeHUD];
	
}



//
/***********************************************
 * @description			PASSWORD RETRIEVAL
 ***********************************************/
//


-(void)retrievePasswordForUser:(NSString *)email{
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:userName, @"username", nil];
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",nil];
	
	NetRequest *request=[[NetRequest alloc]init];
	request.dataid=PASSWORDRETRIEVAL;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.revisonId=0;
	request.source=USER;
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
	[dict release];
	[request release];
	
}

-(void)retrievePasswordForUserResponse:(ValidationVO*)validation{
	
	
	switch(validation.validationStatus){
			
		case ValidationRetrivedPasswordSuccess:
		{
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:PASSWORDRETRIEVALRESPONSE object:nil userInfo:dict];
			[dict release];
		}
			break;
		case ValidationEmailNotRecognised:
		{
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_password",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:PASSWORDRETRIEVALRESPONSE object:nil userInfo:dict];
			[dict release];
		}
			break;	
			
	}
	
}


//
/***********************************************
 * @description			Logout existing user for this session. This does not reset the users stored state.
 ***********************************************/
//
-(void)logoutUser{
	accountMode=kUserAccountNotLoggedIn;
	
	// cs support
	[[CycleStreets sharedInstance].files resetPasswordInKeyChain];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationClearAccount" object:nil];
}

-(void)updateAutoLoginPreference:(BOOL)value{
	user.autoLogin=value;
	[self saveUser];
}


//
/***********************************************
 * @description			Will logout and reset all user stored state data, user will have to login
 ***********************************************/
//
-(void)resetUserAccount{
	isRegistered=NO;
	accountMode=kUserAccountNotLoggedIn;
	[self removeUserState];
	
	
}


//
/***********************************************
 * @description			UTILITY
 ***********************************************/
//


-(void)createUser{
	
	user=[[UserVO alloc]init];
	user.username=userName;
	
}




-(void)loadUser{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	
	BetterLog(@" filepath=%@",[self filepath]);
	
	if ([fm fileExistsAtPath:[self filepath]]) {
		
		BetterLog(@"User State file exists");
		
		NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self filepath]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		user = [[unarchiver decodeObjectForKey:kUSERSTATEARCHIVEKEY] retain];
		[unarchiver finishDecoding];
		[unarchiver release];
		[data release];
		
		
		if(user!=nil){
			
			NSError *error=nil;
			userPassword =[[SFHFKeychainUtils getPasswordForUsername:user.email andServiceName:[[NSBundle mainBundle] bundleIdentifier]   error:&error] retain];
			
			if(error!=nil){
				// if password is unknown but email is ok theyll need to re login
				BetterLog(@"[INFO] Keychain error occured: %@",[error description]);
				[self removeUserState];
			}else {
				
				if(userPassword!=nil){
					// if has autologin enabled will attempt to login now
					if(user.autoLogin==YES){
						//[self loginUserWithEmail:user.email andPassword:userPassword];
					}else {
						accountMode=kUserAccountCredentialsExist;
					}
					
					
				}else {
					
					BetterLog(@"[INFO]  Unable to retrieve userPassword from Keychain, Simulator=%i",[DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR);
					
					if([DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR){
						userPassword=@"123456";
						if(user.autoLogin==YES){
							//[self loginUserWithEmail:user.email andPassword:userPassword];
						}else {
							accountMode=kUserAccountCredentialsExist;
						}
						
					}else {
						[self removeUserState];
					}
					
				}
				
			}
			
		}		
		
	}else {
		
		BetterLog(@"User State file not found");
		
	}
	
}


-(BOOL)saveUser{
	
	NSError *error=nil;
	[SFHFKeychainUtils storeUsername:user.email andPassword:userPassword forServiceName:[[NSBundle mainBundle] bundleIdentifier] updateExisting:YES error:&error];
	
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:user forKey:kUSERSTATEARCHIVEKEY];
	[archiver finishEncoding];
	[data writeToFile:[self filepath] atomically:YES];
	
	[data release];
	[archiver release];
	
	
	if(error!=nil){
		BetterLog(@"[KEYCHAIN] Unable to save user details to key chain %@",[error description]);
		user=nil;
		userPassword=nil;
		userName=nil;
		return NO;
	}
	
	return YES;
}




-(void)removeUserState{
	
	NSError *error=nil;
	
	// removes user keychain entry
	[SFHFKeychainUtils deleteItemForUsername:user.email andServiceName:[[NSBundle mainBundle] bundleIdentifier] error:&error ];
	
	// removes userstate file
	NSFileManager *fm=[NSFileManager defaultManager];
	if ([fm fileExistsAtPath:[self filepath]]) {
		[fm removeItemAtPath:[self filepath] error:&error];
	}
	
	// user will need to relogin
	isRegistered=NO;
	sessionToken=nil;
	user=nil;
	userName=nil;
	userPassword=nil;
	
}


-(BOOL)hasSessionToken{
	return sessionToken!=nil;
}

-(BOOL)isLoggedIn{
	return accountMode==kUserAccountLoggedIn;
}



-(NSString*)filepath{
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* docsdir=[paths objectAtIndex:0];
	BetterLog(@"docsdir=%@",docsdir);
	return [docsdir stringByAppendingPathComponent:NMUSERSTATEFILE];	
}


//
/***********************************************
 * @description			HUDSUPPORT
 ***********************************************/
//


-(void)showProgressHUDWithMessage:(NSString*)message{
	
	HUD=[[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
    HUD.delegate = self;
	HUD.labelText=message;
	[HUD show:YES];
	
}


-(void)removeHUD{
	
	[HUD hide:YES];
	
}


-(void)hudWasHidden{
	
	[HUD removeFromSuperview];
	[HUD release];
	
}



@end
