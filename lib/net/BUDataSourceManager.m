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
#import "ApplicationJSONParser.h"
#import "GenericConstants.h"
#import "AppAccountManager.h"
#import "NSString-Utilities.h"

#import "BUNetworkOperation.h"
#import <AFHTTPRequestOperationManager.h>

#define ENABLERESPONSECACHE 1


// @ private
@interface BUDataSourceManager()


@property (nonatomic, strong) NSMutableDictionary		* dataProviders;
@property (nonatomic, strong) NSMutableDictionary		* cachedrequests;
@property (nonatomic, strong) NSMutableDictionary		* activeRequests;
@property(nonatomic,assign)int maxMemoryItems;


-(void)didCompleteStartup;
// new variants with request id

// cached data methods
-(NSString*)cachePath;
-(BOOL)createCacheDirectory;
-(void)cacheRequestResult:(BUNetworkOperation*)response;
-(BOOL)checkCachedDataExpiration:(BUNetworkOperation*)request;
-(BOOL)loadCachedData:(BUNetworkOperation*)request;
-(NSMutableArray*)retrieveCachedDataForType:(NSString*)type andID:(NSString*)requestid;
-(NSString*)cacheFilePathForType:(NSString*)type andID:(NSString*)requestid;

-(void)sendErrorNotification:(NSString*)error dict:(NSDictionary*)dict;
-(void)sendErrorNotification:(NSString*)error forOpeartion:(BUNetworkOperation*)operation;
-(void)displayRequestFailedError:(NSString*)title :(NSString*)message :(NSString*)buttonLabel;
-(void)removeStaleFiles;
-(BOOL)connectionCacheFallback:(NetResponse*)response;

// compatability mode
-(void)modelDidParseData:(NSNotification*)notification;
-(void)dataDidLoad:(NSNotification*)notification;
-(void)requestDidFail:(NSNotification*)notification;

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
	
	
	[notifications addObject:REMOTEFILELOADED];
	[notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:REQUESTDATAREFRESH];
	[notifications addObject:REMOTEFILEFAILED];
	[notifications addObject:XMLPARSERDIDFAILPARSING];
	[notifications addObject:JSONPARSERDIDFAILPARSING];
    
    [notifications addObject:LOCALFILELOADED];
	
	[super listNotificationInterests];
    
	
}


-(void)didReceiveNotification:(NSNotification*)notification{
	
	NSString *name=notification.name;
	
	if([name isEqualToString:REMOTEFILELOADED]){
		[self dataDidLoad:notification];
	}else if([name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
		[self modelDidParseData:notification];
	}else if([name isEqualToString:REQUESTDATAREFRESH]){
		[self requestDataForType:notification];
	}else if ([name isEqualToString:REMOTEFILEFAILED]) {
		[self requestDidFail:notification];
	}else if ([name isEqualToString:XMLPARSERDIDFAILPARSING]) {
		[self requestDidFail:notification];
	}else if ([name isEqualToString:JSONPARSERDIDFAILPARSING]) {
		[self requestDidFail:notification];
	}if([name isEqualToString:LOCALFILELOADED]){
		[self dataDidLoad:notification];
    }

}


//
/***********************************************
 * Startup
 ***********************************************/
//


-(void)sortStartupSourcesbyPriority{
	
}


-(void)doStartUpSequence{
	
	[self didCompleteStartup];
		
}



//
/***********************************************
 * Requests
 ***********************************************/
//
#pragma mark Data Requests

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
    
    NSDictionary *service=[services objectForKey:operation.dataid];
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
			
			// SYSTEM initiated request go through the model>cache>remote checking chain
			if(![self loadCachedDataForType:operation.dataid withRequestid:operation.requestid]){
				doRemoteRequest=[self loadCachedData:operation];
			}else {
#if ENABLERESPONSECACHE
				BetterLog(@"[DEBUG] Model found dataid & requestid: %@ > %@",operation.dataid,operation.requestid);
                doRemoteRequest=NO;
#else
                BetterLog(@"[DEBUG] Model found dataid & requestid but ENABLERESPONSECACHE=FALSE so loading from server again");
                doRemoteRequest=YES;
#endif
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


#pragma mark Remote data requests
-(void)loadRemoteOperation:(BUNetworkOperation*)networkOperation {
    
    BetterLog(@"");
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOTEDATAREQUESTED object:networkOperation userInfo:nil];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	
	AFHTTPRequestOperation *operation=[manager HTTPRequestOperationWithRequest:networkOperation.requestForType success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		networkOperation.responseData=(NSMutableData*)responseObject;
		[self remoteRequestDidComplete:operation];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
	}];
	
	networkOperation.networkOperation=operation;
	
	[manager.operationQueue addOperation:operation];
	
	
    
    [AFclientSharedInstance doNetworkRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        
        switch (response.responseState) {
            case NetResponseStateFailed:
            {
                
                
            }
            break;
              
            case NetResponseStateFailedWithError:
            {
                switch (response.errorType) {
                        
                    case NetResponseErrorAuthorisation:
                        
                    {
                                
                    }
                        
                    default:
                
                break;
                
                }
                
                
            }
            break;
                
            default:
            {
                response.responseData=(NSMutableData*)responseObject;
                [self remoteRequestDidComplete:response];
            }
            break;
        }
    
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        [self remoteRequestDidFail:response withError:error];
        
    }];
}


