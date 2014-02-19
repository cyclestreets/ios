//
//  CSWaypointAnnotation.m
//  CycleStreets
//
//  Created by Neil Edwards on 17/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSWaypointAnnotation.h"

@interface CSWaypointAnnotation()

@property (nonatomic,assign,readwrite)  CLLocationCoordinate2D					coordinate;

@end

@implementation CSWaypointAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
    return @"subtitle";
}

- (NSString *)title{
    return @"title";
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coordinate
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

@end
