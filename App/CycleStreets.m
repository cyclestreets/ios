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

//  CycleStreets.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "CycleStreets.h"
#import "Files.h"
#import "CategoryLoader.h"

@implementation CycleStreets

@synthesize appDelegate;
@synthesize files;
@synthesize categoryLoader;
@synthesize APIKey;

- (id) init {
	if (self = [super init]) {
		self.files = [[[Files alloc] init] autorelease];
		self.categoryLoader = [[[CategoryLoader alloc] init] autorelease];
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *APIFile = [mainBundle pathForResource:@"APIKey" ofType:@"txt"];
		NSString *keyFromFile = [NSString stringWithContentsOfFile:APIFile encoding:NSUTF8StringEncoding error:NULL];
		APIKey = [[[keyFromFile stringByReplacingOccurrencesOfString:@"\n" withString:@""] copy] retain];
	}
	return self;
}

- (void)dealloc {
	self.appDelegate = nil;
	self.files = nil;
	self.categoryLoader = nil;
	[APIKey release];
	APIKey = nil;
	
	[super dealloc];
}

@end
