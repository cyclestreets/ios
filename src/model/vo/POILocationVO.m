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

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [locationid release], locationid = nil;
    [name release], name = nil;
    [notes release], notes = nil;
    [website release], website = nil;
	
    [super dealloc];
}


@end
