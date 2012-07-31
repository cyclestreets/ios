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

//  PhotoList.m
//  CycleStreets
//
//  Created by Alan Paxton on 03/05/2010.
//

#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"

static NSString *PHOTO_ELEMENT = @"cs:photo";

@implementation PhotoMapListVO

@synthesize photos;

- (id) initWithElements:(NSDictionary *)elements {
	if (self = [super init]) {
		photos = [[NSMutableArray alloc] init];
		for (NSDictionary *photoDictionary in [elements objectForKey:PHOTO_ELEMENT]) {
			PhotoMapVO *photo = [[PhotoMapVO alloc] initWithDictionary:photoDictionary];
			[photos addObject:photo];
		}
	}
	return self;
}

+ (NSArray *) photoListXMLElementNames {
	return [[NSArray alloc] initWithObjects:PHOTO_ELEMENT, nil];
}


@end
