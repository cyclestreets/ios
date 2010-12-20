//
//  XMLManager.m
//  RacingUK
//
//  Created by Neil Edwards on 24/11/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "DataSourceManager.h"
#import "RemoteFileManager.h"
#import "Model.h"
#import "UserSettingsManager.h"
#import "GlobalUtilities.h"
#import "StringUtilities.h"
#import "AppConstants.h"


// @ private
@interface DataSourceManager(Private) 

-(void)doDataConnectionRequest;
-(void)listNotificationInterests;
-(void)didReceiveNotification:(NSNotification*)notification;
-(NSString*)cachePath;
-(BOOL)createCacheDirectory;
-(void)didReceiveResponse:(NSData*)data forType:(NSString*)type;
-(void)didCompleteStartup;
// new variants with request id
-(void)cacheRequestResult:(NetResponse*)response;
-(BOOL)checkCachedDataExpiration:(NetRequest*)request;
-(void)loadCachedData:(NetRequest*)request;
-(NSMutableArray*)retrieveCachedDataForType:(NSString*)type andID:(NSString*)requestid;
-(NSString*)cacheFilePathForType:(NSString*)type andID:(NSString*)requestid;
-(void)processDataRequest:(NetRequest*)request;
-(void)sendErrorNotification:(NSString*)error dict:(NSDictionary*)dict;
-(void)displayRequestFailedError:(NSString*)title :(NSString*)message :(NSString*)buttonLabel;
-(void)removeStaleFiles;
-(BOOL)connectionCacheFallback:(NetResponse*)response;

// compatability mode
-(void)dataDidLoad:(NSNotification*)notification;
-(void)requestDidFail:(NSNotification*)notification;

@end





@implementation DataSourceManager
SYNTHESIZE_SINGLETON_FOR_CLASS(DataSourceManager);
@synthesize services;
@synthesize requestURL;
@synthesize dataPriority;
@synthesize DATASOURCE;
@synthesize startupState;
@synthesize delegate;
@synthesize cacheCreated;
@synthesize notifications;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [services release], services = nil;
    [requestURL release], requestURL = nil;
    [dataPriority release], dataPriority = nil;
    [DATASOURCE release], DATASOURCE = nil;
    delegate = nil;
    [notifications release], notifications = nil;
	
    [super dealloc];
}



/***********************************************************/
//  dataPriority 
/***********************************************************/
- (NSString *)dataPriority
{
    return [[dataPriority retain] autorelease]; 
}
- (void)setDataPriority:(NSString *)aDataPriority
{
    if (dataPriority != aDataPriority) {
        [dataPriority release];
        dataPriority = [aDataPriority copy];
    }
}



//
/***********************************************
 * Notifications
 ***********************************************/
//

-(id)init{
	
	if (self = [super init])
	{
		if(dataPriority==nil){
			dataPriority=kDATAPRIORITY;
		}
		
		DATASOURCE=REMOTEDATA;
				
		[self listNotificationInterests];
		
		cacheCreated=[self createCacheDirectory];
		
		[self removeStaleFiles];
		
	}
	return self;
	
}


-(void)listNotificationInterests{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	notifications=[[NSMutableDictionary alloc] initWithObjectsAndKeys:
				   [NSValue valueWithPointer:@selector(dataDidLoad:)],REMOTEFILELOADED,
				   [NSValue valueWithPointer:@selector(modelDidParseData:)],REQUESTDIDCOMPLETEFROMSERVER,
				   [NSValue valueWithPointer:@selector(requestDataForType:)],REQUESTDATAREFRESH,
				   [NSValue valueWithPointer:@selector(requestDidFail:)],REMOTEFILEFAILED,
				   [NSValue valueWithPointer:@selector(requestDidFail:)],XMLPARSERDIDFAILPARSING,nil];
	
	for( NSString* notification in notifications){
		
		SEL sel=[[notifications objectForKey:notification] pointerValue];
		
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:sel
		 name:notification
		 object:nil ] ;
		
	}
	
}


