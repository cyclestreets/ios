//
//  XMLManager.m
//
//
//  Created by Neil Edwards on 24/11/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "BUDataSourceManager.h"
#import "UserSettingsManager.h"
#import "GlobalUtilities.h"
#import "StringUtilities.h"
#import "ApplicationXMLParser.h"
//#import "ApplicationJSONParser.h"
#import "GenericConstants.h"
#import "NSString-Utilities.h"
#import "ValidationVO.h"

#import "BUNetworkOperation.h"
#import <AFHTTPRequestOperationManager.h>

#define ENABLERESPONSECACHE 1


// @ private
@interface BUDataSourceManager()


@property (nonatomic, strong) NSMutableDictionary					* dataProviders;
@property (nonatomic, strong) NSMutableDictionary					* cachedrequests;
@property (nonatomic, strong) NSMutableDictionary					* activeRequests;
@property(nonatomic,assign)int										maxMemoryItems;


@property (nonatomic, strong) NSMutableString                       * requestURL;
@property (nonatomic, strong) NSString                              * DATASOURCE;
@property (nonatomic, strong) NSString                              * diskCachePath;
@property (nonatomic, assign) BOOL                                  startupState;
@property (nonatomic, assign) BOOL                                  cacheCreated;



@end





@implementation BUDataSourceManager
SYNTHESIZE_SINGLETON_FOR_CLASS(BUDataSourceManager);




//
/***********************************************
 * Notifications
 ***********************************************/
//

-(instancetype)init{
	
	if (self = [super init])
	{
		
		_DATASOURCE=REMOTEDATA;
		
		_cacheCreated=[self createCacheDirectory];
		
		[self removeStaleFiles];
        
        self.dataProviders=[NSMutableDictionary dictionary];
        self.activeRequests=[NSMutableDictionary dictionary];;
        self.cachedrequests=[NSMutableDictionary dictionary];
        
		_maxMemoryItems=10; // this is per dataid so will normally be c.70 blocks
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(didReceiveMemoryWarning:)
		 name:UIApplicationDidReceiveMemoryWarningNotification
		 object:nil];
		
	}
	return self;
	
}


-(void)listNotificationInterests{
	
    
    [notifications addObject:LOCALFILELOADED];
	
	[super listNotificationInterests];
    
	
}


-(void)didReceiveNotification:(NSNotification*)notification{
	
//	NSString *name=notification.name;
	
//	if([name isEqualToString:REMOTEFILELOADED]){
//		[self dataDidLoad:notification];
//	}else if([name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
//		[self modelDidParseData:notification];
//	}else if([name isEqualToString:REQUESTDATAREFRESH]){
//		[self requestDataForType:notification];
//	}else if ([name isEqualToString:REMOTEFILEFAILED]) {
//		[self requestDidFail:notification];
//	}else if ([name isEqualToString:XMLPARSERDIDFAILPARSING]) {
//		[self requestDidFail:notification];
//	}else if ([name isEqualToString:JSONPARSERDIDFAILPARSING]) {
//		[self requestDidFail:notification];
//	}if([name isEqualToString:LOCALFILELOADED]){
//		[self dataDidLoad:notification];
//    }

}


#pragma mark - Startup

-(void)sortStartupSourcesbyPriority{
	
}


-(void)doStartUpSequence{
	
	[self didCompleteStartup];
		
}


-(void)didCompleteStartup{
	
	if([_delegate respondsToSelector:@selector(DataSourceDidCompleteStartup)]){
		[_delegate DataSourceDidCompleteStartup];
	}
	
	_startupState=NO;
	
}


//
/***********************************************
 * Requests
 ***********************************************/
//
#pragma mark - Data Requests

// Deprecated
-(void)requestDataForType:(NSNotification*)notification{
	
	//[self processDataRequest:[[notification userInfo] objectForKey:@"request"]];
}


