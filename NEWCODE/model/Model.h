//
//  Model.h
//  RND
//
//  Created by neil on 23/11/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXMLParser.h"
#import "SynthesizeSingleton.h"

@protocol RNDModelDeleagte <NSObject> 



@optional
-(void)modelDidLoad;
-(void)modelDidFailWithError:(NSString*)error;
-(void)modelDidParseData:(NSString*)type;

@end



@interface Model : NSObject <TBXMLParserDelegate>{
	
	
	NSMutableDictionary		*dataProviders;
	NSMutableDictionary		*cachedrequests;
	TBXMLParser				*xmlparser;
	
	NSMutableDictionary		*activeRequests;
	
	// delegate
	id <RNDModelDeleagte> delegate;
	
	int						maxMemoryItems;
}


@property(nonatomic,retain)NSMutableDictionary *dataProviders;
@property(nonatomic,retain)NSMutableDictionary *cachedrequests;
@property(nonatomic,retain)TBXMLParser *xmlparser;
@property(nonatomic,retain)NSMutableDictionary *activeRequests;
@property(nonatomic,assign)id <RNDModelDeleagte> delegate;
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
