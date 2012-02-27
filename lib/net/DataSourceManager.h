//
//  XMLManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 24/11/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

// Provides a generic interface to loading new xml data
// passes outgoing & incoming xml packets through to the appropriate XMLParser sub class

#import <Foundation/Foundation.h>
#import "Model.h"
#import "SynthesizeSingleton.h"

#define kCACHEDIRECTORY @"datacache"
#define kDATAPRIORITY @"racecard"
#define kCACHEARCHIVEKEY @"RKCachedDataArchiveKey"

@protocol DataSourceDelegate<NSObject>

@optional
-(void)DataSourceDidCompleteStartup;

@end




@interface DataSourceManager : NSObject {
	NSDictionary			*services;
	NSMutableString			*requestURL;
	NSString				*dataPriority;
	NSString				*DATASOURCE;
	
	BOOL					startupState;
	
	id<DataSourceDelegate>  delegate;
	
	BOOL					cacheCreated;
	NSMutableDictionary		*notifications;
}
@property(nonatomic,retain)NSDictionary *services;
@property(nonatomic,retain)NSMutableString *requestURL;
@property(nonatomic,retain)NSString *dataPriority;
@property(nonatomic,retain)NSString *DATASOURCE;
@property(nonatomic,assign)BOOL startupState;
@property(nonatomic,assign)id<DataSourceDelegate> delegate;
@property(nonatomic,assign)BOOL cacheCreated;
@property(nonatomic,retain)NSMutableDictionary *notifications;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DataSourceManager);

-(void)doStartUpSequence;
//-(void)requestDataForType:(NSString*)type parameters:(id)firstObject, ...;
//-(void)requestDataForType:(NSString*)type withId:(NSString*)requestid parameters:(id)params, ...;
-(void)requestDataForType:(NSNotification*)notification;
-(NSDictionary*)getServiceForType:(NSString*)type;
@end
