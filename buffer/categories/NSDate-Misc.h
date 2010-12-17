//
//  NSDate-Misc.h
//  RacingUK
//
//  Created by neil on 14/12/2009.
//  Copyright 2009 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate(Misc)
+ (NSDate *)dateWithoutTime;
- (NSDate *)dateByAddingDays:(NSInteger)numDays;
- (NSDate *)dateAsDateWithoutTime;
- (int)differenceInDaysTo:(NSDate *)toDate;
- (NSString *)formattedDateString;
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;
@end