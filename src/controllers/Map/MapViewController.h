//
//  NewMapViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 26/09/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "RMMapViewDelegate.h"
#import "RouteVO.h"
#import "RouteLineView.h"
#import "BlueCircleView.h"
#import "WEPopoverController.h"
#import "MapLocationSearchViewController.h"
#import "UserLocationManager.h"
#import "WayPointViewController.h"
#import "RMTileSource.h"
#import "SMCalloutView.h"

@class CycleStreets;
@class RouteVO;
@class Location;
@class InitialLocation;


enum  {
	MapPlanningStateNoRoute, // no route loaded, no waypoints added
	MapPlanningStateLocating, // gps is on
	MapPlanningStateStartPlanning, // a waypoint has been added
	MapPlanningStatePlanning, // waypoints>1 have been added but no route requested
	MapPlanningStateRoute, // a route is loaded
};
typedef int MapPlanningState;

enum  {
	MapAlertTypeClearRoute,
	MapAlertTypeProximity
};
typedef int MapAlertType;


@interface MapViewController : SuperViewController
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, PointListProvider, LocationProvider, WEPopoverControllerDelegate,UserLocationManagerDelegate,SMCalloutViewDelegate>{
	
	
	Class popoverClass;
	
	
}


// class methods
+ (NSArray *)mapStyles;
+ (NSObject <RMTileSource> *)tileSource;
+ (void)zoomMapView:(RMMapView *)mapView toLocation:(CLLocation *)newLocation;
+ (NSArray *) pointList:(RouteVO *)route withView:(RMMapView *)mapView;
+ (NSString *)currentMapStyle;
+ (NSString *)mapAttribution;

@end
