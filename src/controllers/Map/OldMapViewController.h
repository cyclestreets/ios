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
#import "RoutePlanMenuViewController.h"
#import "WEPopoverController.h"
#import "ExpandedUILabel.h"
#import "MapMarkerTouchView.h"

@class CycleStreets;
@class RouteVO;
@class Location;
@class InitialLocation;

enum PlanningStateT {stateStart = 0,
	stateLocatingStart = 5,
	stateEnd = 10,
	stateLocatingEnd = 15,
	statePlan = 20,
	stateRoute = 30
};
typedef enum PlanningStateT PlanningState;

@interface OldMapViewController : UIViewController
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, PointListProvider, LocationProvider, WEPopoverControllerDelegate> {
	//IB items
	IBOutlet UIToolbar *toolBar;
	
	UIBarButtonItem *locationButton; // gps button
	UIBarButtonItem *activeLocationButton;
	UIBarButtonItem *nameButton; // search Button
	UIBarButtonItem *routeButton; // plan/new route button
	UIBarButtonItem *deleteButton; // remove route point button
    UIBarButtonItem *planButton; // plan change button
	UIBarButtonItem			*startContextLabel; // pre route label
	UIBarButtonItem			*finishContextLabel; // pre route label
	UIActivityIndicatorView	*locatingIndicator;
	
	UIBarButtonItem		*leftFlex;
	UIBarButtonItem		*rightFlex;
    
   
    RoutePlanMenuViewController *routeplanView;
	
	IBOutlet  UILabel *attributionLabel;
	
	CycleStreets *cycleStreets;		//application data
	IBOutlet RMMapView *mapView;				//map of current area
	IBOutlet RouteLineView *lineView;		//overlay route lines on top of map
	IBOutlet BlueCircleView *blueCircleView;	//overlay GPS location
	IBOutlet MapMarkerTouchView *markerTouchView;	//overlay for market touches
	RMMapContents		*mapContents;
	
	InitialLocation *initialLocation;
	CLLocationManager *locationManager; //move out of this class into app, or app sub, if/when we generalise.
	CLLocation *lastLocation;		//the last one
	
	MapLocationSearchViewController *mapLocationSearchView;			//the search popup
	
	RouteVO *route;					//current route
	
	RMMarker *start;
	RMMarker *end;
	RMMarker *activeMarker;
	NSMutableArray *startEndPool;//work around release/retain problem on Markers, only visible on 3.1.3.
	
	//lots of state flags. Needs a refactor. Turn everything into planningState ?
	BOOL doingLocation;
	BOOL programmaticChange;
	
	BOOL	avoidAccidentalTaps;
	BOOL	singleTapDidOccur;
	CGPoint	singleTapPoint;
	
	UIAlertView *firstAlert;
	UIAlertView *clearAlert;
	UIAlertView *startFinishAlert;
	UIAlertView *noLocationAlert;
	
	PlanningState planningState;
	
	// popover support
	WEPopoverController *routeplanMenu;
	Class popoverClass;
	
}
@property (nonatomic, strong) IBOutlet UIToolbar		* toolBar;
@property (nonatomic, strong) UIBarButtonItem		* locationButton;
@property (nonatomic, strong) UIBarButtonItem		* activeLocationButton;
@property (nonatomic, strong) UIBarButtonItem		* nameButton;
@property (nonatomic, strong) UIBarButtonItem		* routeButton;
@property (nonatomic, strong) UIBarButtonItem		* deleteButton;
@property (nonatomic, strong) UIBarButtonItem		* planButton;
@property (nonatomic, strong) UIBarButtonItem		* startContextLabel;
@property (nonatomic, strong) UIBarButtonItem		* finishContextLabel;
@property (nonatomic, strong) UIActivityIndicatorView		* locatingIndicator;
@property (nonatomic, strong) UIBarButtonItem		* leftFlex;
@property (nonatomic, strong) UIBarButtonItem		* rightFlex;
@property (nonatomic, strong) RoutePlanMenuViewController		* routeplanView;
@property (nonatomic, strong) IBOutlet UILabel		* attributionLabel;
@property (nonatomic, strong) CycleStreets		* cycleStreets;
@property (nonatomic, strong) IBOutlet RMMapView		* mapView;
@property (nonatomic, strong) IBOutlet RouteLineView		* lineView;
@property (nonatomic, strong) IBOutlet BlueCircleView		* blueCircleView;
@property (nonatomic, strong) IBOutlet MapMarkerTouchView		* markerTouchView;
@property (nonatomic, strong) RMMapContents		* mapContents;
@property (nonatomic, strong) InitialLocation		* initialLocation;
@property (nonatomic, strong) CLLocationManager		* locationManager;
@property (nonatomic, strong) CLLocation		* lastLocation;
@property (nonatomic, strong) MapLocationSearchViewController		* mapLocationSearchView;
@property (nonatomic, strong) RouteVO		* route;
@property (nonatomic, strong) RMMarker		* start;
@property (nonatomic, strong) RMMarker		* end;
@property (nonatomic, strong) RMMarker		* activeMarker;
@property (nonatomic, strong) NSMutableArray		* startEndPool;
@property (nonatomic, assign) BOOL		 doingLocation;
@property (nonatomic, assign) BOOL		 programmaticChange;
@property (nonatomic, assign) BOOL		 avoidAccidentalTaps;
@property (nonatomic, assign) BOOL		 singleTapDidOccur;
@property (nonatomic, assign) CGPoint		 singleTapPoint;
@property (nonatomic, strong) UIAlertView		* firstAlert;
@property (nonatomic, strong) UIAlertView		* clearAlert;
@property (nonatomic, strong) UIAlertView		* startFinishAlert;
@property (nonatomic, strong) UIAlertView		* noLocationAlert;
@property (nonatomic, assign) PlanningState		 planningState;
@property (nonatomic, strong) WEPopoverController		* routeplanMenu;


- (IBAction) didZoomIn;
- (IBAction) didZoomOut;
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
