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

@class BUNetworkOperation;

#define kCACHEDIRECTORY @"datacache"
#define kDATAPRIORITY @"none"
#define kCACHEARCHIVEKEY @"AppDataSourceCacheKey"


@protocol DataSourceManagerDelegate<NSObject>

@optional
-(void)DataSourceDidCompleteStartup;

@end


@interface BUDataSourceManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BUDataSourceManager);

@property(nonatomic,weak)id<DataSourceManagerDelegate>              delegate;
@property (nonatomic, strong) NSMutableDictionary                   * services;


-(void)doStartUpSequence;
-(void)requestDataForType:(NSNotification*)notification;
-(NSDictionary*)getServiceForType:(NSString*)type;


-(void)removeCachedDataForType:(NSString*)type;
-(void)removeCachedDataForTypeArray:(NSArray*)typeArray;

-(BOOL)cancelRequestForType:(NSString*)dataid;

- (void)processDataRequest:(BUNetworkOperation*)operation;

@end
