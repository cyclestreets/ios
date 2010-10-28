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

//  NamedPlace.m
//  CycleStreets
//
//  Created by Alan Paxton on 10/05/2010.
//

#import "NamedPlace.h"


@implementation NamedPlace

@synthesize locationCoords;
@synthesize name;

- (id)initWithDictionary:(NSDictionary *)fields {
	if (self = [super init]) {
		locationCoords.latitude = [[fields objectForKey:@"latitude"] doubleValue];
		locationCoords.longitude = [[fields objectForKey:@"longitude"] doubleValue];
		self.name = [NSString stringWithFormat:@"%@, %@", [fields objectForKey:@"name"], [fields objectForKey:@"near"]];
	}
	return self;
}

- (void)dealloc {
	[name release];
	
	[super dealloc];
}

@end
