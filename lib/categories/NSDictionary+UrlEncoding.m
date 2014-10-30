//
//  NSDictionary+UrlEncoding.m
//  
//
//  Created by Neil Edwards on 15/07/2009.
//  Copyright 2009 buffer. All rights reserved.
//

// produces a GET format url encosed string from a given dictionary

#import "NSDictionary+UrlEncoding.h"
#import "StringUtilities.h"

// helper function: get the string form of any object
static NSString *toString(id object) {
	return [NSString stringWithFormat: @"%@", object];
}



@implementation NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString {
	NSMutableArray *parts = [NSMutableArray array];
	for (id key in self) {
		id value = [self objectForKey: key];
		NSString *part = [NSString stringWithFormat: @"%@=%@", [StringUtilities urlencode:key], [StringUtilities urlencode:toString(value)]];
		[parts addObject: part];
	}
	return [parts componentsJoinedByString: @"&"];
}


@end