-(void)didReceiveNotification:(NSNotification*)notification{
	
	NSString *name=[notification name];
	
	if([notifications objectForKey:name]!=nil){
		SEL sel=[[notifications objectForKey:name] pointerValue];
		[self performSelector:sel withObject:notification];
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


-(void)requestDataForType:(NSNotification*)notification{
	
	[self processDataRequest:[[notification userInfo] objectForKey:@"request"]];
}



-(void)processDataRequest:(NetRequest*)request{
	
	if([request.source isEqualToString:SYSTEM]){
		if([[Model sharedInstance] RequestIsExistingRequest:request.dataid withRequestid:request.requestid]==YES){
			return;
		}
	}
	
	NSDictionary *service=[services objectForKey:request.dataid];
	
	if(service!=nil){
		BetterLog(@" [DEBUG] requestDataForType found service for %@",request.dataid);
		request.service=service;
		
	}else {
		BetterLog(@"[ERROR] Invalid service/dataid : %@",request.dataid);
		[self sendErrorNotification:DATAREQUESTFAILED dict:nil];
		return;
	}
	
	
	BetterLog(@"[DEBUG] cacheCreated=%i",cacheCreated);
	
	if(cacheCreated==YES){
		
		BetterLog(@"[DEBUG] request.source=%@",request.source);
		
		if([request.source isEqualToString:SYSTEM]){
			
			
			
			// SYSTEM initiated request go through the model>cache>remote checking chain
			if(![[Model sharedInstance] loadCachedDataForType:request.dataid withRequestid:request.requestid]){
				
				BetterLog(@"[DEBUG] Model did not find dataid: %@ & requestid: %@",request.dataid,request.requestid);
				
				[self loadCachedData:request];
			
			}else {
				BetterLog(@"[DEBUG] Model found dataid & requestid");
			}
			
		}else {
			
			BetterLog(@"[DEBUG] Request is USER type, contacting server with %@",request.dataid);
			
			// USER initiated request always contacts the server.
			[[RemoteFileManager sharedInstance] addRequestToQueue:request];
			
		}
		
		
	}else {
		
		BetterLog(@"[ERROR] Cache Directory doesnot exist: Executing with Remote data load for %@ with %@",request.dataid,request.requestid);
		
		[[RemoteFileManager sharedInstance] addRequestToQueue:request];
	}

	
}
	

-(void)loadCachedData:(NetRequest*)request{
	
	if([self checkCachedDataExpiration:request]){
		
		BetterLog(@"[DEBUG] cache file found and non-expired for %@ and %@",request.dataid,request.requestid);
		
		NSMutableArray *result=[self retrieveCachedDataForType:request.dataid andID:request.requestid];
		
		if(result!=nil){
			[[Model sharedInstance] setCachedData:result forType:request.dataid withRequestid:request.requestid];
		}else {
			BetterLog(@"[ERROR] Unable to de-archive cache file: Falling back to Remote file load");
			[[RemoteFileManager sharedInstance] addRequestToQueue:request];
		}
		
		
	}else {
		
		BetterLog(@"[DEBUG] cached data file either not found or expired: Loading data from server");
		BetterLog(@"[DEBUG] requestid=%@",request.requestid);
		[[RemoteFileManager sharedInstance] addRequestToQueue:request];
		
	}
	
	
}



-(void)didCompleteStartup{
	
	if([delegate respondsToSelector:@selector(DataSourceDidCompleteStartup)]){
		[delegate DataSourceDidCompleteStartup];
	}
	
	startupState=NO;

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
		
		if([self connectionCacheFallback:response]==NO){
			
			[self displayRequestFailedError:CONNECTIONERROR :UNABLETOCONTACT :OK];
		
			[self sendErrorNotification:CONNECTIONERROR dict:[notification userInfo]];
		}
		
	}else if ([name isEqualToString:XMLPARSERDIDFAILPARSING]) {
		
		NSDictionary *userInfo=[notification userInfo];
		NetResponse *response=[userInfo objectForKey:@"response"];
		
		BetterLog(@" XML Error: %@",response.error);
		
		if([response.error isEqualToString:XMLPARSER_RESPONSENOENTRIES]){
			
			[[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDIDCOMPLETENOENTRIES object:nil userInfo:userInfo];
			
		}else {
			[self displayRequestFailedError:XMLPARSERERROR :INVALIDRESPONSE :OK];
			[self sendErrorNotification:DATAREQUESTFAILED dict:userInfo];
		}
		
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




# pragma Model notification method

//
/***********************************************
 * Notification from model when data form server has been parsed and stored, cache this data to disk
 ***********************************************/
//
-(void)modelDidParseData:(NSNotification*)notification{
	
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
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
	cacheinterval=cacheinterval*60; // convert to mins
	
	//BetterLog(@" fileage=%f  cacheinterval=%i",fileage,cacheinterval);
	
	if([fm fileExistsAtPath:filepath]){
		
		BOOL noRefresh=[[request.service objectForKey:@"neverRefresh"] boolValue];
		
		if(noRefresh==YES){
			BetterLog(@"[DEBUG] service.noRefresh: ignoring cache interval and loading from cache");
			return YES;
		}else {
			
			if (fileage<cacheinterval) {
				return YES;
			}else {
				//NSLog(@"[DEBUG] Cached File expired, deleteing...");
				[fm removeItemAtPath:filepath error:nil];
				return NO;
			}
			
		}

		
	}
	
	return NO;
}



-(void)cacheRequestResult:(NetResponse*)response{
	
	//BetterLog(@" dataid=%@",response.dataid);
	
	if (cacheCreated==YES) {
	
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:response.dataProvider forKey:kCACHEARCHIVEKEY];
		[archiver finishEncoding];
		[data writeToFile:[self cacheFilePathForType:response.dataid andID:response.requestid] atomically:YES];
		
		[data release];
		[archiver release];
		
	}

}



-(NSMutableArray*)retrieveCachedDataForType:(NSString*)type andID:(NSString*)requestid{
	
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSMutableArray *dataProvider=nil;
	
	if ([fm fileExistsAtPath:[self cacheFilePathForType:type andID:requestid]]) {
		
		//NSLog(@"[DEBUG] DataSourceManager.retrieveCachedDataForType type=%@",type);
		
		NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self cacheFilePathForType:type andID:requestid]];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		dataProvider = [unarchiver decodeObjectForKey:kCACHEARCHIVEKEY];
		[unarchiver finishDecoding];
		[unarchiver release];
		[data release];
		
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


//
/***********************************************
 * utilities
 ***********************************************/
//


-(NSDictionary*)getServiceForType:(NSString*)type{
	
	if(services!=nil){
		return [services objectForKey:type];
	}
	return nil;		
}

-(NSString*)cacheFilePathForType:(NSString*)type andID:(NSString*)requestid{
	
	return [[self cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@_cache.plist",type,requestid]]; // should be file name type rather than plain type
	
}


-(NSString*)cachePath{
	
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* docsdir=[paths objectAtIndex:0];
	return [docsdir stringByAppendingPathComponent:kCACHEDIRECTORY];	
	
}


-(void)displayRequestFailedError:(NSString*)title :(NSString*)message :(NSString*)buttonLabel{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:buttonLabel otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
	
}


-(void)sendErrorNotification:(NSString*)error dict:(NSDictionary*)dict{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:error object:nil userInfo:dict];
	
}


@end