-(void)remoteRequestDidComplete:(NetResponse*)response{
    
    BetterLog(@"");
    
	[self parseData:response];
    
}

-(void)remoteRequestDidFail:(NetResponse*)response withError:(NSError*)error{
    
    BetterLog(@"Error: %@",error.description);
    
    response.responseState=NetResponseStateFailedWithError;
    
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            response.errorType=NetResponseErrorNotConnected;
        break;
        case kCFURLErrorBadServerResponse:
        case NSURLErrorTimedOut:
            response.errorType=NetResponseErrorConnection;
        break;
            
        default:
            break;
    }
    
    [self sendErrorNotification:REQUESTDIDFAIL forResponse:response];
    
}


#pragma mark Data Type parsers


-(void)parseData:(NetResponse*)response{
	
	BetterLog(@" for requestId %@",response.dataid );
	
	switch(response.dataType){
            
		case DATATYPE_XML:
		{
			[self initiateModelCacheStoreForType:response.dataid];
			
			[[ApplicationXMLParser sharedInstance] parseDataForResponse:response success:^(NetResponse *result) {
                
                [self XMLParseDidCompletewithResponse:result];
                
            } failure:^(NetResponse *result, NSError *error) {
                
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
			[self initiateModelCacheStoreForType:response.dataid];
			
			[[PPXMLParser sharedInstance] parseDataForResponse:response success:^(NetResponse *result) {
                
                [self XMLParseDidCompletewithResponse:result];
                
            } failure:^(NetResponse *result, NSError *error) {
                
                [self XMLParserDidFail:result withError:error];
                
            }];
        }
            break;
		default:
        {
            BetterLog(@"[ERROR] No parser found for this response: %@", response.dataid);
        }
			
            break;
	}
    
	
	
}


#pragma mark XML response methods
-(void)XMLParseDidCompletewithResponse:(NetResponse*)response{
    
    BetterLog(@"");
    
    if(response.requestid!=nil){
        
        if(response.dataProvider!=nil)
            [[_dataProviders objectForKey:response.dataid] setObject:response.dataProvider forKey:response.requestid];
        
        // this will always overwrite same named objects
        // so no need to check for duplication request ids
        [_activeRequests setObject:response.requestid forKey:response.dataid];
        
        [self compactRequestsForDataid:response.dataid andRequest:response.requestid];
        
        if(response.source==DataSourceRequestCacheTypeUseCache)
            [self cacheRequestResult:response];
        
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:RESPONSESERVER,RESPONSE, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETE object:response userInfo:dict];
    }
    
}

-(void)XMLParserDidFail:(NetResponse*)response withError:(NSError*)error{
	
	BetterLog(@"");
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:XMLPARSERDIDFAILPARSING object:response userInfo:dict];
	
	
}