- (void)processDataRequest:(BUNetworkOperation*)operation {
    
    // source is system only we will ignore this request if the last requestid is the same
    // for user we will always refresh
    if(operation.source==DataSourceRequestCacheTypeUseCache){
		if([self RequestIsExistingRequest:operation.dataid withRequestid:operation.requestid]==YES){
			return;
		}
	}
    
    NSDictionary *service=[_services objectForKey:operation.dataid];
    BOOL doRemoteRequest=NO;
    
    if(service!=nil){
		BetterLog(@" [DEBUG] requestDataForType found service for %@",operation.dataid);
		operation.service=service;
		
	}else {
		BetterLog(@"[ERROR] Invalid service/dataid : %@",operation.dataid);
		[self sendErrorNotification:DATAREQUESTFAILED dict:nil];
		return;
	}
    
    if(_cacheCreated==YES){
		
		
		if(operation.source==DataSourceRequestCacheTypeUseCache){
			
			// check memory cache
			if([self loadMemoryCachedDataForOperation:operation]==NO){
				
				// check file cache
				doRemoteRequest=[self loadFileCachedData:operation];
				
				
			}else {
				BetterLog(@"[DEBUG] Model found dataid & requestid: %@ > %@",operation.dataid,operation.requestid);
                doRemoteRequest=NO;
			}
			
		}else {
			
			BetterLog(@"[DEBUG] Request is USER type, contacting server with %@",operation.dataid);
			doRemoteRequest=YES;
			
		}
		
	}else {
		
		BetterLog(@"[ERROR] Cache Directory doesnot exist: Executing with Remote data load for %@ with %@",operation.dataid,operation.requestid);
		doRemoteRequest=YES;
	}
    
    if(doRemoteRequest==YES){
        [self loadRemoteOperation:operation];
    }
    
}


#pragma mark - Remote data requests
-(void)loadRemoteOperation:(BUNetworkOperation*)networkOperation {
    
    BetterLog(@"");
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOTEDATAREQUESTED object:networkOperation userInfo:nil];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	
	AFHTTPRequestOperation *operation=[manager HTTPRequestOperationWithRequest:networkOperation.requestForType success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		networkOperation.responseData=responseObject;
		[self remoteRequestDidComplete:networkOperation];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		[self remoteRequestDidFail:networkOperation withError:error];
		
	}];
	
	
	[manager.operationQueue addOperation:operation];
	
	
}


-(void)remoteRequestDidComplete:(BUNetworkOperation*)networkOperation{
    
    BetterLog(@"");
    
	[self parseData:networkOperation];
    
}

-(void)remoteRequestDidFail:(BUNetworkOperation*)networkOperation withError:(NSError*)error{
    
    BetterLog(@"Error: %@",error.description);
    
    networkOperation.operationState=NetResponseStateFailedWithError;
    
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            networkOperation.operationError=NetResponseErrorNotConnected;
        break;
        case kCFURLErrorBadServerResponse:
        case NSURLErrorTimedOut:
            networkOperation.operationError=NetResponseErrorConnection;
        break;
            
        default:
            break;
    }
    
    [self sendErrorNotification:REQUESTDIDFAIL forResponse:networkOperation];
    
}


#pragma mark - Data Type parsers


-(void)parseData:(BUNetworkOperation*)networkOperation{
	
	BetterLog(@" for requestId %@",networkOperation.dataid );
	
	switch(networkOperation.dataType){
            
		case DATATYPE_XML:
		{
			[self initiateModelCacheStoreForType:networkOperation.dataid];
			
			[[ApplicationXMLParser sharedInstance] parseDataForOperation:networkOperation success:^(BUNetworkOperation *result) {
                
                [self XMLParseDidCompletewithOperation:networkOperation];
                
            } failure:^(BUNetworkOperation *result, NSError *error) {
                
                [self XMLParserDidFail:result withError:error];
                
            }];
        }
            break;
		case DATATYPE_JSON:
        {
//            [self initiateModelCacheStoreForType:response.dataid];
//			
//			[[ApplicationJSONParser sharedInstance] parseDataForResponse:response success:^(NetResponse *result) {
//                
//                [self JSONParseDidCompletewithResponse:result];
//                
//            } failure:^(NetResponse *result, NSError *error) {
//                
//                [self JSONParserDidFail:result withError:error];
//                
//            }];

        }
            break;
            
        case DATATYPE_OPTIONAL:
		{
			
        }
            break;
		default:
        {
            BetterLog(@"[ERROR] No parser found for this response: %@", networkOperation.dataid);
        }
			
            break;
	}
    
	
	
}


#pragma mark - XML response methods
-(void)XMLParseDidCompletewithOperation:(BUNetworkOperation*)networkOperation{
    
    BetterLog(@"");
    
    if(networkOperation.requestid!=nil){
        
        if(networkOperation.dataProvider!=nil)
            [[_dataProviders objectForKey:networkOperation.dataid] setObject:networkOperation.dataProvider forKey:networkOperation.requestid];
        
        // this will always overwrite same named objects
        // so no need to check for duplication request ids
        [_activeRequests setObject:networkOperation.requestid forKey:networkOperation.dataid];
        
        [self compactRequestsForDataid:networkOperation.dataid andRequest:networkOperation.requestid];
        
        if(networkOperation.source==DataSourceRequestCacheTypeUseCache)
            [self cacheRequestResult:networkOperation];
        
       
		if(networkOperation.completionBlock)
			networkOperation.completionBlock(networkOperation,YES,nil);
		
    }
    
}

