//
//  NSDate+Helper.h
//  Codebook
//
//  Created by Billy Gray on 2/26/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;

// commonly used format strings
+ (NSString *)dbFormatString;  // unix
+ (NSString *)dayFormatString;
+ (NSString *)shortFormatString; // 12/09/10
+ (NSString *)humanFormatString;  // Wednesday, August 12
+ (NSString *)fullDateFormatString; // Wednesday, October 12, 2010 

//
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromDayString:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString*)format;
- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;


// NSDDate 12/24 Bug support
+(NSString *)time24FromDate:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone;
+(NSDate *)dateFromTime24:(NSString *)time24String withTimeZone:(NSTimeZone *)timeZone;
+(BOOL)userSetTwelveHourMode;
+(NSString *)time12FromTime24:(NSString *)time24String;

@end