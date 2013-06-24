//
//  NSArray+Additions.h
//  CycleStreets
//
//  Created by Neil Edwards on 27/02/2013.
//  Copyright (c) 2013 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

- (id)safeObjectAtIndex:(NSUInteger)index;
- (BOOL)arrayContainsIndex:(NSUInteger)index;

@end