-(void)XMLParserDidFail:(BUNetworkOperation*)networkOperation withError:(NSError*)error{
	
	BetterLog(@"");
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:networkOperation,RESPONSE, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:XMLPARSERDIDFAILPARSING object:networkOperation userInfo:dict];
	
	
}

#pragma mark - JSON response methods




#pragma mark - File cache

-(BOOL)loadFileCachedData:(BUNetworkOperation*)networkOperation{
	
	if([self checkCachedDataExpiration:networkOperation]){
		
		BetterLog(@"[DEBUG] cache file found and non-expired for %@ and %@",networkOperation.dataid,networkOperation.requestid);
		
		id result=[self retrieveFileCachedDataForType:networkOperation.dataid andID:networkOperation.requestid];
		
		if(result!=nil){
			[self setMemoryCachedDataForOperation:networkOperation];
            return NO;
		}else {
			return YES;
		}
		
		
	}else {
		
		BetterLog(@"[DEBUG] cached data file either not found or expired: Loading data from server %@ > %@",networkOperation.dataid,networkOperation.requestid);
		return YES;
		
	}
	
    return NO;
	
}






#pragma mark - Memory Cache support

-(void)initiateModelCacheStoreForType:(NSString*)type{
	
	if([_dataProviders objectForKey:type]==nil){
		[_dataProviders setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:type];
		[_cachedrequests setObject:[NSMutableArray arrayWithCapacity:10] forKey:type];
		
	}
	
}


//
/***********************************************
 * @description			locates and returns ram cached data for a request
 ***********************************************/
//
-(BOOL)loadMemoryCachedDataForOperation:(BUNetworkOperation*)networkOperation{
	
	BetterLog(@"");
	
	NSString *dataid=networkOperation.dataid;
	NSString *requestid=networkOperation.requestid;
	
	if([_dataProviders objectForKey:dataid]==nil){
		return NO;
	}
	
	if([[_dataProviders objectForKey:dataid] objectForKey:requestid]==nil){
		return NO;
	}
	
	
	networkOperation.dataProvider=[[_dataProviders objectForKey:dataid] objectForKey:requestid];
	
	if(networkOperation.completionBlock)
		networkOperation.completionBlock(networkOperation,YES,nil);
	
	
	return YES;
	
	
}

-(void)setMemoryCachedDataForOperation:(BUNetworkOperation*)networkOperation{
	
	NSString *dataid=networkOperation.dataid;
	NSString *requestid=networkOperation.requestid;
	
	BetterLog(@"[DEBUG] Model.setCachedData for type: %@",networkOperation.dataid);
	
	if([_dataProviders objectForKey:dataid]==nil){
		[_dataProviders setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:dataid];
	}
	
	[[_dataProviders objectForKey:dataid] setObject:networkOperation.dataProvider forKey:requestid];
	
	[_activeRequests setObject:requestid forKey:dataid];
	
	[self compactRequestsForDataid:dataid andRequest:requestid];
	
	if(networkOperation.completionBlock)
		networkOperation.completionBlock(networkOperation,YES,nil);
}


//
/***********************************************
 * stores refs to requestids, will remove ref & cached model data if maxMemoryItems per dataid is reached
 ***********************************************/
//
-(void)compactRequestsForDataid:(NSString*)dataid andRequest:(NSString*)requestid{
	
	NSMutableArray *dataarray=[_cachedrequests objectForKey:dataid];
	
	// ensure no duplicates inserted
	if(![dataarray containsObject:requestid]){
		[dataarray addObject:requestid];
	}
	
	// if exceeds max, remove oldest item;
	if([dataarray count]>_maxMemoryItems){
		NSString *removeablerequest=[dataarray objectAtIndex:0];
		NSMutableDictionary *dict=[_dataProviders objectForKey:dataid];
		[dict removeObjectForKey:removeablerequest];
		[dataarray removeObjectAtIndex:0];
	}
	
}


//
/***********************************************
 * checks to see if request is the same as the existing one for this data id, if so sends REQUESTWASACTIVE notification else DSM wil continue as normal
 ***********************************************/
