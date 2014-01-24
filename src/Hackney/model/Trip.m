//
//  Trip.m
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import "Trip.h"
#import "Coord.h"
#import "User.h"

#import <CoreLocation/CoreLocation.h>

@implementation Trip

@dynamic distance;
@dynamic start;
@dynamic notes;
@dynamic uploaded;
@dynamic purpose;
@dynamic duration;
@dynamic saved;
@dynamic coords;
@dynamic thumbnail;
@dynamic user;




-(NSString*)durationString{
	
	static NSDateFormatter *inputFormatter = nil;
	if ( inputFormatter == nil )
		inputFormatter = [[NSDateFormatter alloc] init];
	
	[inputFormatter setDateFormat:@"HH:mm:ss"];
	NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
	[inputFormatter setDateFormat:@"HH:mm:ss"];
	NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:(NSTimeInterval)[self.duration doubleValue]
													sinceDate:fauxDate];
	
	
	return [NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:outputDate]];
	
}


-(NSString*)co2SavedString{
	
	return [NSString stringWithFormat:@"CO2 Saved: %.1f lbs", 0.93 * [self.distance doubleValue] / 1609.344];
	
}

-(NSString*)caloriesUsedString{
	
	double calory = 49 * [self.distance doubleValue] / 1609.344 - 1.69;
    if (calory <= 0) {
        return [NSString stringWithFormat:@"Calories Burned: 0 kcal"];
    }else{
		return [NSString stringWithFormat:@"Calories Burned: %.1f kcal", calory];
	}
	
}


-(NSString*)longdateString{
	
	static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    static NSDateFormatter *timeFormatter = nil;
    if (timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
	
	
	return [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:self.start], [timeFormatter stringFromDate:self.start]];

}





@end
