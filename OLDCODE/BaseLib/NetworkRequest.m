/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  NetworkRequest.m
//  Properties
//
//  Created by Alan Paxton on 10/02/2010.
//

#import "NetworkRequest.h"
#import "Common.h"
#import "CycleStreets.h"

@implementation NetworkRequest
@synthesize request;
@synthesize response;
@synthesize connection;
@synthesize data;
@synthesize target;
@synthesize tag;
@synthesize success;
@synthesize failure;

- (void)returnData:(NSData *)resultData {
	//tidy up
	self.data = nil;
	self.connection = nil;
	self.response = nil;
	self.request = nil;
	
	//return
	[self.target performSelector:self.success withObject:self withObject:resultData];	
}

- (id)initWithURL:(NSString *)urlString delegate:(NSObject *)resultTarget tag:(NSObject *)instanceTag onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod {
	if (self = [super init]) {
		self.target = resultTarget;
		self.tag = instanceTag;
		self.success = successMethod;
		self.failure = failureMethod;
		NSURL *url = [NSURL URLWithString:urlString];
		self.request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
		
		[request setValue:[CycleStreets sharedInstance].userAgent forHTTPHeaderField:@"User-Agent"];
		
		self.connection = nil;
		/*
		 This is now in start.
		NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
		if (cachedResponse == nil) {
			self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
			[self.connection release];
			[self.connection start];
		} else {
			[self returnData:cachedResponse.data];
		}
		 */
	}
	return self;
}

- (void)start {
	NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	if (cachedResponse == nil) {
		self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[self.connection release];
		[self.connection start];
	} else {
		[self returnData:cachedResponse.data];
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)rcvdResponse {
	self.response = rcvdResponse;
	self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)moreData {
	[self.data appendData:moreData];
}

// This is overridden when subclasses want contents (eg JSON), rather than raw data.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSData *resultData = self.data;
	
	//cache the result
	NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
	[[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];
	[cachedResponse release];
	
	[self returnData:resultData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.target performSelector:self.failure withObject:[error localizedDescription]];
}

- (void) cancel {
	[self.connection cancel];
	if (self.connection) {
		//need to tell the target that an error (caused by cancel) happened.
		[self.target performSelector:self.failure withObject:@"Request cancelled by user."];
	}
	self.connection = nil;
	self.request = nil;
}

- (NSString *) description {
	NSString *dataDesc = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSString *desc = [NSString stringWithFormat:@"%@\n%@",
					  [request description],
					  dataDesc];
	return desc;
}

- (void)dealloc {
	self.request = nil;
	self.response = nil;
	self.connection = nil;
	self.data = nil;
	self.target = nil;
	self.tag = nil;
	[super dealloc];
}

@end
