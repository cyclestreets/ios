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

//  XMLRequest.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//


#import "XMLRequest.h"
#import "RouteParser.h"
#import "Route.h"
#import "CycleStreets.h"

@implementation XMLRequest

@synthesize elementsToParse;
@synthesize elementCategories;

// The override to return JSONified contents, rather than raw data.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// Log the data.
	//NSString *string = [NSString stringWithUTF8String:[data bytes]];
	//NSLog(@"XML %@", string);
	
	// Parse the elements we need for a route out of the XML
	RouteParser *route = [RouteParser parse:data forElements:elementsToParse withCategories:elementCategories];
	if (!route.error) {
		NSDictionary *result = route.categorisedElementLists;
		if ([result count] == 0) {
			result = route.elementLists;
		}
		[self.target performSelector:self.success withObject:self withObject:result];
	} else {
		[self.target performSelector:self.failure withObject:self withObject:[route.error localizedDescription]];
	}
	
	//tidy up
	self.data = nil;
	self.connection = nil;
}

- (NSString *) description {
	return [super description];
}

- (void)dealloc {
	self.elementsToParse = nil;
	self.elementCategories = nil;
	[super dealloc];
}

@end
