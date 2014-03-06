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
#import "SynthesizeSingleton.h"
#import "FrameworkObject.h"


#define kCACHEDIRECTORY @"datacache"
#define kDATAPRIORITY @"none"
#define kCACHEARCHIVEKEY @"AppDataSourceCacheKey"


@interface BUDataSourceManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DataSourceManager);


@property (nonatomic, strong) NSMutableDictionary                   * services;
@property (nonatomic, strong) NSMutableString                       * requestURL;
@property (nonatomic, strong) NSString                              * DATASOURCE;
@property (nonatomic, strong) NSString                              * diskCachePath;
@property (nonatomic, assign) BOOL                                  startupState;
@property (nonatomic, assign) BOOL                                  cacheCreated;


-(void)doStartUpSequence;
-(void)requestDataForType:(NSNotification*)notification;
-(NSDictionary*)getServiceForType:(NSString*)type;


-(void)removeCachedDataForType:(NSString*)type;
-(void)removeCachedDataForTypeArray:(NSArray*)typeArray;


- (void)processDataRequest:(NetRequest*)request forClient:(AFHTTPClientWrapper*)clientSharedInstance;

@end
