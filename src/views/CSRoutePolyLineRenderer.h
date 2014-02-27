//
//  CSRoutePolyLineRenderer.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CSRoutePolyLineRenderer : MKOverlayPathRenderer


- (id)initWithPolyline:(MKPolyline *)polyline;

@property (nonatomic, readonly) MKPolyline *polyline;


@end
