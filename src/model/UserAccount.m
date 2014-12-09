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
#import "BUResponseObject.h"
#import "StringUtilities.h"
#import "BUNetworkOperation.h"
#import "BUDataSourceManager.h"
#import "BuildTargetConstants.h"
#import "CSUserRouteList.h"

@interface UserAccount()


@property (nonatomic, retain)	NSString	*userName;
@property (nonatomic, retain)	NSString	*userEmail;
@property (nonatomic, retain)	NSString	*userVisibleName;
@property (nonatomic, assign)	BOOL		isRegistered;
@property (nonatomic, retain)	NSString	*sessionToken;
@property (nonatomic, retain)	NSString	*deviceID;


@property (nonatomic,strong) CSUserRouteList *userRouteDataProvider;


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

-(void)registerUserResponse:(BUNetworkOperation*)operation{
	
	BetterLog(@"");
	
	switch(operation.responseStatus){
			
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
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,operation.validationMessage,MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:REGISTERRESPONSE object:nil userInfo:dict];
			

			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Creation Error" andMessage:operation.validationMessage];
			
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
		[self loginUserWithUserName:_user.username andPassword:_userPassword displayHUD:YES];
	}
}

-(void)loginExistingUserSilent{
	if(_accountMode==kUserAccountCredentialsExist){
		[self loginUserWithUserName:_user.username andPassword:_userPassword displayHUD:NO];
	}
}



-(void)loginUserWithUserName:(NSString*)name andPassword:(NSString*)password displayHUD:(BOOL)displayHUD{
	
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
		
		[self loginUserResponse:operation displayHUD:displayHUD];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	if(displayHUD)
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Signing in" andMessage:nil];
	
}

-(void)loginUserResponse:(BUNetworkOperation*)operation displayHUD:(BOOL)displayHUD{
	
	switch(operation.responseStatus){
			
		case ValidationLoginSuccess:
		{
			
			
			_isRegistered=YES;
			_accountMode=kUserAccountLoggedIn;
			[self createUser];
			[self saveUser];
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,STATE,nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			
			if(displayHUD)
				[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Logged In" andMessage:nil];
			
		}
			break;
			
		case ValidationLoginFailed:
		{
			_user.email=@"";
			_userPassword=@"";
			
			NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ERROR,STATE,@"error_response_login",MESSAGE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:LOGINRESPONSE object:nil userInfo:dict];
			
			if(displayHUD)
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

-(void)retrievePasswordForUserResponse:(BUNetworkOperation*)operation{
	
	
	switch(operation.responseStatus){
			
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



#pragma mark - User route loading by username

-(void)loadRoutesForUser:(BOOL)isPaged cursorId:(NSString*)cursorID{
	
	NSMutableDictionary *parameters=[@{@"key":[CycleStreets sharedInstance].APIKey,
									   @"limit":@(30),
									   @"datetime":@"sqldatetime",
									   @"format":@"flat"} mutableCopy];
	
	if(isPaged){
		parameters[@"before"]=cursorID;
	}
	
	if([BuildTargetConstants buildTarget]==ApplicationBuildTarget_CNS){
		parameters[@"username"]=API_IDENTIFIER;
	}else{
		parameters[@"username"]=_user.username;
	}
	
	BUNetworkOperation *request=[[BUNetworkOperation alloc]init];
	request.dataid=ROUTESFORUSER;
	request.requestid=ZERO;
	request.parameters=parameters;
	request.source=DataSourceRequestCacheTypeUseNetwork;
	
	request.completionBlock=^(BUNetworkOperation *operation, BOOL complete,NSString *error){
		
		[self loadRoutesForUserResponse:operation];
		
	};
	
	[[BUDataSourceManager sharedInstance] processDataRequest:request];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Obtaining Routes for user" andMessage:nil];
	
	
}


-(void)loadRoutesForUserPage{
	
	//TODO: if CSUserRouteList has next page
	// call loadRoutesForUser:(BOOL)isPaged cursorId:(NSString*)cursorID  with pageination bottom value
	
	
}



-(void)loadRoutesForUserResponse:(BUNetworkOperation*)response{
	
	BetterLog(@"");
	
	switch(response.responseStatus){
			
		case VaidationUserRoutesSuccess:
		{
			
			if(_userRouteDataProvider==nil){
				self.userRouteDataProvider=response.responseObject;
			}else{
				CSUserRouteList *newlist=response.responseObject;
				self.userRouteDataProvider.requestpaginationDict=newlist.requestpaginationDict;
				
				[_userRouteDataProvider.routes addObjectsFromArray:newlist.routes];
				
			}
			
			NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:SUCCESS,STATE, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:ROUTESFORUSERRESPONSE object:nil userInfo:dict];
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Complete" andMessage:nil];
			
		}
		break;
		
		case ValidationUserRoutesFailed:
		{
			CSUserRouteList *newlist=response.responseObject;
			if(newlist==nil || newlist.count==0){
				NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:ERROR,@"status", nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ROUTESFORUSERRESPONSE" object:nil userInfo:dict];
			}
			
			[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"No results" andMessage:nil];
			
		}
		break;
			
		default:
		break;
			
	}
	
}


-(NSArray*)userRoutes{
	
	return _userRouteDataProvider.routes;
	
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
	if (_user==nil) {
		_accountMode=kUserAccountNotLoggedIn;
	}else{
		_accountMode=kUserAccountCredentialsExist;
	}
	
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
