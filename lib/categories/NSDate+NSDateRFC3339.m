//
//  NSDate+NSDateRFC3339.m
//  RacingUK
//
//  Created by Neil Edwards on 14/12/2011.
//  Copyright (c) 2011 Chroma. All rights reserved.
//

#import "NSDate+NSDateRFC3339.h"

@implementation NSDate (NSDateRFC3339)



+(NSDate*)dateFromRFC3339:(NSString *)dateString 
{
    NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
    [rfc3339TimestampFormatterWithTimeZone setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	
    NSDate *theDate = nil;
    NSError *error = nil; 
    if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:dateString range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateString, error);
    }
	
    return theDate;
}


-(NSString*)RFC3339String
{
    static NSDateFormatter *df = nil;
    if(df == nil)
    {
        df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    }
    return [df stringFromDate:self];
}

@end