#pragma mark JSON response methods

-(BOOL)loadCachedData:(NetRequest*)request{
	
	if([self checkCachedDataExpiration:request]){
		
		BetterLog(@"[DEBUG] cache file found and non-expired for %@ and %@",request.dataid,request.requestid);
		
		id result=[self retrieveCachedDataForType:request.dataid andID:request.requestid];
		
		if(result!=nil){
			[self setCachedData:result forType:request.dataid withRequestid:request.requestid];
            return NO;
		}else {
			return YES;
		}
		
		
	}else {
		
		BetterLog(@"[DEBUG] cached data file either not found or expired: Loading data from server %@ > %@",request.dataid,request.requestid);
		return YES;
		
	}
	
    return NO;
	
}



-(void)didCompleteStartup{
	
	if([delegate respondsToSelector:@selector(DataSourceDidCompleteStartup)]){
		[delegate DataSourceDidCompleteStartup];
	}
	
	startupState=NO;

}


#pragma mark memory Request Support

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
-(BOOL)loadCachedDataForType:(NSString*)dataid withRequestid:(NSString*)requestid{
	
	BetterLog(@"");
	
	
	if([_dataProviders objectForKey:dataid]==nil){
		return NO;
	}
	
	if([[_dataProviders objectForKey:dataid] objectForKey:requestid]==nil){
		return NO;
	}
	
	
	NetResponse	*response=[[NetResponse alloc]init];
	response.dataid=dataid;
	response.requestid=requestid;
	response.dataProvider=[[_dataProviders objectForKey:dataid] objectForKey:requestid];
	
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:RESPONSEMODEL,RESPONSE, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETE object:response userInfo:dict];
	
	
	return YES;
	
	
}

-(void)setCachedData:(id)data forType:(NSString*)type withRequestid:(NSString*)requestid{
	
	BetterLog(@"[DEBUG] Model.setCachedData for type: %@",type);
	
	if([_dataProviders objectForKey:type]==nil){
		[_dataProviders setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:type];
	}
	
	[[_dataProviders objectForKey:type] setObject:data forKey:requestid];
	
	[_activeRequests setObject:requestid forKey:type];
	
	[self compactRequestsForDataid:type andRequest:requestid];
	
	NetResponse	*response=[[NetResponse alloc]init];
	response.dataid=type;
	response.requestid=requestid;
	response.dataProvider=data;
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:RESPONSECACHE,RESPONSE,nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETE object:response userInfo:dict];
	
	
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
        
		NetResponse	*response=[[NetResponse alloc]init];
		response.dataid=dataid;
		response.requestid=requestid;
		response.dataProvider=nil;
		
		
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:response,RESPONSE, nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTWASACTIVE object:nil userInfo:dict];
		
		
	}
	
	return NO;
	
    
}


//
/***********************************************
 * Responses
 ***********************************************/
//


// Notification from Remote Manager when data has downloaded
-(void)dataDidLoad:(NSNotification*)notification{
	
	NSDictionary *userInfo=[notification userInfo];
	NetResponse *response=[userInfo objectForKey:@"response"];
	
	[[Model sharedInstance] parseData:response];
	
}

