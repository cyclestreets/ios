//
//  NSArray+Additions.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/02/2013.
//  Copyright (c) 2013 CycleStreets Ltd. All rights reserved.
//

#import "NSArray-Additions.h"

@implementation NSArray (Additions)

- (id)safeObjectAtIndex:(NSUInteger)index;
{
    return ([self arrayContainsIndex:index] ? [self objectAtIndex:index] : nil);
}

- (BOOL)arrayContainsIndex:(NSUInteger)index;
{
    return NSLocationInRange(index, NSMakeRange(0, [self count]));
}

@end
