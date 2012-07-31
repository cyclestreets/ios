//
//  NSManagedObject+FirstLetter.h
//  MovieList.xcodeproj-XC4
//
//  Created by Neil Edwards on 10/02/2011.
//  Copyright 2011 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<CoreData/CoreData.h>

@interface NSManagedObject (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName;
@end