//
-(BOOL)RequestIsExistingRequest:(NSString*)dataid withRequestid:(NSString*)requestid{
	
	BOOL result=[[_activeRequests objectForKey:dataid] isEqualToString:requestid];
	
	if(result==YES){
        
		BUNetworkOperation	*response=[[BUNetworkOperation alloc]init];
		response.dataid=dataid;
		response.requestid=requestid;
		response.dataProvider=nil;
		
		
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE, nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTWASACTIVE object:nil userInfo:dict];
		
		
	}
	
	return NO;
	
    
}




#pragma mark - File cache support

-(BOOL)createCacheDirectory{
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	//NSError *error=nil;
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString* docsdir=[paths objectAtIndex:0];
	NSString *cachepath=[docsdir stringByAppendingPathComponent:kCACHEDIRECTORY];
	
	
	BOOL resetCache=[[[UserSettingsManager sharedInstance] userDefaultForType:kSettingDataReset] boolValue];
	
	if(resetCache==YES){
		
		[fileManager removeItemAtPath:cachepath error:nil];
		
		if([fileManager createDirectoryAtPath:cachepath withIntermediateDirectories:NO attributes:nil error:nil ]){
			
			[[UserSettingsManager sharedInstance] resetCacheReset]; 
			
			return YES;
		}else{
			return NO;
		}
		
		
	}else {
		
		BOOL isDir;
		
		if([fileManager fileExistsAtPath:cachepath isDirectory:&isDir]){
			return YES;
		}else {
			
			if([fileManager createDirectoryAtPath:cachepath withIntermediateDirectories:NO attributes:nil error:nil ]){
				return YES;
			}else{
				return NO;
			}
		}
		
	}

	
}


//
/***********************************************
 * @description			returns YES if cache file exists & its cache interval has not been exceeded
 ***********************************************/
//
-(BOOL)checkCachedDataExpiration:(BUNetworkOperation*)request{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString	*filepath=[self cacheFilePathForType:request.dataid andID:request.requestid];
	NSDictionary *fileInfo=[fm attributesOfItemAtPath:filepath error:nil];
	NSDate *filedate=[fileInfo objectForKey:NSFileModificationDate];
	NSDate *now=[NSDate date];
		
	NSTimeInterval fileage = [now timeIntervalSinceDate:filedate];
	int cacheinterval=[[[UserSettingsManager sharedInstance] userDefaultForType:kSettingDataIntervalKey] intValue];
    int servicecacheinterval=request.serviceCacheInterval;
    
    if(servicecacheinterval>0){
        cacheinterval=servicecacheinterval;
    }
    
	cacheinterval=cacheinterval*60; // convert to mins
	
	BetterLog(@" fileage=%f  cacheinterval=%i",fileage,cacheinterval);
	
	if([fm fileExistsAtPath:filepath]){
		
		BOOL noRefresh=[[request.service objectForKey:@"neverRefresh"] boolValue];
		
		if(noRefresh==YES){
			BetterLog(@"[DEBUG] service.noRefresh: ignoring cache interval and loading from cache");
			return YES;
		}else {
			
			if (fileage<cacheinterval) {
				return YES;
			}else {
				BetterLog(@"[DEBUG] Cached File expired for %@ > %@, deleteing...",request.dataid,request.requestid);
				[fm removeItemAtPath:filepath error:nil];
				return NO;
			}
			
		}

		
	}
	
	return NO;
}



-(void)cacheRequestResult:(BUNetworkOperation*)response{
	
	BetterLog(@" dataid=%@",response.dataid);
    
    BOOL shouldBeCached=response.serviceShouldBeCached;
    
	if (_cacheCreated==YES && shouldBeCached==YES) {
	
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		
		// handles responses that are pure data or ones that are ValdationVO wrapped
		if([response.dataProvider isKindOfClass:[ValidationVO class]]){
			ValidationVO *dp=(ValidationVO*)response.dataProvider;
			[archiver encodeObject:dp forKey:kCACHEARCHIVEKEY];
		}else {
			[archiver encodeObject:response.dataProvider forKey:kCACHEARCHIVEKEY];
		};
		
		[archiver finishEncoding];
		[data writeToFile:[self cacheFilePathForType:response.dataid andID:response.requestid] atomically:YES];
		
		
	}

}



-(NSMutableArray*)retrieveFileCachedDataForType:(NSString*)type andID:(NSString*)requestid{
	
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSMutableArray *dataProvider=nil;
	
	if ([fm fileExistsAtPath:[self cacheFilePathForType:type andID:requestid]]) {
		
		BetterLog(@"[DEBUG] DataSourceManager.retrieveCachedDataForType type=%@",type);
		
		NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self cacheFilePathForType:type andID:requestid]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		dataProvider = [unarchiver decodeObjectForKey:kCACHEARCHIVEKEY];
		[unarchiver finishDecoding];
		
	}
	
	return dataProvider;
}



