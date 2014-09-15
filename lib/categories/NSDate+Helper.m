//
//  NSDate+Helper.m
//  Codebook
//
//  Created by Billy Gray on 2/26/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSDayCalendarUnit) 
											   fromDate:self
												 toDate:[NSDate date]
												options:0];
	return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = @"Today";
			break;
		case 1:
			text = @"Yesterday";
			break;
		default:
			text = [NSString stringWithFormat:@"%lu days ago", (unsigned long)daysAgo];
	}
	return text;
}

- (NSUInteger)weekday {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}

+ (NSString *)dbFormatString {
	return @"yyyy-MM-dd HH:mm:ss";
}
+ (NSString *)shortdbFormatString {
	return @"yyyy-MM-dd HH:mm";
}

+ (NSString *)dayFormatString {
	return @"yyyy-MM-dd";
}

+ (NSString *)shortFormatString {
	return @"dd/MM/yy";
}

+ (NSString *)humanFormatString {
	return @"EEEE, MMMM d";
}

+ (NSString *)usefulhumanFormatString {
	return @"EE, MMM d yyyy";
}

+ (NSString *)shortHumanFormatString {
	return @"dd MMM YY";
}

+ (NSString *)shortHumanFormatStringWithTime {
	return @"dd MMM yyyy HH:mm";
}

+ (NSString *)fullDateFormatString {
	return @"EEEE, MMMM dd, yyyy";
}



+ (NSDate *)dateFromString:(NSString *)string {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:[NSDate dbFormatString]];
	// NOTE: this is required to overcome the iPhone SDK Bug where the users time format setting will override any application formatting
	[inputFormatter setLocale:[NSLocale systemLocale]]; 
	//
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSDate *)dateFromDayString:(NSString *)string {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:[NSDate dayFormatString]];
	[inputFormatter setLocale:[NSLocale systemLocale]]; 
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	//[outputFormatter setLocale:[NSLocale systemLocale]]; NOTE: use of setLocate seriously messes this up.
	NSString *newDateString = [outputFormatter stringFromDate:date];
	return newDateString;
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString*)format {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSDate *)dateFromUKString:(NSString *)string withFormat:(NSString*)format {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
	
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [NSDate stringFromDate:date withFormat:[NSDate dbFormatString]];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
	/* 
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
	
	NSDate *today = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
													 fromDate:today];
	
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	
	NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
	NSString *displayString = nil;
	
	// comparing against midnight
	if ([date compare:midnight] == NSOrderedDescending) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		} else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	} else {
		// check if date is within last 7 days
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-7];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
		if ([date compare:lastweek] == NSOrderedDescending) {
			[displayFormatter setDateFormat:@"EEEE"]; // Tuesday
		} else {
			// check if same calendar year
			NSInteger thisYear = [offsetComponents year];
			
			NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
														   fromDate:date];
			NSInteger thatYear = [dateComponents year];			
			if (thatYear >= thisYear) {
				[displayFormatter setDateFormat:@"MMM d"];
			} else {
				[displayFormatter setDateFormat:@"MMM d, yyyy"];
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
	}
	
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSDate *)beginningOfWeek {
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
	NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
	
	//normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	// Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
											   fromDate:self];
	return [calendar dateFromComponents:components];
}




//
/***********************************************
 * @description			SUPPORT FOR BUG IN NSDateFormatter which overrides your formmating string with the users Date/Time pref Setting
 ***********************************************/
//

// Returns time string in 24-hour mode from the given NSDate
+(NSString *)time24FromDate:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone
{
	NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	[dateFormatter setTimeZone:timeZone];
	[dateFormatter setLocale:[NSLocale systemLocale]]; 
	NSString* time = [dateFormatter stringFromDate:date];
	
	if (time.length > 5) {
		NSRange range;
		range.location = 3;
		range.length = 2;
		int hour = [[time substringToIndex:2] intValue];
		NSString *minute = [time substringWithRange:range];
		range = [time rangeOfString:@"AM"];
		if (range.length==0)
			hour += 12;
		time = [NSString stringWithFormat:@"%02d:%@", hour, minute];
	}
	
	return time;
}

// Returns a proper NSDate given a time string in 24-hour mode
+(NSDate *)dateFromTime24:(NSString *)time24String withTimeZone:(NSTimeZone *)timeZone
{
	int hour = [[time24String substringToIndex:2] intValue];
	int minute = [[time24String substringFromIndex:3] intValue];
	NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:timeZone];
	
	NSDate *result;
	if ([self userSetTwelveHourMode]) {
		[dateFormatter setDateFormat:@"hh:mm aa"];
		if (hour > 12) {
			result = [dateFormatter dateFromString:[NSString stringWithFormat:@"%02d:%02d PM", hour - 12, minute]];
		} else {
			result = [dateFormatter dateFromString:[NSString stringWithFormat:@"%02d:%02d AM", hour, minute]];
		}
	} else {
		[dateFormatter setDateFormat:@"HH:mm"];
		result = [dateFormatter dateFromString:[NSString stringWithFormat:@"%02d:%02d", hour, minute]];
	}
	
	return result;
}

