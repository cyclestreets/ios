//
//  NSManagedObject+FirstLetter.m
//  MovieList.xcodeproj-XC4
//
//  Created by Neil Edwards on 10/02/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import "NSManagedObject+FirstLetter.h"


@implementation NSManagedObject (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"name"] uppercaseString];
	
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
	
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
	
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}
@end
