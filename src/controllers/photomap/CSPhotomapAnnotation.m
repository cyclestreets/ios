//
//  CSPhotomapAnnotation.m
//  CycleStreets
//
//  Created by Neil Edwards on 19/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSPhotomapAnnotation.h"

@interface CSPhotomapAnnotation()


@property (nonatomic,assign,readwrite)  CLLocationCoordinate2D					coordinate;

@end

@implementation CSPhotomapAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
    return @"";
}

- (NSString *)title{
    return @"";
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
