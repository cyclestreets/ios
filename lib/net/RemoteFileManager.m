//
//  RemoteFileManager.m
//  Racing uk
//
//  Created by Neil Edwards on 10/08/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "RemoteFileManager.h"
#import "GlobalUtilities.h"
#import "NetRequest.h"
#import "NSDictionary+UrlEncoding.h"
#import	"NetRequest.h"
#import "NetResponse.h"
#import "AppConstants.h"
#import "RequestQueueVO.h"

#define NSHTTPPropertyStatusCodeKey @"DB404Error"



@interface RemoteFileManager(Private) 

-(RequestQueueVO*)findRequestByType:(NSString*)type;
-(void)loadItemFromQueue;
-(void)load:(NetRequest*)request;
-(void)stopConnection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end






@implementation RemoteFileManager
SYNTHESIZE_SINGLETON_FOR_CLASS(RemoteFileManager);
@synthesize responseData;
@synthesize networkAvailable;
@synthesize myConnection;
@synthesize requestQueue;
@synthesize activeRequest;
@synthesize queueRequests;


/***********************************************************/
// dealloc
/***********************************************************/



-(id)init{
	
	if (self = [super init])
	{
		queueRequests=YES;
        NSMutableArray *arr=[[NSMutableArray alloc]init];
		self.requestQueue=arr;
		
	}
	return self;
	
	
}


//
/***********************************************
 * adds a unique datid type requst to the queue, if an existing one of this type is active, it is cancelled and replaced with the new one
 ***********************************************/
//
-(void)addRequestToQueue:(NetRequest*)request{
	
	if(queueRequests==YES){

		RequestQueueVO *result=[self findRequestByType:request.dataid];

		if(result.status==NO){
			
			request.status=QUEUED;
			[requestQueue addObject:request];
			
			if([requestQueue count]==1){
				[self loadItemFromQueue];
			}
			
		}else {
			[self removeRequestFromQueue:request.dataid andResume:NO];
			
			request.status=QUEUED;
			[requestQueue addObject:request];
			[self loadItemFromQueue];
			
		}
		
	}else {
		
		BetterLog(@"[DEBUG] pre load check for existing requests: [requestQueue count]=%i",[requestQueue count]);
		
		if([requestQueue count]==1){
			
			if(activeRequest.status==INPROGRESS){
				[myConnection cancel];
				myConnection=nil;
			}
			[requestQueue removeObjectAtIndex:0];
		}
		
		
		
		request.status=QUEUED;
		[requestQueue addObject:request];
		
		BetterLog(@"[DEBUG] post load check for existing requests: [requestQueue count]=%i",[requestQueue count]);
		
		[self loadItemFromQueue];
		
	}



}


//
/***********************************************
 * load next item in queue
 ***********************************************/
//
-(void)loadItemFromQueue{
	
	BetterLog(@"[requestQueue count]=%i",[requestQueue count]);
	
	if([requestQueue count]>0){
		
		activeRequest=[requestQueue objectAtIndex:0];
		activeRequest.status=INPROGRESS;
		[self load:activeRequest];
		
	}
	
	
}


// needs to support request queue

-(void)load:(NetRequest*)request{
	
		
	if(myConnection!=nil){
		[myConnection cancel];
	}
	
	NetResponse *response=[[NetResponse alloc]init];
	response.dataid=activeRequest.dataid;	
	response.requestid=activeRequest.requestid;
	response.requestType=activeRequest.requestType;
	response.dataType=activeRequest.dataType;
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:response,RESPONSE, nil];
	  // Keep and eye out here for potential leak issue
	[[NSNotificationCenter defaultCenter] postNotificationName:REMOTEDATAREQUESTED object:nil userInfo:dict];
	
	
	myConnection = [[NSURLConnection alloc] initWithRequest:[request requestForType]  delegate:self];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	if(myConnection){
		responseData=[NSMutableData data];
		[responseData setLength:0];
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	
	
	if ([response respondsToSelector:@selector(statusCode)])
		{
			int statusCode = [((NSHTTPURLResponse *)response) statusCode];
			if (statusCode >= 400)
			{
				
				BetterLog(@"didReceiveResponse: server.statusCode %i",statusCode);
				
				[myConnection cancel];  // stop connecting; no more delegate messages
				NSDictionary *errorInfo
				= [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
													  NSLocalizedString(@"Server returned status code %d",@""),
													  statusCode]
											  forKey:NSLocalizedDescriptionKey];
				NSError *statusError
				= [NSError errorWithDomain:NSHTTPPropertyStatusCodeKey
									  code:statusCode
								  userInfo:errorInfo];
				[self connection:myConnection didFailWithError:statusError];
			}
		}

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
	
    [responseData appendData:data];
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:@"RemoteFileManagerLoadedBytes",@"type",responseData,@"value",nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteFileManagerLoadedBytes" object:nil userInfo:dict];
	
}

//
/***********************************************
 * @description			Delegate method to return upload progress
 ***********************************************/
