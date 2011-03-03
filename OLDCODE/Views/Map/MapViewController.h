/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  Map.h
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import <UIKit/UIKit.h>
#import "Namefinder2.h"
#import "RMMapViewDelegate.h"
#import "RMMapView.h"
#import "RouteLineView.h"
#import "BlueCircleView.h"
@class CycleStreets;
@class Route;
@class Location;
@class InitialLocation;
@class CustomButtonView;

enum PlanningStateT {stateStart = 0,
	stateLocatingStart = 5,
	stateEnd = 10,
	stateLocatingEnd = 15,
	statePlan = 20,
	stateRoute = 30
};
typedef enum PlanningStateT PlanningState;

@interface MapViewController : UIViewController
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, PointListProvider, LocationProvider> {
	//IB items
	UIToolbar *toolBar;
	
	UIBarButtonItem *locationButton;
	UIBarButtonItem *activeLocationButton;
	CustomButtonView *activeLocationView;
	
	UIBarButtonItem *nameButton;
	UIBarButtonItem *routeButton;
	UIBarButtonItem *deleteButton;
	
	UILabel *attributionLabel;
	
	CycleStreets *cycleStreets;		//application data
	RMMapView *mapView;				//map of current area
	RouteLineView *lineView;		//overlay route lines on top of map
	BlueCircleView *blueCircleView;	//overlay GPS location
	
	InitialLocation *initialLocation;
	CLLocationManager *locationManager; //move out of this class into app, or app sub, if/when we generalise.
	CLLocation *lastLocation;		//the last one
	
	Namefinder2 *namefinder;			//the search popup
	
	Route *route;					//current route
	
	RMMarker *start;
	RMMarker *end;
	NSMutableArray *startEndPool;//work around release/retain problem on Markers, only visible on 3.1.3.
	
	//lots of state flags. Needs a refactor. Turn everything into planningState ?
	BOOL doingLocation;
	BOOL programmaticChange;
	
	BOOL firstTimeStart;
	BOOL firstTimeFinish;
	BOOL avoidAccidentalTaps;
	
	UIAlertView *firstAlert;
	UIAlertView *clearAlert;
	UIAlertView *startFinishAlert;
	UIAlertView *noLocationAlert;
	
	PlanningState planningState;
}

@property (nonatomic, retain) UIBarButtonItem *locationButton;
@property (nonatomic, retain) UIBarButtonItem *activeLocationButton;
@property (nonatomic, retain) CustomButtonView *activeLocationView;

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *nameButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *routeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, retain) IBOutlet RMMapView *mapView;
@property (nonatomic, retain) IBOutlet RouteLineView *lineView;
@property (nonatomic, retain) IBOutlet BlueCircleView *blueCircleView;
@property (nonatomic, retain) IBOutlet UILabel *attributionLabel;
@property (nonatomic, retain) RMMarker *start;
@property (nonatomic, retain) RMMarker *end;
@property BOOL programmaticChange;

@property PlanningState planningState;

- (IBAction) didZoomIn;
- (IBAction) didZoomOut;
- (IBAction) didLocation;
- (IBAction) didDelete;
- (IBAction) didRoute;
- (IBAction) didSearch;

@property (nonatomic, retain) UIAlertView *firstAlert;
@property (nonatomic, retain) UIAlertView *clearAlert;
@property (nonatomic, retain) UIAlertView *startFinishAlert;
@property (nonatomic, retain) UIAlertView *noLocationAlert;


- (void) showRoute:(Route *)route;
- (void)stopDoingLocation;
- (void)startDoingLocation;

+ (NSArray *)mapStyles;
+ (NSObject <RMTileSource> *)tileSource;
+ (void)zoomMapView:(RMMapView *)mapView toLocation:(CLLocation *)newLocation;
+ (NSArray *) pointList:(Route *)route withView:(RMMapView *)mapView;
+ (NSString *)currentMapStyle;
+ (NSString *)mapAttribution;

@end
