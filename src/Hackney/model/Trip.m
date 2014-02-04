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
#import "GlobalUtilities.h"
#import "SettingsManager.h"

#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

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


- (id)init
{
    self = [super init];
    if (self) {
        self.distance=0;
		self.duration=0;
    }
    return self;
}



//
/***********************************************
 * @description			overrides for faulty Apple CoreDataGeneratedAccessors
 ***********************************************/
//
- (void)addCoordsObject:(Coord *)value {
	
	NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.coords];
	
	[tempSet addObject:value];
	
	self.coords = tempSet;
	
}

- (void)removeCoordsObject:(Coord *)value{
	
	NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.coords];
	
	[tempSet removeObject:value];
	
	self.coords = tempSet;
	
}

- (void)addCoords:(NSOrderedSet *)values{
	
	NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.coords];
	
	[tempSet intersectOrderedSet:values];
	
	self.coords=tempSet;
	
}





-(BOOL)isUploaded{
	return self.uploaded!=nil;
}







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


-(NSString*)lengthString{
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		float totalMiles = [[self distance] floatValue]/1600;
		return [NSString stringWithFormat:@"%3.1f miles", totalMiles];
	}else {
		float	kms=[[self distance] floatValue]/1000;
		return [NSString stringWithFormat:@"%4.1f km", kms];
	}
}

-(NSString*)speedString{
	
	
	NSNumber *kmSpeed=[NSNumber numberWithInt:0];
	
	if([self.duration intValue]==0 || [self.distance intValue]==0){
		// nothing
	}else{
		kmSpeed = [NSNumber numberWithFloat:(([self.distance floatValue]/1000)/([self.duration floatValue]/ 3600))];
	}
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES) {
		double mileSpeed=[kmSpeed doubleValue]/1.609;
		return [NSString stringWithFormat:@"%2.0f mph", mileSpeed];
	}else {
		return [NSString stringWithFormat:@"%2.1f km/h", [kmSpeed  floatValue]];
	}
}


-(NSString*)timeString{
	
	NSUInteger h = [[self duration]intValue] / TIME_HOUR;
	NSUInteger m = ([[self duration]intValue] / 60) % 60;
	NSUInteger s = [[self duration]intValue] % 60;
	
	if ([[self duration]intValue]>TIME_HOUR) {
		return [NSString stringWithFormat:@"%02d:%02d:%02d", h,m,s];
	}else {
		return [NSString stringWithFormat:@"%02d:%02d", m,s];
	}
}


-(NSString*)co2SavedString{
	
	return [NSString stringWithFormat:@"CO2 saved: %.1f lbs", 0.93 * [self.distance doubleValue] / 1609.344];
	
}

-(NSString*)caloriesUsedString{
	
	double calory = 49 * [self.distance doubleValue] / 1609.344 - 1.69;
    if (calory <= 0) {
        return [NSString stringWithFormat:@"Calories used: 0 kcal"];
    }else{
		return [NSString stringWithFormat:@"Calories used: %.1f kcal", calory];
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



- (NSArray *)describablePropertyNames
{
	// Loop through our superclasses until we hit NSObject
	NSMutableArray *array = [NSMutableArray array];
	Class subclass = [self class];
	while (subclass != [NSObject class])
	{
		unsigned int propertyCount;
		objc_property_t *properties = class_copyPropertyList(subclass,&propertyCount);
		for (int i = 0; i < propertyCount; i++)
		{
			// Add property name to array
			objc_property_t property = properties[i];
			const char *propertyName = property_getName(property);
			[array addObject:@(propertyName)];
		}
		free(properties);
		subclass = [subclass superclass];
	}
	
	// Return array of property names
	return array;
}



-(NSString*)longDescription{
	
	
	NSMutableString *propertyDescriptions = [NSMutableString string];
	for (NSString *key in [self describablePropertyNames])
	{
		if(![key isEqualToString:@"coords"]){
			
			id value = [self valueForKey:key];
			[propertyDescriptions appendFormat:@"; %@ = %@", key, value];
			
		}
		
	}
	return [NSString stringWithFormat:@"<%@: 0x%x%@>", [self class],
			(NSUInteger)self, propertyDescriptions];
	
	
}




@end
