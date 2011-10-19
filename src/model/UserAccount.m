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
#import "HudManager.h"
#import "CycleStreets.h"
#import "Files.h"
#import "LoginVO.h"


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
	
	BetterLog(@"response.dataid=%@",response.dataid);
	
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
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
	}
	
	
}



//
/***********************************************
 * @description			USER REGISTRATION
 ***********************************************/
//

-(void)registerUserWithUserName:(NSString*)name andPassword:(NSString*)password visibleName:(NSString*)visiblename email:(NSString*)email{
	
	userName=[name retain];
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
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Registering New User" andMessage:nil];
	
}

-(void)registerUserResponse:(ValidationVO*)validation{
	
	BetterLog(@"");
	
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
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Account Created" andMessage:nil];
			
		}	
			break;	
		case ValidationRegisterFailed:
		{
			user.email=@"";
			userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,validation.returnMessage,MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			[dict release];
			

			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Creation Error" andMessage:validation.returnMessage];
			
		}
			break;
		
		default:
			
			[[HudManager sharedInstance] removeHUD];
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
		[self loginUserWithUserName:user.username andPassword:userPassword];
	}
}


-(void)loginUserWithUserName:(NSString*)name andPassword:(NSString*)password{
	
	self.userName=name;
	self.userPassword=password;
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:userName, @"username",
									 userPassword,@"password", nil];
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey, @"key", nil];
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
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Signing in" andMessage:nil];
	
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
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Logged In" andMessage:nil];
			
		}
			break;
			
		case ValidationLoginFailed:
		{
			user.email=@"";
			userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_login",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			[dict release];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Login Failed" andMessage:nil];
			
		}	
			break;
			
		default:
			
			[[HudManager sharedInstance] removeHUD];
		break;
			
	}
	
	
	
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
	
	self.user=[[UserVO alloc]init];
	user.username=userName;
	
}




-(void)loadUser{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	
	BetterLog(@" filepath=%@",[self filepath]);
	
	if ([fm fileExistsAtPath:[self filepath]]) {
		
		BetterLog(@"User State file exists");
		
		NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self filepath]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.user = [[unarchiver decodeObjectForKey:kUSERSTATEARCHIVEKEY] retain];
		[unarchiver finishDecoding];
		[unarchiver release];
		[data release];
		
		
		if(user!=nil){
			
			NSError *error=nil;
			self.userPassword =[SFHFKeychainUtils getPasswordForUsername:user.username andServiceName:[[NSBundle mainBundle] bundleIdentifier]   error:&error];			
			if(error!=nil){
				// if password is unknown but email is ok theyll need to re login
				BetterLog(@"[INFO] Keychain error occured: %@",[error description]);
				[self removeUserState];
			}else {
				
				if(userPassword!=nil){
					accountMode=kUserAccountCredentialsExist;
					
				}else {
					
					BetterLog(@"[INFO]  Unable to retrieve userPassword from Keychain, Simulator=%i",[DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR);
					
					if([DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR){
						self.userPassword=@"j166lypuff";
						if(user.autoLogin==YES){
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
	
	BetterLog(@"");
	
	NSError *error=nil;
	[SFHFKeychainUtils storeUsername:user.username andPassword:userPassword forServiceName:[[NSBundle mainBundle] bundleIdentifier] updateExisting:YES error:&error];
	
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:user forKey:kUSERSTATEARCHIVEKEY];
	[archiver finishEncoding];
	[data writeToFile:[self filepath] atomically:YES];
	
	[data release];
	[archiver release];
	
	if([DeviceUtilities detectDevice]!=MODEL_IPHONE_SIMULATOR){
	
		if(error!=nil){
			BetterLog(@"[KEYCHAIN] Unable to save user details to key chain %@",[error description]);
			self.user=nil;
			self.userPassword=nil;
			self.userName=nil;
			return NO;
		}
		
	}
	
	return YES;
}



-(void)logoutUser{
	accountMode=kUserAccountNotLoggedIn;
}


-(void)removeUserState{
	
	BetterLog(@"");
	
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
	self.sessionToken=nil;
	self.user=nil;
	self.userName=nil;
	self.userPassword=nil;
	
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






@end
