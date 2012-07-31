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

//  PhotoEntry.m
//  CycleStreets
//
//  Created by Alan Paxton on 03/05/2010.
//

#import "PhotoMapVO.h"

@implementation PhotoMapVO

static int MIN_SIZE = 80;
static int BIG_SIZE = 300;

@synthesize locationCoords;
@synthesize csid;
@synthesize caption;
@synthesize bigImageURL;
@synthesize smallImageURL;


// Optimize small URL for smallest thumbnail available which is big enough.
- (void) generateSmallImageURL:(NSString *)sizes {
	//default to the known big one.
	self.smallImageURL = self.bigImageURL;
	
	//try and find a known smaller one
	int bestSize = 0;
	for (NSString *size in [sizes componentsSeparatedByString:@"|"]) {
		int newSize = [size intValue];
		if (newSize >= MIN_SIZE) {
			if (bestSize == 0) {
				bestSize = newSize;
			}
			if (newSize < bestSize) {
				bestSize = newSize;
			}
		}
	}
	
	//we got one. Fix up the URL.
	if (bestSize > 0) {
		NSString *from = [[NSNumber numberWithInt:BIG_SIZE] stringValue];
		NSString *to = [[NSNumber numberWithInt:bestSize] stringValue];
		self.smallImageURL = [self.bigImageURL stringByReplacingOccurrencesOfString:from withString:to];
	}
}

- (id)initWithDictionary:(NSDictionary *)fields {
	if (self = [super init]) {
		locationCoords.latitude = [[fields objectForKey:@"cs:latitude"] doubleValue];
		locationCoords.longitude = [[fields objectForKey:@"cs:longitude"] doubleValue];
		csid = [[fields objectForKey:@"cs:id"] copy];
		caption = [[fields objectForKey:@"cs:caption"] copy];
		self.bigImageURL = [fields objectForKey:@"cs:thumbnailUrl"];
		[self generateSmallImageURL:[fields objectForKey:@"cs:thumbnailSizes"]];
	}
	return self;
}

- (CLLocationCoordinate2D)location {
	return locationCoords;
}




@end
