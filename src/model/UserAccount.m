//
//  UserAccount.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/12/2010.
//  Copyright 2010 CycleStreets Ltd. All rights reserved.
//
//
//  UserManger.m
// CycleStreets
//
//  Created by Neil Edwards on 12/11/2010.
//  Copyright 2010 buffer. All rights reserved.
//

#import "UserAccount.h"
#import "SFHFKeychainUtils.h"
#import "DeviceUtilities.h"
#import "GlobalUtilities.h"
#import "HudManager.h"
#import "CycleStreets.h"
#import "Files.h"
#import "LoginVO.h"
#import "ValidationVO.h"
#import "StringUtilities.h"
#import "BUNetworkOperation.h"
#import "BUDataSourceManager.h"

@interface UserAccount()


@property (nonatomic, retain)	NSString	*userName;
@property (nonatomic, retain)	NSString	*userEmail;
@property (nonatomic, retain)	NSString	*userVisibleName;
@property (nonatomic, assign)	BOOL		isRegistered;
@property (nonatomic, retain)	NSString	*sessionToken;
@property (nonatomic, retain)	NSString	*deviceID;


@end

@implementation UserAccount
SYNTHESIZE_SINGLETON_FOR_CLASS(UserAccount);



-(instancetype)init{
	
	if (self = [super init])
	{
		_isRegistered=YES;
		_userPassword=@"";
		_userName=@"";
		_deviceID=[StringUtilities createAppUUID];
		_accountMode=kUserAccountNotLoggedIn;
		
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
	[notifications addObject:XMLPARSERDIDFAILPARSING];
	
	[self addRequestID:REGISTER];
	[self addRequestID:LOGIN];
	[self addRequestID:PASSWORDRETRIEVAL];
	
	[super listNotificationInterests];
}



-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	BUNetworkOperation		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED] || [notification.name isEqualToString:REQUESTDIDFAIL]){
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Network Error" andMessage:@"Unable to contact server"];
		}
		
	}
	
}



//
/***********************************************
 * @description			USER REGISTRATION
 ***********************************************/
//

-(void)registerUserWithUserName:(NSString*)name andPassword:(NSString*)password visibleName:(NSString*)visiblename email:(NSString*)email{
	
	self.userName=[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.userPassword=password;
	self.userVisibleName=visiblename;
	self.userEmail=email;
	
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:_userName, @"username",
									 _userPassword,@"password", 
									 _userEmail,@"email",
									 _userVisibleName,@"name",nil];
	
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",nil];
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=REGISTER;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[self registerUserResponse:operation];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Registering New User" andMessage:nil];
	
}

