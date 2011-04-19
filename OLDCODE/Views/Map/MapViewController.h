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
#import "MapLocationSearchViewController.h"
#import "RMMapViewDelegate.h"
#import "RMMapView.h"
#import "RouteLineView.h"
#import "BlueCircleView.h"
#import "MBProgressHUD.h"
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
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, PointListProvider, LocationProvider,MBProgressHUDDelegate> {
	//IB items
	UIToolbar *toolBar;
	
	UIBarButtonItem *locationButton;
	UIBarButtonItem *activeLocationButton;
	UIActivityIndicatorView	*locatingIndicator;
	
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
	
	MapLocationSearchViewController *mapLocationSearchView;			//the search popup
	
	Route *route;					//current route
	
	RMMarker *start;
	RMMarker *end;
	NSMutableArray *startEndPool;//work around release/retain problem on Markers, only visible on 3.1.3.
	
	//lots of state flags. Needs a refactor. Turn everything into planningState ?
	BOOL doingLocation;
	BOOL programmaticChange;
	
	BOOL firstTimeStart;
	BOOL firstTimeFinish;
	BOOL	avoidAccidentalTaps;
	BOOL	singleTapDidOccur;
	CGPoint	singleTapPoint;
	
	UIAlertView *firstAlert;
	UIAlertView *clearAlert;
	UIAlertView *startFinishAlert;
	UIAlertView *noLocationAlert;
	
	PlanningState planningState;
	
	MBProgressHUD		*HUD;
}
@property (nonatomic, retain)	IBOutlet UIToolbar	*toolBar;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*locationButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*activeLocationButton;
@property (nonatomic, retain)	IBOutlet UIActivityIndicatorView	*locatingIndicator;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*nameButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*routeButton;
@property (nonatomic, retain)	IBOutlet UIBarButtonItem	*deleteButton;
@property (nonatomic, retain)	IBOutlet UILabel	*attributionLabel;
@property (nonatomic, retain)	CycleStreets	*cycleStreets;
@property (nonatomic, retain)	RMMapView	*mapView;
@property (nonatomic, retain)	RouteLineView	*lineView;
@property (nonatomic, retain)	BlueCircleView	*blueCircleView;
@property (nonatomic, retain)	InitialLocation	*initialLocation;
@property (nonatomic, retain)	CLLocationManager	*locationManager;
@property (nonatomic, retain)	CLLocation	*lastLocation;
@property (nonatomic, retain)	MapLocationSearchViewController	*mapLocationSearchView;
@property (nonatomic, retain)	Route	*route;
@property (nonatomic, retain)	RMMarker	*start;
@property (nonatomic, retain)	RMMarker	*end;
@property (nonatomic, retain)	NSMutableArray	*startEndPool;
@property (nonatomic, assign)	BOOL	doingLocation;
@property (nonatomic, assign)	BOOL	programmaticChange;
@property (nonatomic, assign)	BOOL	firstTimeStart;
@property (nonatomic, assign)	BOOL	firstTimeFinish;
@property (nonatomic, assign)	BOOL	avoidAccidentalTaps;
@property (nonatomic, assign)	BOOL	singleTapDidOccur;
@property (nonatomic, assign)	CGPoint	singleTapPoint;
@property (nonatomic, retain)	IBOutlet UIAlertView	*firstAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*clearAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*startFinishAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*noLocationAlert;
@property (nonatomic, assign)	PlanningState	planningState;
@property (nonatomic, retain)	MBProgressHUD	*HUD;




- (IBAction) didZoomIn;
- (IBAction) didZoomOut;
- (IBAction) didLocation;
- (IBAction) didDelete;
- (IBAction) didRoute;
- (IBAction) didSearch;
-(void)updateSelectedRoute;
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