//
- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    
	if(activeRequest.trackProgress==YES){
		
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:totalBytesWritten],@"totalBytesWritten",
							[NSNumber numberWithInt:bytesWritten],@"bytesWritten",
							[NSNumber numberWithInt:totalBytesExpectedToWrite],@"totalBytesExpectedToWrite",
							nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:FILEUPLOADPROGRESS object:nil userInfo:dict];
	}
    
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	BetterLog(@"");
	
	networkAvailable=YES;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	
	NetResponse *response=[[NetResponse alloc]init];
	response.dataid=activeRequest.dataid;
	response.requestid=activeRequest.requestid;
	response.requestType=activeRequest.requestType;
	response.responseData=responseData;
	response.dataType=activeRequest.dataType;
	
	[self removeRequestFromQueue:activeRequest.dataid andResume:YES];
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:networkAvailable],@"networkStatus",response,@"response", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REMOTEFILELOADED object:nil userInfo:dict];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	
	BetterLog(@"RemoteFileManager.didFailWithError for dataid: %@ %@",activeRequest.dataid, [error localizedDescription] );
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	networkAvailable=NO;
	
	NetResponse *response=[[NetResponse alloc]init];
	response.dataid=activeRequest.dataid;
	response.requestid=activeRequest.requestid;
	response.requestType=activeRequest.requestType;
	response.dataType=activeRequest.dataType;
	response.responseData=nil;
	if(error.code>=400 || error.code==-1001){
		response.error=SERVERCONNECTIONFAILED;
	}else {
		response.error=REMOTEFILEFAILED;
	}

	
	[self removeRequestFromQueue:activeRequest.dataid andResume:YES];
	
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:networkAvailable],@"networkStatus",response,@"response", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:REMOTEFILEFAILED object:nil userInfo:dict];
	
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	//  NSLog(@"We are checking protection Space!");
    if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        BetterLog(@"NSURLAuthenticationMethodServerTrust");
        return YES;
    }
    else if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
		BetterLog(@"NSURLAuthenticationMethodHTTPBasic");
        return YES;
    }
    BetterLog(@"Cannot Auth!");
    return NO;
	
	
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
	
	if([challenge previousFailureCount]==0){
		
		if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		{
			BetterLog(@"NSURLAuthenticationMethodServerTrust requested");
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
			[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
			
		}
		else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
		{
			BetterLog(@"NSURLAuthenticationMethodHTTPBasic requested");
			
			NSString *username=[AppConstants authenticationForRequest:activeRequest.dataid ofType:AUTHENTICATION_USERNAME];
			NSString *password=[AppConstants authenticationForRequest:activeRequest.dataid ofType:AUTHENTICATION_PASSWORD];
			
			BetterLog(@"sending usename=%@ password=%@",username,password);
			
			NSURLCredential *newCredential=[NSURLCredential credentialWithUser:username
													 password:password
												  persistence:NSURLCredentialPersistencePermanent];
			[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
		}
		
	}else{
		BetterLog(@"cancelAuthenticationChallenge");
		[challenge.sender cancelAuthenticationChallenge:challenge];
	}
	
}



/*
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
	BetterLog(@"");
	
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
		
        newCredential=[NSURLCredential credentialWithUser:[AppConstants authenticationForRequest:activeRequest.dataid ofType:AUTHENTICATION_USERNAME]
                                                 password:[AppConstants authenticationForRequest:activeRequest.dataid ofType:AUTHENTICATION_PASSWORD]
                                              persistence:NSURLCredentialPersistencePermanent];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        
    }
}
*/

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
	return NO;
}

								
	
-(RequestQueueVO*)findRequestByType:(NSString*)type{
	
	RequestQueueVO *result=[[RequestQueueVO alloc]init];
	
	for(int i=0;i<[requestQueue count];i++){
		NetRequest *request=[requestQueue objectAtIndex:i];
		if ([request.dataid isEqualToString:type]) {
			result.request=request;
			result.index=i;
			result.status=YES;
			break;
		}
	}
	
	return result;
	
}
							


//
/***********************************************
 * remote queue item cancel method
 ***********************************************/
//
-(void)cancelRequest:(NSNotification*)notification{
	
	NSDictionary *dict=[notification userInfo];
	
	NSString *dataid=[dict objectForKey:DATATYPE];
	
	[self removeRequestFromQueue:dataid andResume:YES];
	
}


-(void)cancelAllRequests{
	
	[requestQueue removeAllObjects];
	[self stopConnection];
}


//
/***********************************************
 * removes and cancels item of type and resumes queue if required
 ***********************************************/
//
-(void)removeRequestFromQueue:(NSString*)type andResume:(BOOL)resume{
	
	RequestQueueVO *result=[self findRequestByType:type];
	
	if(result.status==YES){
		
		if(result.request.status==INPROGRESS){
			
			[self stopConnection];
			
		}
		
		[requestQueue removeObjectAtIndex:result.index];

	}
	
	if(resume==YES){
		[self loadItemFromQueue];
	}
		
}



-(void)stopConnection{
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[myConnection cancel];
	myConnection=nil;
	
}



@end
