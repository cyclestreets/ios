//
//  ConnectionValidator.m
//  RacingUK
//
//  Created by Neil Edwards on 18/07/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "ConnectionValidator.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "GlobalUtilities.h"
#import "AppConstants.h"

@implementation ConnectionValidator

SYNTHESIZE_SINGLETON_FOR_CLASS(ConnectionValidator);
@synthesize networkAvailable;
@synthesize myConnection;
@synthesize delegate;


- (void) dealloc{
	
	delegate=nil;
	RELEASE_SAFELY(myConnection);
    [super dealloc];
}

-(void)isDataSourceAvailable{
	
	BetterLog(@"");
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "www.google.com");
	SCNetworkReachabilityFlags flags;
	BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
	BOOL result = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
	
	if(result==YES){
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:result],@"networkStatus",@"type",@"ConnectionReachabilityPassed",nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:CONNECTIONVALIDATION object:nil userInfo:dict];
		[dict release];
	}else{
		
		NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:result],@"networkStatus",@"type",@"ConnectionReachabilityFailed",nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:CONNECTIONVALIDATION object:nil userInfo:dict];
		[dict release];
	}
	
	
	
}

-(void)isNetworkAvailable{
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:30.0 ];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	if(myConnection!=nil){
		[myConnection cancel];
		RELEASE_SAFELY(myConnection);
	}
		
	myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(myConnection){
		
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	BetterLog(@"");
	
	networkAvailable=YES;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self isDataSourceAvailable];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	
	BetterLog(@"");
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	networkAvailable=NO;
	NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:networkAvailable],@"networkStatus",@"type",@"ConnectionDidFail",nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:CONNECTIONVALIDATION object:nil userInfo:dict];
	[dict release];
	
}




@end
