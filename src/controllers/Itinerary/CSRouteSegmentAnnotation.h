//
//  CSRouteSegmentAnnotation.h
//  CycleStreets
//
//  Created by Neil Edwards on 24/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "WayPointVO.h"
@class SegmentVO;

@interface CSRouteSegmentAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic,assign)  WayPointType					wayPointType;
@property (nonatomic,assign)  BOOL							menuEnabled;
@property (nonatomic,assign)  int							annotationAngle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
