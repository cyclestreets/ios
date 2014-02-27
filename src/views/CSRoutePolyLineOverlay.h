//
//  CSRoutePolyLineOverlay.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/02/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class RouteVO;

@interface CSRoutePolyLineOverlay : MKPolyline

@property (nonatomic,strong)  NSMutableArray						*dataProvider;


+(CLLocationCoordinate2D*)coordinatesForRoute:(RouteVO*)route fromMap:(MKMapView *)mapView;

@end
