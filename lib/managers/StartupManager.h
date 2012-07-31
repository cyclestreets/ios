//
//  StartupManager.h
//
//
//  Created by neil on 08/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

// controls startup sequence


#import <Foundation/Foundation.h>
#import "DataSourceManager.h"
#import "StyleManager.h"
#import	"StringManager.h"
#import "AppConfigManager.h"


#define kDEVSERVICEFILE @"services_dev.plist" // nagme-ci.chromaagency.com
#define kLIVESERVICEFILE @"services_live.plist"  //nagme.com


@protocol StartupManagerDelegate<NSObject>

@optional
-(void)startupComplete;
-(void)startupFailedWithError:(NSString*)error;

@end



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
