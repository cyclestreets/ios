//
//  RouteMapViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 27/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "RouteVO.h"
#import "RMMapViewDelegate.h"
#import "RMMapView.h"
#import "MapLocationSearchViewController.h"
#import "RouteLineView.h"
#import <CoreLocation/CoreLocation.h>

@class CycleStreets;


enum  RoutePlanningState{
	RoutePlanningStateInit = 0,
	RoutePlanningStateLocatingPoint = 1,
	RoutePlanningStatePointLocated = 2,
	RoutePlanningStateRoutePossible = 3,
	RoutePlanningStateRouting = 4,
	RoutePlanningStateShowRoute = 5,
};
typedef enum RoutePlanningState PlanningState;

@interface RouteMapViewController : SuperViewController{
	
	UIToolbar						*toolBar;
	
	UIBarButtonItem					*gpslocateButton;
	UIBarButtonItem					*locationSearchButton;
	UIBarButtonItem					*poiSelectionButton;
	UIBarButtonItem					*deletePointButton;
	UIBarButtonItem					*findRouteButton;
	
	UILabel							*routeStateLabel;
	
	UILabel							*attributionLabel;
	
	CycleStreets					*cycleStreets;		//application data
	IBOutlet RMMapView				*mapView;			//map of current area
	IBOutlet RouteLineView			*lineView;			//overlay route lines on top of map
	IBOutlet BlueCircleView			*blueCircleView;	//overlay GPS location
	
	
	CLLocationManager				*locationManager; //move out of this class into app, or app sub, if/when we generalise.
	CLLocation						*lastLocation;		//the last one
	
	MapLocationSearchViewController *mapLocationSearchView;			//the search popup
	
	RouteVO *route;					//current route
	
	NSMutableArray					*routePointArray; // array of waypoints for route
	
	BOOL							doingLocation;
	BOOL							programmaticChange;
	BOOL							avoidAccidentalTaps;
	BOOL							singleTapDidOccur;
	CGPoint							singleTapPoint;
	BOOL							markerisDragging;
	
	
	
	PlanningState					planningState;
	
}


- (IBAction) didLocation;
- (IBAction) didDelete;
- (IBAction) didRoute;
- (IBAction) didSearch;

-(void)updateSelectedRoute;
- (void) showRoute:(RouteVO *)route;

- (void)stopDoingLocation;
- (void)startDoingLocation;

+ (NSArray *)mapStyles;
+ (NSObject <RMTileSource> *)tileSource;
+ (void)zoomMapView:(RMMapView *)mapView toLocation:(CLLocation *)newLocation;
+ (NSArray *) pointList:(RouteVO *)route withView:(RMMapView *)mapView;
+ (NSString *)currentMapStyle;
+ (NSString *)mapAttribution;

@end
