//
//  Coord.m
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import "Coord.h"
#import "Trip.h"

#import <objc/runtime.h>

@implementation Coord

@dynamic hAccuracy;
@dynamic longitude;
@dynamic vAccuracy;
@dynamic speed;
@dynamic latitude;
@dynamic recorded;
@dynamic altitude;
@dynamic trip;




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
		if(![key isEqualToString:@"trip"]){
			
			id value = [self valueForKey:key];
			[propertyDescriptions appendFormat:@"; %@ = %@", key, value];
			
		}
	
	}
	return [NSString stringWithFormat:@"<%@: 0x%x%@>", [self class],
			(NSUInteger)self, propertyDescriptions];
	
	
}



@end