// Notification from Remote Manager or Model when a data request has an error
-(void)requestDidFail:(NSNotification*)notification{
	
	NSString *name=notification.name;
	
	if([name isEqualToString:REMOTEFILEFAILED]){
		
		NSDictionary *userInfo=[notification userInfo];
		NetResponse *response=[userInfo objectForKey:@"response"];
		
		if([response.error isEqualToString:REMOTEFILEFAILED]){
			
			if([self connectionCacheFallback:response]==NO){
				
				[self displayRequestFailedError:CONNECTIONERROR :UNABLETOCONTACT :OK];
			
				[self sendErrorNotification:CONNECTIONERROR dict:userInfo];
			}
			
		}else if ([response.error isEqualToString:SERVERCONNECTIONFAILED]) {
			
			if([self connectionCacheFallback:response]==NO){
				
				[self displayRequestFailedError:SERVERDOWNERROR :SERVERDOWN :OK];
				
				[self sendErrorNotification:SERVERDOWNERROR dict:userInfo];
			}
			
		}

		
	}else if ([name isEqualToString:XMLPARSERDIDFAILPARSING]) {
		
		NSDictionary *userInfo=[notification userInfo];
		NetResponse *response=[userInfo objectForKey:@"response"];
		
		BetterLog(@" XML Error: %@",response.error);
		
		if([response.error isEqualToString:XMLPARSER_RESPONSENOENTRIES]){
			
			[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDFAIL object:response userInfo:nil];
			
		}else {
			//[self displayRequestFailedError:XMLPARSERERROR :INVALIDRESPONSE :OK];
			[self sendErrorNotification:REQUESTDIDFAIL forResponse:response];
		}
		
	}else if ([name isEqualToString:JSONPARSERDIDFAILPARSING]) {
		
		NSDictionary *userInfo=[notification userInfo];
		
		//[self displayRequestFailedError:JSONPARSERERROR :INVALIDRESPONSE :OK];
		[self sendErrorNotification:REQUESTDIDFAIL dict:userInfo];
		
		
	}
	
	
	
}



//
/***********************************************
 * @description			handles event when connection has failed but we have a cached file available
 ***********************************************/
//
-(BOOL)connectionCacheFallback:(NetResponse*)response{
	
	NSMutableArray *result=[self retrieveCachedDataForType:response.dataid andID:response.requestid];
	
	if(result==nil){
		return NO;
	}else {
		BetterLog(@" Connection cache fallback result!=nil");
		[[Model sharedInstance] setCachedData:result forType:response.dataid withRequestid:response.requestid];
		[self displayRequestFailedError:CONNECTIONERROR :CONNECTIONCACHE :OK];
		return YES;
	}
	
}



# pragma mark Deprecate
# pragma mark Model notification method

//
/***********************************************
 * Notification from model when data form server has been parsed and stored, cache this data to disk
 ***********************************************/
//
-(void)modelDidParseData:(NSNotification*)notification{
    
    BetterLog(@"");
	
	NSDictionary *userInfo=[notification userInfo];
	NetResponse *response=[userInfo objectForKey:@"response"];
	
	NSDictionary *service=[services objectForKey:response.dataid];
	if([[service objectForKey:@"cache"] boolValue]==YES){
		[self cacheRequestResult:response];
	}
}


//
/***********************************************
 * data caching
 ***********************************************/
//

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
-(BOOL)checkCachedDataExpiration:(NetRequest*)request{
	
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



-(void)cacheRequestResult:(NetResponse*)response{
	
	BetterLog(@" dataid=%@",response.dataid);
    
    BOOL shouldBeCached=response.serviceShouldBeCached;
    
	if (cacheCreated==YES && shouldBeCached==YES) {
	
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



-(NSMutableArray*)retrieveCachedDataForType:(NSString*)type andID:(NSString*)requestid{
	
	
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


//
/***********************************************
 * utilities
 ***********************************************/
//

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
	
	if(services!=nil){
		return [services objectForKey:type];
	}
	return nil;		
}

-(NSString*)cacheFilePathForType:(NSString*)type andID:(NSString*)requestid{
	
	return [[self cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@_cache.plist",type,requestid]]; 
	// should be file name type rather than plain type
	
}


-(NSString*)cachePath{
	
	if(diskCachePath==nil){
		NSArray* paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString* docsdir=[paths objectAtIndex:0];
		self.diskCachePath=[docsdir stringByAppendingPathComponent:kCACHEDIRECTORY];
	}
	
	return 	diskCachePath;
	
}


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

-(void)sendErrorNotification:(NSString*)error forResponse:(NetResponse*)response{
	
    response.errorType=NetResponseErrorConnection;
    
	[[NSNotificationCenter defaultCenter] postNotificationName:error object:response userInfo:nil];
	
}


-(void)didReceiveMemoryWarning:(NSNotification*)notification{
    
}


@end
