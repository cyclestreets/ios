//
//  CSRouteSegmentAnnotation.m
//  CycleStreets
//
//  Created by Neil Edwards on 24/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSRouteSegmentAnnotation.h"

@interface CSRouteSegmentAnnotation()

@property (nonatomic,assign,readwrite)  CLLocationCoordinate2D					coordinate;

@end

@implementation CSRouteSegmentAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
    return @"subtitle";
}

- (NSString *)title{
    return @"Remove";
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
