//
//  NSDate-Misc.h
//
//
//  Created by neil on 14/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate(Misc)
+ (NSDate *)dateWithoutTime;
- (NSDate *)dateByAddingDays:(NSInteger)numDays;
- (NSDate *)dateAsDateWithoutTime;
- (NSDate *)dateWithZeroSeconds;
- (NSDate *)dateWithZeroTime;
- (NSInteger)differenceInDaysTo:(NSDate *)toDate;
- (NSString *)formattedDateString;
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;
- (NSString *)YTTDFrom:(NSDate *)comparisonDate withFormat:(NSString *)dateFormat;
- (NSDate *)midnightUTC ;
+(NSDate*)dateForDay:(NSDate*)dayPortion withTime:(NSDate*)timePortion;
@end