// Tests whether the user has set the 12-hour or 24-hour mode in their settings.
+(BOOL)userSetTwelveHourMode
{
	NSDateFormatter *testFormatter = [[NSDateFormatter alloc] init];
	[testFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *testTime = [testFormatter stringFromDate:[NSDate date]];
	return [testTime hasSuffix:@"M"] || [testTime hasSuffix:@"m"];
}

// Converts a 24-hour time string to 12-hour time string
+(NSString *)time12FromTime24:(NSString *)time24String
{
	NSDateFormatter *testFormatter = [[NSDateFormatter alloc] init];
	int hour = [[time24String substringToIndex:2] intValue];
	int minute = [[time24String substringFromIndex:3] intValue];
	
	NSString *result = [NSString stringWithFormat:@"%02d:%02d %@", hour % 12, minute, hour > 12 ? [testFormatter PMSymbol] : [testFormatter AMSymbol]];
	return result;
}


+(NSPredicate *)dateMatcher:(NSDate *)date forAttribute:(NSString *)attributeName{   
    
	//First set the unit flags you want automatically put into your date from an NSDate object   
	unsigned startUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;   
	//now create an NSCalendar object   
	NSCalendar *startCal = [NSCalendar currentCalendar];   
	//Use the NSCalendar object to create an NSDateComponents object from the date you are interested in rounding   
	//In this case we are just using the time now by calling [NSDate date]   
	NSDateComponents *minDateComps = [startCal components:startUnitFlags fromDate:[NSDate date]];   
	//Now we use the NSCalendar object again to generate a date from the date components object   
	NSDate *startDate = [startCal dateFromComponents:minDateComps];   
    
    
	//First set the unit flags you want automatically put into your date from an NSDate object   
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;   
	//now create an NSCalendar object   
	NSCalendar *cal = [NSCalendar currentCalendar];   
	//Use the NSCalendar object to create an NSDateComponents object from the date you are interested in rounding   
	//In this case we are just using the time now by calling [NSDate date]   
	NSDateComponents *maxDateComps = [cal components:unitFlags fromDate:[NSDate date]];   
	//now set the hours, minutes and seconds to the end of the day   
	maxDateComps.hour = 23;   
	maxDateComps.minute = 59;   
	maxDateComps.second = 59;   
	//Now we use the NSCalendar object again to generate a date from the date components object   
	NSDate *endDate = [cal dateFromComponents:maxDateComps];   
    
    
	// Finally create the predicate with the correct format   
	return [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)",attributeName, startDate, attributeName, endDate];   
}   


+(NSDate*)convertEpochMSTimeToDate:(NSString*)time{
	
	long long plong;  
	NSRange range;  
	range.length = time.length;  
	range.location = 0;  
	
	[[NSScanner scannerWithString:[time substringWithRange:range]] 
	 scanLongLong:&plong];
	
	plong=plong/1000;
	
	return [NSDate dateWithTimeIntervalSince1970:plong];
	
}


+(NSDate*)newDateTimeIgnoringDate:(NSDate*)date{
	
	unsigned int flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSCalendar* calendar = [NSCalendar currentCalendar];
	
	NSDateComponents* components = [calendar components:flags fromDate:date];
	[components setSecond:0];
	
	NSDate* timeOnlyDate = [calendar dateFromComponents:components];
	
	return timeOnlyDate;
	
}


@end