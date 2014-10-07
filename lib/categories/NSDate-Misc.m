//
//  NSDate-Misc.m
//
//
//  Created by neil on 14/12/2009.
//  Copyright 2009 Buffer. All rights reserved.
//

#import "NSDate-Misc.h"

@implementation NSDate(Misc)
+ (NSDate *)dateWithoutTime
{
    return [[NSDate date] dateAsDateWithoutTime];
}
-(NSDate *)dateByAddingDays:(NSInteger)numDays
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:numDays];
    
    NSDate *date = [gregorian dateByAddingComponents:comps toDate:self options:0];
    return date;
}



- (NSDate *)dateAsDateWithoutTime
{
    NSString *formattedString = [self formattedDateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *ret = [formatter dateFromString:formattedString];
    return ret;
}
- (NSInteger)differenceInDaysTo:(NSDate *)toDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:self
                                                  toDate:toDate
                                                 options:0];
    NSInteger days = [components day];
    return days;
}
- (NSString *)formattedDateString
{
    return [self formattedStringUsingFormat:@"MMM dd, yyyy"];
}
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}


- (NSDate *)dateWithZeroTime
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	return [calendar dateFromComponents:comps];
}

- (NSDate *)dateWithZeroSeconds
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
	[comps setSecond:0];
	return [calendar dateFromComponents:comps];
}

//- (NSString *)whenString
- (NSString *)YTTDFrom:(NSDate *)comparisonDate withFormat:(NSString *)dateFormat
{
	NSDate *selfZero = [self dateWithZeroTime];
	NSDate *checkZero = [comparisonDate dateWithZeroTime];
	NSTimeInterval interval = [checkZero timeIntervalSinceDate:selfZero];
	int dayDiff = interval/(60*60*24);
	
	// Initialize the formatter.
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	if (dayDiff == 0) { // today: show time only
		//[formatter setDateStyle:NSDateFormatterNoStyle];
		//[formatter setTimeStyle:NSDateFormatterShortStyle];
		return @"Today";
	} else if (dayDiff == 1 || dayDiff == -1) {
		//return NSLocalizedString((dayDiff == 1 ? @”Yesterday” : @”Tomorrow”), nil);
		[formatter setDoesRelativeDateFormatting:YES];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterNoStyle];
		//} else if (dayDiff <= 7) { // < 1 week ago: show weekday
		//	[formatter setDateFormat:@"EEEE"];
	} else { // show date
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterNoStyle];
		[formatter setDateFormat:dateFormat];
	}
	
	return [formatter stringFromDate:self];
}


- (NSDate *)midnightUTC {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:self];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
	
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
	
    return midnightUTC;
}


+(NSDate*)dateForDay:(NSDate*)dayPortion withTime:(NSDate*)timePortion{
	
	NSCalendar *daycalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned dayunitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *daycomps = [daycalendar components:dayunitFlags fromDate:dayPortion];
	
	NSCalendar *timecalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned timeunitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDateComponents *timecomps = [timecalendar components:timeunitFlags fromDate:timePortion];
	
	
	NSDateComponents *finalcomps=[[NSDateComponents alloc]init];
	[finalcomps setYear:daycomps.year];
	[finalcomps setMonth:daycomps.month];
	[finalcomps setDay:daycomps.day];
	[finalcomps setHour:timecomps.hour];
	[finalcomps setMinute:timecomps.minute];
	
	NSDate *combindedDate = [daycalendar dateFromComponents:finalcomps];
	
	return combindedDate;
	
}

@end
