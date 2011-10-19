//
//  StartupManager.h
//  RacingUK
//
//  Created by neil on 08/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

// controls startup sequence


#import <Foundation/Foundation.h>
#import "DataSourceManager.h"
#import "StyleManager.h"
#import	"StringManager.h"
#import "AppConfigManager.h"

@protocol StartupManagerDelegate<NSObject>

@optional
-(void)startupComplete;
-(void)startupFailedWithError:(NSString*)error;

@end


#define kSERVICEFILE @"services.plist"


@interface StartupManager : NSObject <DataSourceDelegate,StyleManagerDelegate,StringManagerDelegate,AppConfigManagerDelegate>{
	NSUserDefaults				*userSettings;
	BOOL						networkAvailable;
	NSMutableDictionary			*userState;
	// delegate
	id<StartupManagerDelegate> delegate;
	
	NSString					*error;
}
@property(nonatomic,retain)NSUserDefaults *userSettings;
@property(nonatomic,assign)BOOL networkAvailable;
@property(nonatomic,retain)NSMutableDictionary *userState;
@property(nonatomic,assign)id<StartupManagerDelegate> delegate;
@property(nonatomic,retain)NSString *error;


-(void)doStartupSequence;
@end
