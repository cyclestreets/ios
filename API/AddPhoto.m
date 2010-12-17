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

//  AddPhoto.m
//  CycleStreets
//
//  Created by Alan Paxton on 31/05/2010.
//

#import "AddPhoto.h"
#import "XMLRequest.h"
#import "CycleStreets.h"
#import "Common.h"

static NSString *format = @"%@?key=%@";
static NSString *urlPrefix = @"https://www.cyclestreets.net/api/addphoto.xml";

@implementation AddPhoto

@synthesize longitude;
@synthesize latitude;
@synthesize privacy;
@synthesize time;
@synthesize caption;
@synthesize category;
@synthesize metaCategory;

@synthesize imageData;

- (id) initWithUsername:(NSString *)newUsername withPassword:(NSString *)newPassword {
	if (self = [super init]) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		
		NSString *newURL = [NSString
							stringWithFormat:format,
							urlPrefix,
							[cycleStreets APIKey]];
		[url release];
		url = newURL;
		[url retain];
			
		username = [newUsername copy];
		password = [newPassword copy];
	}
	return self;
}

- (void) content:(NSMutableData *)data withName:(NSString *)name withValue:(NSString *)value {
	
	NSString *stringBoundary = [NSString stringWithString:@"0xBoundaryBoundaryBoundaryBoundary"];
	if (value == nil) {
		value = @"";
	}
	[data appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *line = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name];
	[data appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
#ifdef DEBUG
	NSLog(@"\r\n--%@\r\n", stringBoundary);
	NSLog(@"%@", line);
	NSLog(@"%@", value);
#endif
}

- (void) runWithTarget:(NSObject *)resultTarget onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod {
	
	body = [[NSMutableData alloc] init];	
	
	[request release];
	request = [[XMLRequest alloc] initWithURL:url delegate:(NSObject *)resultTarget tag:nil onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod];
	request.elementsToParse = [NSArray arrayWithObject:@"result"]; //we'll check for the URL.	
	NSMutableURLRequest *r = request.request;
	
	[r addValue:@"gzip" forHTTPHeaderField:@"Accepts-Encoding"];
	[r setHTTPMethod:@"POST"];
	NSString *stringBoundary = [NSString stringWithString:@"0xBoundaryBoundaryBoundaryBoundary"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[r addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"mediaupload\"; filename=\"from_iphone.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:imageData];	
	
	//Commented out all those we think are not required, and in fact better left to the server to set defaults.
	[self content:body withName:@"username" withValue:username];
	[self content:body withName:@"password" withValue:password];
	[self content:body withName:@"latitude" withValue:latitude];
	[self content:body withName:@"longitude" withValue:longitude];
	//[self content:body withName:@"privacy" withValue:@"Public"];
	[self content:body withName:@"caption" withValue:caption];
	[self content:body withName:@"metacategory" withValue:metaCategory];
	[self content:body withName:@"category" withValue:category];
	//[self content:body withName:@"zoom" withValue:@"16"];
	//[self content:body withName:@"elevation" withValue:@"2"];
	//[self content:body withName:@"proximity" withValue:@"Medium"];
	//[self content:body withName:@"azimuth" withValue:@"horizontal"];
	[self content:body withName:@"datetime" withValue:time];
	//[self content:body withName:@"bearing" withValue:@"270"];
	//[self content:body withName:@"feature" withValue:@"3"];
	//[self content:body withName:@"masterLocationId" withValue:@""];
	//[self content:body withName:@"basemap" withValue:@"Open Cycle Map"];
	
#ifdef DEBUG
	NSLog(@"%@", url);
#endif
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[r setHTTPBody:body];
	[request start];	
}

- (NSString *)description {
	NSString *copy = [url copy];
	[copy release];
	return copy;
}

- (void) dealloc {
	[url release];
	[body release];
	[request release];
	
	[username release];
	[password release];
	
	self.longitude = nil;
	self.latitude = nil;
	self.privacy = nil;
	self.time = nil;
	self.imageData = nil;
	self.caption = nil;
	self.category = nil;
	self.metaCategory = nil;
	
	[super dealloc];
}

@end