//
/***********************************************
 * does periodic cached file removal to save disk space
 ***********************************************/
//
-(void)removeStaleFiles{
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString	*datacachepath=[self cachePath];
	NSArray	*cacheFileArray=[ fm contentsOfDirectoryAtPath:datacachepath error:nil];
	NSDate *now=[NSDate date];
	int staleinterval=TIME_WEEK;
	NSString *filepath;
	NSDictionary *fileInfo;
	NSDate *filedate;
	NSTimeInterval fileage;
	
	for(int i=0;i<[cacheFileArray count];i++){
		
		filepath=[datacachepath stringByAppendingPathComponent:[cacheFileArray objectAtIndex:i]];
		fileInfo=[fm attributesOfItemAtPath:filepath error:nil];
		filedate=[fileInfo objectForKey:NSFileModificationDate];
		fileage=[now timeIntervalSinceDate:filedate];
		
		if (fileage>staleinterval) {
			if([fm fileExistsAtPath:filepath]){
				[fm removeItemAtPath:filepath error:nil];
			}
		}
		
	}
	
}



/// removes cached files for an array of request types, it will ignore any requestid suffixs
-(void)removeCacheFilesOfRequestTypeArray:(NSArray*)typeArray{
    
    NSFileManager *fm=[NSFileManager defaultManager];
	NSString	*datacachepath=[self cachePath];
	NSArray	*cacheFileArray=[ fm contentsOfDirectoryAtPath:datacachepath error:nil];
	NSString *filepath;
    
    // filter array down to just the ones we want to remove
    NSMutableArray *predicates = [NSMutableArray array];
    for (NSString *fileName in typeArray) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(SELF CONTAINS %@)", fileName];
        [predicates addObject:pred];
    }
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    cacheFileArray=[cacheFileArray filteredArrayUsingPredicate:compoundPredicate];

	// optimised removal
	for(NSString *filename in cacheFileArray){
        filepath=[datacachepath stringByAppendingPathComponent:filename];
        
        if([fm fileExistsAtPath:filepath]){
            [fm removeItemAtPath:filepath error:nil];
        }
		
	}
    
}



#pragma mark - Utilities

-(void)removeCachedDataForType:(NSString*)type{
    
    if([_dataProviders objectForKey:type]!=nil){
		[_dataProviders removeObjectForKey:type];
	}
    
    [self removeCacheFilesOfRequestTypeArray:@[type]];
    
}

-(void)removeCachedDataForTypeArray:(NSArray*)typeArray{
    
    for(NSString *requestType in typeArray ){
        
        if([_dataProviders objectForKey:requestType]!=nil){
            [_dataProviders removeObjectForKey:requestType];
        }
    }
    
    
    
    [self removeCacheFilesOfRequestTypeArray:typeArray];
    
}


-(NSDictionary*)getServiceForType:(NSString*)type{
	
	if(_services!=nil){
		return [_services objectForKey:type];
	}
	return nil;		
}

-(NSString*)cacheFilePathForType:(NSString*)type andID:(NSString*)requestid{
	
	return [[self cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@_cache.plist",type,requestid]]; 
	// should be file name type rather than plain type
	
}


-(NSString*)cachePath{
	
	if(_diskCachePath==nil){
		NSArray* paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString* docsdir=[paths objectAtIndex:0];
		self.diskCachePath=[docsdir stringByAppendingPathComponent:kCACHEDIRECTORY];
	}
	
	return 	_diskCachePath;
	
}



#pragma mark - Error alerts

-(void)displayRequestFailedError:(NSString*)title :(NSString*)message :(NSString*)buttonLabel{
    
    // TODO: should be inline or HUD Error not Alert!
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:buttonLabel otherButtonTitles:nil, nil];
	[alert show];
	
}


-(void)sendErrorNotification:(NSString*)error dict:(NSDictionary*)dict{
    
	
	[[NSNotificationCenter defaultCenter] postNotificationName:error object:nil userInfo:dict];
	
}

-(void)sendErrorNotification:(NSString*)error forResponse:(BUNetworkOperation*)response{
	
    response.operationError=NetResponseErrorConnection;
    
	[[NSNotificationCenter defaultCenter] postNotificationName:error object:response userInfo:nil];
	
}


-(void)didReceiveMemoryWarning:(NSNotification*)notification{
    
}


@end
