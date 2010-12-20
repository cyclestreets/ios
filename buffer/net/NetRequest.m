//
//  Request.m
//  RacingUK
//
//  Created by Neil Edwards on 10/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "NetRequest.h"
#import "AppConstants.h"
#import "NSDictionary+UrlEncoding.h"
#import "StringUtilities.h"
#import "DataSourceManager.h"
#import "GlobalUtilities.h"

@implementation NetRequest
@synthesize service;
@synthesize dataid;
@synthesize url;
@synthesize status;
@synthesize parameters;
@synthesize requestType;
@synthesize requestid;
@synthesize revisonId;
@synthesize source;


/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [service release], service = nil;
    [dataid release], dataid = nil;
    [url release], url = nil;
    [parameters release], parameters = nil;
    [requestType release], requestType = nil;
    [requestid release], requestid = nil;
    [source release], source = nil;
	
    [super dealloc];
}



- (id)init {
	
	if (self = [super init]) {
		
		source=SYSTEM; 
		
	}
    return self;
}










-(NSMutableURLRequest*)requestForType{
	
	NSURL *requesturl;
	NSMutableURLRequest *request=nil;
	NSString *servicetype=[service objectForKey:@"type"];
	
	if ([servicetype isEqualToString:URL]) {
		
		NSString *urlString=[StringUtilities urlFromParameterArray:[parameters objectForKey:@"parameterarray"] url:[self url]];
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										timeoutInterval:30.0 ];
		
		BetterLog(@"url type url: %@",urlString);
		
	}else if([servicetype isEqualToString:POST]){
		
		// support controller/method parameters
		if([service objectForKey:@"controller"]!=nil)
			[parameters setValue:[service objectForKey:@"controller"] forKey:@"c"];
		if([service objectForKey:@"method"]!=nil)
			[parameters setValue:[service objectForKey:@"method"] forKey:@"m"];
		
		requesturl=[NSURL URLWithString:[self url]];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		/*
		NSLog(@"[DEBUG] POST SEND:");
		for(NSString *key in parameters){
			NSLog(@"[DEBUG] %@=%@",key,[parameters objectForKey:key]);
		}
		 */
		
		NSString *parameterString=[parameters urlEncodedString];
		NSString *msgLength = [NSString stringWithFormat:@"%d", [parameterString length]];
		[request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody: [parameterString dataUsingEncoding:NSUTF8StringEncoding]];
		
		
		
		
	}else if ([servicetype isEqualToString:GET]) {
		
		
		 NSLog(@"[DEBUG] GET SEND:");
		 for(NSString *key in parameters){
			 NSLog(@"[DEBUG] %@=%@",key,[parameters objectForKey:key]);
		 }
		 
		
		// support controller/method parameters
		if([service objectForKey:@"controller"]!=nil)
			[parameters setValue:[service objectForKey:@"controller"] forKey:@"c"];
		if([service objectForKey:@"method"]!=nil)
			[parameters setValue:[service objectForKey:@"method"] forKey:@"m"];
		
		NSString *urlString=[[NSString alloc]initWithFormat:@"%@?%@",[self url],[parameters urlEncodedString]];
		
		BetterLog(@"GET urlString: %@",urlString);
		
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		[urlString release];
	}
	
	

	return request;
	
}



-(NSMutableString*)url{
	
	NSMutableString *str=nil;
	
	if([[DataSourceManager sharedInstance].DATASOURCE isEqualToString:REMOTEDATA]){
		str=[NSMutableString stringWithString:[service objectForKey:@"remoteurl"]];
	}else {
		str=[NSMutableString stringWithString:[service objectForKey:@"localurl"]];
	}
	return str;
}


@end
