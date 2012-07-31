//
//  MutableDictionaryCopy.m
//  IndexedTableApp
//
//  Created by Neil Edwards on 30/03/2009.
//  Copyright 2009 buffer. All rights reserved.
//

#import "NSDictionary-MutableDictionaryCopy.h"


@implementation NSDictionary (MutableDictionaryCopy)

- (NSMutableDictionary *)mutableDeepCopyOfArrays
{
	//NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	NSArray *keys = [self allKeys];
	for (id key in keys)
	{
		NSArray *oneArray = [self valueForKey:key];
		NSMutableArray *arrayCopy = [[NSMutableArray alloc] initWithArray:oneArray];
		[ret setValue:arrayCopy forKey:key];
	}
	return ret;
}
- (NSMutableDictionary *) MutableDictionaryCopy
{
	//NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	NSArray *keys = [self allKeys];
	for (id key in keys)
	{
		id oneValue = [self valueForKey:key];
		id oneCopy = nil;
		
		if ([oneValue respondsToSelector:@selector(MutableDictionaryCopy)])
			oneCopy = [oneValue MutableDictionaryCopy];
		else if ([oneValue respondsToSelector:@selector(mutableCopy)])
			oneCopy = [oneValue mutableCopy];
		
		if (oneCopy == nil)
			oneCopy = [oneValue copy];
		[ret setValue:oneCopy forKey:key];
	}
	return ret;
}

@end
