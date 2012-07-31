//
//  NSString-CountryCompare.m
//
//
//  Created by neil on 26/07/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import "NSString-CountryCompare.h"


@implementation NSString(CountryCompare) 

- (NSComparisonResult)countryCompare:(NSString *)aString{
	/*
	 NSOrderedAscending = -1,
	 NSOrderedSame,
	 NSOrderedDescending
	 
	 */
	if ([self isEqualToString:aString]) {
		return NSOrderedSame;
	}
	
	if ([self isEqualToString:@"Eire"]) {
		
		if ([aString isEqualToString:@"United Kingdom"]) {
			return NSOrderedAscending;
		}
		if ([aString isEqualToString:@"South Africa"]) {
			return NSOrderedDescending;
		}
		
	} else if ([self isEqualToString:@"United Kingdom"]) {		
		return NSOrderedDescending ;// everything is below UK
		
	} else if ([self isEqualToString:@"South Africa"]) {
		return NSOrderedAscending ;// everything is above South Africa
	} 
	
	return NSOrderedSame;
}

@end
