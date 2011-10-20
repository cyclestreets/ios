//
//  AppConfigManager.m
//  
//
//  Created by Neil Edwards on 18/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import "AppConfigManager.h"
#import "DataSourceManager.h"


@interface AppConfigManager(Private)

-(void)loadApplicationConfig;
-(void)loadServices;

-(NSString*)appconfigDataPath;
-(NSString*)serviceDataPath;

@end


@implementation AppConfigManager
SYNTHESIZE_SINGLETON_FOR_CLASS(AppConfigManager)
@synthesize configDict;
@synthesize delegate;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [configDict release], configDict = nil;
    delegate = nil;
    
    [super dealloc];
}




- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}


-(void)initialise{
    [self loadApplicationConfig];
}


-(void)loadApplicationConfig{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSString *appconfigpath=[self appconfigDataPath];
	BOOL appconfigexists = [fileManager fileExistsAtPath:appconfigpath];
	
	if(appconfigexists==YES){
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[self appconfigDataPath]];
		self.configDict=dict;
        [dict release];
		
		[self loadServices];
		
	}else {
		
        if([delegate respondsToSelector:@selector(startupFailedWithError:)]){
            [delegate startupFailedWithError:STARTUPERROR_CONFIGLOADFAILED];
        }
        self.delegate=nil;
	}
	
}



#pragma mark Data path methods
// @private
-(NSString*)appconfigDataPath{
    
    NSDictionary *infoDict=[[NSBundle mainBundle] infoDictionary];
	NSString *appconfigid=[infoDict objectForKey:@"APPCONFIG_ID"];
	
	if([appconfigid isEqualToString:APPSTATE_DEVELOPMENT]){
		return [[NSBundle mainBundle] pathForResource:APPCONFIG_DEV_PLISTFILENAME ofType:@"plist"];
	}else if ([appconfigid isEqualToString:APPSTATE_STAGING]) {
		return [[NSBundle mainBundle] pathForResource:APPCONFIG_STAGING_PLISTFILENAME ofType:@"plist"];
	}else {
		return [[NSBundle mainBundle] pathForResource:APPCONFIG_LIVE_PLISTFILENAME ofType:@"plist"];
	}
    
}

#pragma mark service loading methods

-(void)loadServices{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL servicesexist = [fileManager fileExistsAtPath:[self serviceDataPath]];
	
	if(servicesexist==YES){
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithContentsOfFile:[self serviceDataPath]];
		[DataSourceManager sharedInstance].services=dict;
        [dict release];
	}else {
        
        if([delegate respondsToSelector:@selector(startupFailedWithError:)]){
            [delegate startupFailedWithError:STARTUPERROR_SERVICELOADFAILED];
        }
        self.delegate=nil;
	}
	
}



#pragma mark Data path methods
// @private
-(NSString*)serviceDataPath{
    
    NSDictionary *infoDict=[[NSBundle mainBundle] infoDictionary];
	NSString *serverid=[infoDict objectForKey:@"SERVER_DOMAIN_ID"];
	
	if([serverid isEqualToString:APPSTATE_DEVELOPMENT]){
		return [[NSBundle mainBundle] pathForResource:SERVICE_DEV_PLISTFILENAME ofType:@"plist"];
	}else if ([serverid isEqualToString:APPSTATE_STAGING]) {
		return [[NSBundle mainBundle] pathForResource:SERVICE_STAGING_PLISTFILENAME ofType:@"plist"];
	}else {
		return [[NSBundle mainBundle] pathForResource:SERVICE_LIVE_PLISTFILENAME ofType:@"plist"];
	}
    
}



@end
