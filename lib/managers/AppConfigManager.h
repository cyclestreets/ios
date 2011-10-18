//
//  AppConfigManager.h
//  
//
//  Created by Neil Edwards on 18/08/2011.
//  Copyright 2011 buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#define APPCONFIG_DEV_PLISTFILENAME @"appconfig_dev"
#define APPCONFIG_STAGING_PLISTFILENAME @"appconfig_staging"
#define APPCONFIG_LIVE_PLISTFILENAME @"appconfig_live"

#define SERVICE_DEV_PLISTFILENAME @"services_dev"
#define SERVICE_STAGING_PLISTFILENAME @"services_staging"
#define SERVICE_LIVE_PLISTFILENAME @"services_live"



@protocol AppConfigManagerDelegate<NSObject>

@optional
-(void)startupFailedWithError:(NSString*)errorString;
-(void)startupComplete;


@end


@interface AppConfigManager : NSObject{

    NSDictionary                *configDict;
    
    id<AppConfigManagerDelegate> delegate;

}
@property (nonatomic, retain)	NSDictionary		*configDict;
@property (nonatomic, assign)	id<AppConfigManagerDelegate>		delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(AppConfigManager)

-(void)initialise;    

@end
