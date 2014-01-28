//
//  UserSettingsManager.h
//
//
//  Created by neil on 10/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//
// Manager for Settings values & state

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

// define user default keys
#define kSettingDataReset @"cache_reset"
#define kSettingDataIntervalKey @"cache_interval"

// define application state keys
// containers
#define	kSTATEUSERCONTROLLEDSETTINGSKEY	@"userControlledSettings"
#define	kSTATESYSTEMCONTROLLEDSETTINGSKEY	@"systemControlledSettings"
#define KUSERSTATECANSAVEUNKNOWNS 1

// define file paths
#define kSTATEFILE @"userState.plist"

@protocol UserSettingsManagerDelegate<NSObject>

-(void)startupFailedWithError:(NSString*)error;

@end


@interface UserSettingsManager : NSObject {
	NSUserDefaults			*settings;
	
	NSMutableDictionary		*stateDict;
	NSMutableDictionary		*userState;
	NSMutableDictionary		*systemState;
	
	BOOL					hasSettingsBundle;
	
	BOOL					userStateWritable;
	id<UserSettingsManagerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, strong) NSUserDefaults		* settings;
@property (nonatomic, strong) NSMutableDictionary		* stateDict;
@property (nonatomic, strong) NSMutableDictionary		* userState;
@property (nonatomic, strong) NSMutableDictionary		* systemState;
@property (nonatomic) BOOL		 hasSettingsBundle;
@property (nonatomic) BOOL		 userStateWritable;
@property(nonatomic,unsafe_unretained)id<UserSettingsManagerDelegate> delegate;


SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserSettingsManager);
//
-(void)saveApplicationState;
-(NSArray*)navigation;
-(NSString*)context;
-(NSDate*)lastOpenedDate;

-(void)saveObject:(id)object forKey:(NSString*)key;
-(void)saveObject:(id)object forType:(NSString*)type forKey:(NSString*)key;

-(id)fetchObjectforKey:(NSString*)key;
-(id)fetchObjectforKey:(NSString*)key forType:(NSString*)type;

-(int)getSavedSection;
-(void)setSavedSection:(NSString*)type;

-(id)userDefaultForType:(NSString*)key;

-(void)resetCacheReset;

-(void)updateNavigationControllerState:(NSArray*)controllers;
@end
