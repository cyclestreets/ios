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
#import "CJSONSerializer.h"
#import "CycleStreets.h"

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
@synthesize dataType;

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
	
	NSURL *requesturl=nil;
	NSMutableURLRequest *request=nil;
	NSString *servicetype=[service objectForKey:@"type"];
	
	self.dataType=[AppConstants parserStringTypeToConstant:[service objectForKey:@"parserType"]];
	
	if ([servicetype isEqualToString:URL]) {
		
		NSString *urlString=[StringUtilities urlFromParameterArray:[parameters objectForKey:@"parameterarray"] url:[self url]];
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										timeoutInterval:30.0 ];
		
		BetterLog(@"url type url: %@",urlString);
		
	}else if([servicetype isEqualToString:POST]){
		
		requesturl=[NSURL URLWithString:[self url]];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		
		for(NSString *key in parameters){
			//NSLog(@"[DEBUG] %@=%@",key,[parameters objectForKey:key]);
		}
		 
		//NSLog(@"[DEBUG] POST SEND:%@",[parameters urlEncodedString]);
		
		NSString *parameterString=[parameters urlEncodedString];
		NSString *msgLength = [NSString stringWithFormat:@"%d", [parameterString length]];
		[request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody: [parameterString dataUsingEncoding:NSUTF8StringEncoding]];
		
		[request setValue:[CycleStreets sharedInstance].userAgent forHTTPHeaderField:@"User-Agent"];
		
		
	}else if ([servicetype isEqualToString:GET]) {
		
		NSString *urlString=[[NSString alloc]initWithFormat:@"%@?%@",[self url],[parameters urlEncodedString]];
		
		BetterLog(@"GET url=%@",urlString);
		
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		
		[request setValue:[CycleStreets sharedInstance].userAgent forHTTPHeaderField:@"User-Agent"];
		
		[urlString release];
	}else if([servicetype isEqualToString:POSTJSON]){
		
		requesturl=[NSURL URLWithString:[self url]];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		
		NSString *parameterString=[[CJSONSerializer serializer] serializeDictionary:parameters];
		
		//NSLog(@"[DEBUG] JSONPOST SEND:%@",parameterString);
		
		NSString *msgLength = [NSString stringWithFormat:@"%d", [parameterString length]];
		[request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody: [parameterString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setValue:[CycleStreets sharedInstance].userAgent forHTTPHeaderField:@"User-Agent"];
		
		
	}else if([servicetype isEqualToString:GETPOST]){
		
		NSDictionary *getparameters=[parameters objectForKey:@"getparameters"];
		NSDictionary *postparameters=[parameters objectForKey:@"postparameters"];
		
		NSString *urlString=[[NSString alloc]initWithFormat:@"%@?%@",[self url],[getparameters urlEncodedString]];
		requesturl=[NSURL URLWithString:urlString];
		
		request = [NSMutableURLRequest requestWithURL:requesturl
										  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									  timeoutInterval:30.0 ];
		
		//NSLog(@"[DEBUG] GETPOST SEND url:%@",urlString);
		[urlString release];
		//NSLog(@"[DEBUG] GETPOST SEND body:%@",[postparameters urlEncodedString]);
		
		NSString *parameterString=[postparameters urlEncodedString];
		
		[request setHTTPMethod:@"POST"];
		NSString *msgLength = [NSString stringWithFormat:@"%d", [parameterString length]];
		[request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
		NSString *contentType = [NSString stringWithString:@"application/x-www-form-urlencoded"];
		[request addValue:contentType forHTTPHeaderField: @"Content-Type"];	
		[request setHTTPBody: [parameterString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setValue:[CycleStreets sharedInstance].userAgent forHTTPHeaderField:@"User-Agent"];
	
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
