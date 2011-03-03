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

//  UserValidate.m
//  CycleStreets
//
//  Created by Alan Paxton on 26/05/2010.
//

#import "UserValidate.h"
#import "XMLRequest.h"
#import "CycleStreets.h"

static NSString *format = @"%@?key=%@";

static NSString *urlPrefix = @"https://www.cyclestreets.net/api/uservalidate.xml";

static NSString *bodyFormat = @"username=%@&password=%@";

@implementation UserValidate

- (id) initWithUsername:(NSString *)username withPassword:(NSString *)password {
	if (self = [super init]) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		
		NSString *newURL = [NSString
							stringWithFormat:format,
							urlPrefix,
							[cycleStreets APIKey]];
		url = newURL;
		[url retain];
				
		NSString *bodyString = [NSString
								stringWithFormat:bodyFormat,
								username,
								password];
		body = [NSData dataWithBytes:[bodyString UTF8String] length:[bodyString length]];
		[body retain];
		request = nil;
	}
	return self;
}

+ (NSString *) example {
	return @"http://www.cyclestreets.net/api/uservalidate.xml?key=yourapikey";
}

- (void) runWithTarget:(NSObject *)resultTarget onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod {
	[request release];
	request = [[XMLRequest alloc] initWithURL:url delegate:(NSObject *)resultTarget tag:nil onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod];
	request.elementsToParse = [NSArray arrayWithObject:@"signin"];
	[request.request setHTTPMethod:@"POST"];
	NSString *contentType = [NSString stringWithString:@"application/x-www-form-urlencoded"];
	[request.request addValue:contentType forHTTPHeaderField: @"Content-Type"];	
	[request.request addValue:@"gzip" forHTTPHeaderField:@"Accepts-Encoding"];
	[request.request setHTTPBody:body];
	[request start];
}

- (NSString *)description {
	NSString *copy = [url copy];
	[copy release];
	return copy;
}

- (void) dealloc {
	[url release];
	url = nil;
	[body release];
	body = nil;
	[request release];
	request = nil;
	
	[super dealloc];
}

@end
