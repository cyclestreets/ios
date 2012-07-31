//
//  POILocationVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POILocationVO.h"

@implementation POILocationVO
@synthesize locationid;
@synthesize location;
@synthesize name;
@synthesize notes;
@synthesize website;


static NSString *LOCATIONID = @"locationid";
static NSString *LOCATION = @"location";
static NSString *NAME = @"name";
static NSString *NOTES = @"notes";
static NSString *WEBSITE = @"website";



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.locationid forKey:LOCATIONID];
    [encoder encodeObject:self.location forKey:LOCATION];
    [encoder encodeObject:self.name forKey:NAME];
    [encoder encodeObject:self.notes forKey:NOTES];
    [encoder encodeObject:self.website forKey:WEBSITE];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.locationid = [decoder decodeObjectForKey:LOCATIONID];
        self.location = [decoder decodeObjectForKey:LOCATION];
        self.name = [decoder decodeObjectForKey:NAME];
        self.notes = [decoder decodeObjectForKey:NOTES];
        self.website = [decoder decodeObjectForKey:WEBSITE];
    }
    return self;
}
@end
