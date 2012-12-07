//
//  POITypeVO.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICategoryVO.h"
#import "WBImage.h"

@implementation POICategoryVO
@synthesize key;
@synthesize name;
@synthesize shortname;
@synthesize total;
@synthesize icon;



static NSString *KEY = @"key";
static NSString *NAME = @"name";
static NSString *SHORTNAME = @"shortname";
static NSString *TOTAL = @"total";
static NSString *ICON = @"icon";


-(UIImage*)mapImage{
	
	return [self.icon scaleWithMaxSize:24];
	
}


//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.key forKey:KEY];
    [encoder encodeObject:self.name forKey:NAME];
    [encoder encodeObject:self.shortname forKey:SHORTNAME];
    [encoder encodeInt:self.total forKey:TOTAL];
    [encoder encodeObject:self.icon forKey:ICON];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.key = [decoder decodeObjectForKey:KEY];
        self.name = [decoder decodeObjectForKey:NAME];
        self.shortname = [decoder decodeObjectForKey:SHORTNAME];
        self.total = [decoder decodeIntForKey:TOTAL];
        self.icon = [decoder decodeObjectForKey:ICON];
    }
    return self;
}

@end
