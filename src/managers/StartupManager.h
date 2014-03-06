//
//  StartupManager.h
//  CycleStreets
//
//  Created by neil on 08/12/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

// controls startup sequence


#import <Foundation/Foundation.h>
#import "BUDataSourceManager.h"
#import "StyleManager.h"
#import	"StringManager.h"
#import "AppConfigManager.h"

@protocol StartupManagerDelegate<NSObject>

@optional
-(void)startupComplete;
-(void)startupFailedWithError:(NSString*)error;

@end


#define kSERVICEFILE @"services.plist"


@interface StartupManager : NSObject <DataSourceManagerDelegate,StyleManagerDelegate,StringManagerDelegate,AppConfigManagerDelegate>{
	NSUserDefaults				*userSettings;
	BOOL						networkAvailable;
	NSMutableDictionary			*userState;
	// delegate
	id<StartupManagerDelegate> __unsafe_unretained delegate;
	
	NSString					*error;
}
@property(nonatomic,strong)NSUserDefaults *userSettings;
@property(nonatomic,assign)BOOL networkAvailable;
@property(nonatomic,strong)NSMutableDictionary *userState;
@property(nonatomic,unsafe_unretained)id<StartupManagerDelegate> delegate;
@property(nonatomic,strong)NSString *error;


-(void)doStartupSequence;
@end
