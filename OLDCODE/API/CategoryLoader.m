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

//  CategoryLoader.m
//  CycleStreets
//
//  Created by Alan Paxton on 04/08/2010.
//

#import "CategoryLoader.h"
#import "Categories.h"
#import "GlobalUtilities.h"
#import "CycleStreets.h"
#import "Files.h"

@implementation CategoryLoader

@synthesize categories;
@synthesize categoryLabels;
@synthesize metaCategories;
@synthesize metaCategoryLabels;

@synthesize categoriesAPIMethod;

- (NSArray *)entries:(NSArray *)array named:(NSString *)name {
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	for (NSDictionary *dict in array) {
		NSString *value = [dict objectForKey:name];
		if (value != nil) {
			[result addObject:value];
		}
	}
	return result;
}

- (BOOL) loadCategories:(NSDictionary *)elements {
	BetterLog(@"loadCategories");
	NSArray *cats = [self entries:[elements objectForKey:@"category"] named:@"tag"];
	NSArray *catLabels = [self entries:[elements objectForKey:@"category"] named:@"name"];
	NSArray *metas = [self entries:[elements objectForKey:@"metacategory"] named:@"tag"];
	NSArray *metaLabels = [self entries:[elements objectForKey:@"metacategory"] named:@"name"];
	if ([cats count] > 0 && [cats count] == [catLabels count] &&
		[metas count] > 0 && [metas count] == [metaLabels count])
	{
		//sanity checked OK. Save.
		self.categories = cats;
		self.categoryLabels = catLabels;
		self.metaCategories = metas;
		self.metaCategoryLabels = metaLabels;
		
		return YES;
	}
	return NO;
}

- (void) didSucceedFetch:(XMLRequest *)xmlRequest results:(NSDictionary *)elements {
	BetterLog(@"didSucceedFetch");
	if ([self loadCategories:elements]) {
		//save 'em.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		[cycleStreets.files setPhotoCategories:elements];
		NSString *validuntil = [[[elements objectForKey:@"validuntil"] objectAtIndex:0] valueForKey:@"validuntil"];
		[cycleStreets.files setMiscValue:validuntil forKey:@"validuntil"];
	}
}

- (void) didFailFetch:(XMLRequest *)xmlRequest message:(NSString *)message {
	BetterLog(@"didFailFetch");
}

- (void) fetchCategories {
	if (self.categoriesAPIMethod == nil) {
		self.categoriesAPIMethod = [[[Categories alloc] init] autorelease];
	}
	[self.categoriesAPIMethod runWithTarget:self
								  onSuccess:@selector(didSucceedFetch:results:)
								  onFailure:@selector(didFailFetch:message:)];
}

+ (NSString *)defaultCategory {
	return @"general";
}

+ (NSString *)defaultMetaCategory {
	return @"any";
}

- (void)setupCategories {
	//first, use the "bitter end" defaults.
	self.categories = [NSArray arrayWithObject:[CategoryLoader defaultCategory]];
	self.categoryLabels = [NSArray arrayWithObject:@"Other"];
	self.metaCategories = [NSArray arrayWithObject:[CategoryLoader defaultMetaCategory]];
	self.metaCategoryLabels = [NSArray arrayWithObject:@"Any"];
	
	//second, load the last save from file.
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSDictionary *categoryElements = [cycleStreets.files photoCategories];
	[self loadCategories:categoryElements];
	
	//third, fetch from the server.
	NSString *validuntil = [cycleStreets.files miscValueForKey:@"validuntil"];
	BOOL expired = NO;
	if (validuntil == nil || [validuntil length] == 0) {
		expired = YES;
	}
	if (!expired) {
		NSDate *expiry = [[[NSDate alloc] initWithTimeIntervalSince1970:[validuntil doubleValue]] autorelease];
		NSDate *now = [[[NSDate alloc] init] autorelease];
		if ([now compare:expiry] != NSOrderedAscending) {
			expired = YES;
		}
	}
	if (expired) {
		[self fetchCategories];
	}
}

@end
