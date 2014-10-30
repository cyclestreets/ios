//
//  POIAnnotation.m
//  CycleStreets
//
//  Created by Neil Edwards on 15/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "POIAnnotation.h"

@interface POIAnnotation()

@property (nonatomic,assign,readwrite)  CLLocationCoordinate2D					coordinate;

@end

@implementation POIAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
	return _dataProvider.notes;
}

- (NSString *)title{
	return _dataProvider.name;
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
	_dataProvider.coordinate=coordinate;
}

@end