-(void)registerUserResponse:(BUNetworkOperation*)response{
	
	BetterLog(@"");
	
	switch(response.validationStatus){
			
		case ValidationRegisterSuccess:
		{
			[self createUser];
			[self saveUser];
			
			_isRegistered=YES;
			_accountMode=kUserAccountLoggedIn;
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Account Created" andMessage:nil];
			
		}	
			break;	
		case ValidationRegisterFailed:
		{
			_user.email=@"";
			_userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,response.validationMessage,MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			

			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Creation Error" andMessage:response.validationMessage];
			
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
	if(_accountMode==kUserAccountCredentialsExist){
		[self loginUserWithUserName:_user.username andPassword:_userPassword];
	}
}


-(void)loginUserWithUserName:(NSString*)name andPassword:(NSString*)password{
	
	self.userName=[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.userPassword=password;
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:_userName, @"username",
									 _userPassword,@"password", nil];
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey, @"key", nil];
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",nil];
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=LOGIN;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[self loginUserResponse:operation];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Signing in" andMessage:nil];
	
}

-(void)loginUserResponse:(BUNetworkOperation*)response{
	
	switch(response.validationStatus){
			
		case ValidationLoginSuccess:
		{
			
			
			_isRegistered=YES;
			_accountMode=kUserAccountLoggedIn;
			[self createUser];
			[self saveUser];
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Logged In" andMessage:nil];
			
		}
			break;
			
		case ValidationLoginFailed:
		{
			_user.email=@"";
			_userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_login",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			
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
	
	NSDictionary *postparameters=[NSDictionary dictionaryWithObjectsAndKeys:_userName, @"username", nil];
	NSDictionary *getparameters=[NSDictionary dictionaryWithObjectsAndKeys:[[CycleStreets sharedInstance] APIKey], @"key", nil];
	NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:postparameters,@"postparameters",getparameters,@"getparameters",nil];
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=PASSWORDRETRIEVAL;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[self retrievePasswordForUserResponse:operation];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	
	
}

-(void)retrievePasswordForUserResponse:(BUNetworkOperation*)response{
	
	
	switch(response.validationStatus){
			
		case ValidationRetrivedPasswordSuccess:
		{
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:PASSWORDRETRIEVALRESPONSE object:nil userInfo:dict];
			
			
			
		}
			break;
		case ValidationEmailNotRecognised:
		{
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_password",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:PASSWORDRETRIEVALRESPONSE object:nil userInfo:dict];
		}
			break;
			
		default:
			break;
			
	}
	
}



-(void)updateAutoLoginPreference:(BOOL)value{
	_user.autoLogin=value;
	[self saveUser];
}


//
/***********************************************
 * @description			Will logout and reset all user stored state data, user will have to login
 ***********************************************/
//
-(void)resetUserAccount{
	_isRegistered=NO;
	_accountMode=kUserAccountNotLoggedIn;
	[self removeUserState];
	
	
}


//
/***********************************************
 * @description			UTILITY
 ***********************************************/
//


-(void)createUser{
	
	self.user=[[UserVO alloc]init];
	_user.username=_userName;
	
}




-(void)loadUser{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	
	BetterLog(@" filepath=%@",[self filepath]);
	
	if ([fm fileExistsAtPath:[self filepath]]) {
		
		BetterLog(@"User State file exists");
		
		NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self filepath]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.user = [unarchiver decodeObjectForKey:kUSERSTATEARCHIVEKEY];
		[unarchiver finishDecoding];
		
		
		if(_user!=nil){
			
			NSError *error=nil;
			self.userPassword =[SFHFKeychainUtils getPasswordForUsername:_user.username andServiceName:[[NSBundle mainBundle] bundleIdentifier]   error:&error];			
			if(error!=nil){
				// if password is unknown but email is ok theyll need to re login
				BetterLog(@"[INFO] Keychain error occured: %@",[error description]);
				[self removeUserState];
			}else {
				
				if(_userPassword!=nil){
					_accountMode=kUserAccountCredentialsExist;
					
				}else {
					
					BetterLog(@"[INFO]  Unable to retrieve userPassword from Keychain, Simulator=%i",[DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR);
					
					if([DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR){
						self.userPassword=@"j166lypuff";
						if(_user.autoLogin==YES){
							_accountMode=kUserAccountCredentialsExist;
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
	[SFHFKeychainUtils storeUsername:_user.username andPassword:_userPassword forServiceName:[[NSBundle mainBundle] bundleIdentifier] updateExisting:YES error:&error];
	
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:_user forKey:kUSERSTATEARCHIVEKEY];
	[archiver finishEncoding];
	[data writeToFile:[self filepath] atomically:YES];
	
	
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
	_accountMode=kUserAccountNotLoggedIn;
}


-(void)removeUserState{
	
	BetterLog(@"");
	
	NSError *error=nil;
	
	// removes user keychain entry
	[SFHFKeychainUtils deleteItemForUsername:_user.email andServiceName:[[NSBundle mainBundle] bundleIdentifier] error:&error ];
	
	// removes userstate file
	NSFileManager *fm=[NSFileManager defaultManager];
	if ([fm fileExistsAtPath:[self filepath]]) {
		[fm removeItemAtPath:[self filepath] error:&error];
	}
	
	// user will need to relogin
	_isRegistered=NO;
	self.sessionToken=nil;
	self.user=nil;
	self.userName=nil;
	self.userPassword=nil;
	
}


-(BOOL)hasSessionToken{
	return _sessionToken!=nil;
}

-(BOOL)isLoggedIn{
	return _accountMode==kUserAccountLoggedIn;
}



-(NSString*)filepath{
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* docsdir=[paths objectAtIndex:0];
	BetterLog(@"docsdir=%@",docsdir);
	return [docsdir stringByAppendingPathComponent:NMUSERSTATEFILE];	
}






@end
