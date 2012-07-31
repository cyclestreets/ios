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

//  Categories.m
//  CycleStreets
//
//  Created by Alan Paxton on 28/07/2010.
//

#import "Categories.h"
#import "XMLRequest.h"
#import "CycleStreets.h"

static NSString *format = @"%@?key=%@";
static NSString *urlPrefix = @"http://www.cyclestreets.net/api/photomapcategories.xml";

@implementation Categories

- (id) init {
	if (self = [super init]) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		
		NSString *newURL = [NSString
							stringWithFormat:format,
							urlPrefix,
							[cycleStreets APIKey]];
		url = newURL;
	}
	return self;	
}

+ (NSString *)example {
	return @"http://www.cyclestreets.net/api/photomapcategories.xml?key=yourapikey";
}

- (void) runWithTarget:(NSObject *)resultTarget onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod {
	request = [[XMLRequest alloc] initWithURL:url delegate:(NSObject *)resultTarget tag:nil onSuccess:(SEL)successMethod onFailure:(SEL)failureMethod];
	//request.elementsToParse = [NSArray arrayWithObjects:@"tag", @"name", nil];
	//request.elementCategories = [NSArray arrayWithObjects:@"categories", @"metacategories", nil];
	request.elementsToParse = [NSArray arrayWithObjects:@"validuntil", @"category", @"metacategory", nil];
	[request.request addValue:@"gzip" forHTTPHeaderField:@"Accepts-Encoding"];
	[request start];
}


@end
