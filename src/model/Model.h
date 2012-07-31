//
//  Model.h
//  CycleStreets
//
//  Created by neil on 23/11/2009.
//  Copyright 2009 CycleStreets.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationXMLParser.h"
#import "SynthesizeSingleton.h"

@protocol ModelDeleagte <NSObject> 



@optional
-(void)modelDidLoad;
-(void)modelDidFailWithError:(NSString*)error;
-(void)modelDidParseData:(NSString*)type;

@end



@interface Model : NSObject <ApplicationXMLParserDelegate>{
	
	
	NSMutableDictionary		*dataProviders;
	NSMutableDictionary		*cachedrequests;
	ApplicationXMLParser				*xmlparser;
	
	NSMutableDictionary		*activeRequests;
	
	// delegate
	id <ModelDeleagte> __unsafe_unretained delegate;
	
	int						maxMemoryItems;
}


@property(nonatomic,strong)NSMutableDictionary *dataProviders;
@property(nonatomic,strong)NSMutableDictionary *cachedrequests;
@property(nonatomic,strong)ApplicationXMLParser *xmlparser;
@property(nonatomic,strong)NSMutableDictionary *activeRequests;
@property(nonatomic,unsafe_unretained)id <ModelDeleagte> delegate;
@property(nonatomic,assign)int maxMemoryItems;



// singleton
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(Model);


//
/***********************************************
 * receives response vo from server, passes to specific parser
 ***********************************************/
//
-(void)parseData:(NetResponse*)response;
//
/***********************************************
 * returns dp for type & requestid
 ***********************************************/
//
-(id)dataProviderForType:(NSString*)type withRequestid:(NSString*)requestid;
//
/***********************************************
 * receives cached archived plist data, sets dp for type immediately, no parsing required
 ***********************************************/
//
-(void)setCachedData:(id)data forType:(NSString*)type withRequestid:(NSString*)requestid;


-(BOOL)loadCachedDataForType:(NSString*)dataid withRequestid:(NSString*)requestid;


-(BOOL)RequestIsExistingRequest:(NSString*)dataid withRequestid:(NSString*)requestid;

@end
