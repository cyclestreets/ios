//
//  POIAnnotation.h
//  CycleStreets
//
//  Created by Neil Edwards on 15/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "POILocationVO.h"

@interface POIAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic,strong)  POILocationVO					*dataProvider;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;


@end
