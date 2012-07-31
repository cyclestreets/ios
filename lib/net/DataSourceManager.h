//
//  XMLManager.h
//
//
//  Created by Neil Edwards on 24/11/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

// Provides a generic interface to loading new xml data
// passes outgoing & incoming xml packets through to the appropriate XMLParser sub class

#import <Foundation/Foundation.h>
#import "Model.h"
#import "SynthesizeSingleton.h"

#define kCACHEDIRECTORY @"datacache"
#define kDATAPRIORITY @"none"
#define kCACHEARCHIVEKEY @"AppDataSourceCacheKey"

@protocol DataSourceManagerDelegate<NSObject>

@optional
-(void)DataSourceDidCompleteStartup;

@end




@interface DataSourceManager : NSObject {
    
	NSMutableDictionary			*services;
	NSMutableString				*requestURL;
	NSString					*DATASOURCE;
	NSString					*diskCachePath;
	
	BOOL					startupState;
	
	BOOL					cacheCreated;
	NSMutableDictionary		*notifications;
	
	id<DataSourceManagerDelegate>  __unsafe_unretained delegate;
}
@property (nonatomic, strong) NSMutableDictionary		* services;
@property (nonatomic, strong) NSMutableString		* requestURL;
@property (nonatomic, strong) NSString		* DATASOURCE;
@property (nonatomic, strong) NSString		* diskCachePath;
@property (nonatomic, assign) BOOL		 startupState;
@property (nonatomic, assign) BOOL		 cacheCreated;
@property (nonatomic, strong) NSMutableDictionary		* notifications;
@property(nonatomic,unsafe_unretained)id<DataSourceManagerDelegate> delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DataSourceManager);

-(void)doStartUpSequence;
-(void)requestDataForType:(NSNotification*)notification;
-(NSDictionary*)getServiceForType:(NSString*)type;
@end
