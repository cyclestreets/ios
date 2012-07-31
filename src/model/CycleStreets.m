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
#import "PhotoCategoryManager.h"
#import "SynthesizeSingleton.h"

@implementation CycleStreets
SYNTHESIZE_SINGLETON_FOR_CLASS(CycleStreets);
@synthesize appDelegate;
@synthesize files;
@synthesize APIKey;
@synthesize userAgent;





- (id) init {
	if (self = [super init]) {
		self.files = [[Files alloc] init];
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *APIFile = [mainBundle pathForResource:@"APIKey" ofType:@"txt"];
		NSString *keyFromFile = [NSString stringWithContentsOfFile:APIFile encoding:NSUTF8StringEncoding error:NULL];
		self.APIKey = [keyFromFile stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
		NSDictionary *infoDict=[mainBundle infoDictionary];
		NSString *version=[infoDict objectForKey:@"CFBundleVersion"];
		NSString *appName=[infoDict objectForKey:@"CFBundleName"];
		self.userAgent=[NSString stringWithFormat:@"%@ iOS / %@",appName,version];
		
		[PhotoCategoryManager sharedInstance];
	}
	return self;
}


@end
