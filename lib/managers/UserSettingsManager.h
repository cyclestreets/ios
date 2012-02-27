//
//  RKUserSettingsManager.h
//  CycleStreets
//
//  Created by neil on 10/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//
// Manager for Settings values & state

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

// define user default keys
#define kSettingDataReset @"cache_reset"
#define kSettingDataIntervalKey @"cache_interval"

// define application state keys

#define	kSTATENAVIGATION @"navigation"
#define	kSTATECONTEXT	@"context"

// define file paths
#define kSTATEFILE @"userState.plist"

@protocol UserSettingsManagerDelegate<NSObject>

-(void)startupFailedWithError:(NSString*)error;

@end


@interface UserSettingsManager : NSObject {
	NSUserDefaults			*settings;
	NSMutableDictionary		*userState;
	BOOL					userStateWritable;
	id<UserSettingsManagerDelegate> delegate;
}
@property(nonatomic,retain)NSUserDefaults *settings;
@property(nonatomic,retain)NSMutableDictionary *userState;
@property(nonatomic,assign)BOOL userStateWritable;
@property(nonatomic,assign)id<UserSettingsManagerDelegate> delegate;


SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserSettingsManager);
//
-(void)saveApplicationState;
-(NSArray*)navigation;
-(NSString*)context;
-(int)getSavedSection;
-(void)setSavedSection:(NSString*)type;
-(id)userDefaultForType:(NSString*)key;
-(void)resetCacheReset;
-(void)updateNavigationControllerState:(NSArray*)controllers;
@end
