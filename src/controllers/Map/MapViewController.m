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

//  Map.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//


#import "MapViewController.h"
#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Query.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "Route.h"
#import "Segment.h"
#import <CoreLocation/CoreLocation.h>
#import "RMCloudMadeMapSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMOpenCycleMapSource.h"
#import "RMOrdnanceSurveyStreetViewMapSource.h"
#import "RMTileSource.h"
#import "RMCachedTileSource.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "QueryPhoto.h"
#import "Markers.h"
#import "MapLocationSearchViewController.h"
#import "RMMapView.h"
#import "CSPointVO.h"
#import "RouteLineView.h"
#import "RMMercatorToScreenProjection.h"
#import "Files.h"
#import "InitialLocation.h"
#import "RouteManager.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "POIListviewController.h"
#import "HudManager.h"

@interface MapViewController(Private)

-(void)initToolBarEntries;

- (void) addLocation:(CLLocationCoordinate2D)location;
-(void)updateSelectedRoute;
- (void)gotoState:(PlanningState)newPlanningState;

// saved map loaction loading, separate from savedRoute
- (void)saveLocation:(CLLocationCoordinate2D)location;
- (void)zoomUpdate;
-(void)loadLocation;


-(IBAction)showRoutePlanMenu:(id)sender;
-(void)didSelectNewRoutePlan:(NSDictionary*)dict;

- (void) clearRoute;
- (void) newRoute;
- (void) clearMarkers;

@end

static NSString *MAPPING_BASE_OPENCYCLEMAP = @"OpenCycleMap";
static NSString *MAPPING_BASE_OSM = @"OpenStreetMap";
static NSString *MAPPING_BASE_OS = @"OS";

static NSString *MAPPING_ATTRIBUTION_OPENCYCLEMAP = @"(c) OpenStreetMap and contributors, CC-BY-SA; Map images (c) OpenCycleMap";
static NSString *MAPPING_ATTRIBUTION_OSM = @"(c) OpenStreetMap and contributors, CC-BY-SA";
static NSString *MAPPING_ATTRIBUTION_OS = @"Contains Ordnance Survey data (c) Crown copyright and database right 2010";

static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSInteger MAX_ZOOM_LOCATION = 16;
static NSInteger MAX_ZOOM_LOCATION_ACCURACY = 200;

static CLLocationDistance LOC_DISTANCE_FILTER = 25;
static NSTimeInterval ACCIDENTAL_TAP_DELAY = 0.5;

//don't allow co-location of start/finish
static CLLocationDistance MIN_START_FINISH_DISTANCE = 100;


@implementation MapViewController
@synthesize toolBar;
@synthesize locationButton;
@synthesize activeLocationButton;
@synthesize nameButton;
@synthesize routeButton;
@synthesize deleteButton;
@synthesize planButton;
@synthesize startContextLabel;
@synthesize finishContextLabel;
@synthesize locatingIndicator;
@synthesize leftFlex;
@synthesize rightFlex;
@synthesize routeplanView;
@synthesize attributionLabel;
@synthesize cycleStreets;
@synthesize mapView;
@synthesize lineView;
@synthesize blueCircleView;
@synthesize mapContents;
@synthesize initialLocation;
@synthesize locationManager;
@synthesize lastLocation;
@synthesize mapLocationSearchView;
@synthesize route;
@synthesize start;
@synthesize end;
@synthesize startEndPool;
@synthesize doingLocation;
@synthesize programmaticChange;
@synthesize avoidAccidentalTaps;
@synthesize singleTapDidOccur;
@synthesize singleTapPoint;
@synthesize firstAlert;
@synthesize clearAlert;
@synthesize startFinishAlert;
@synthesize noLocationAlert;
@synthesize planningState;
@synthesize routeplanMenu;
@synthesize activeMarker;



//
/***********************************************
 * @description			CLASS METHODS
 ***********************************************/
//


+ (NSArray *)mapStyles {
	return [NSArray arrayWithObjects:MAPPING_BASE_OSM, MAPPING_BASE_OPENCYCLEMAP, MAPPING_BASE_OS,nil];
}

+ (NSString *)currentMapStyle {
	NSString *mapStyle = [SettingsManager sharedInstance].dataProvider.mapStyle;
	if (mapStyle == nil) {
		mapStyle = [[MapViewController mapStyles] objectAtIndex:0];
	}
	
	return mapStyle;
}

+ (NSString *)mapAttribution {
	NSString *mapStyle = [MapViewController currentMapStyle];
	NSString *mapAttribution = nil;
	if ([mapStyle isEqualToString:MAPPING_BASE_OSM]) {
		mapAttribution = MAPPING_ATTRIBUTION_OSM;
	} else if ([mapStyle isEqualToString:MAPPING_BASE_OPENCYCLEMAP]) {
		mapAttribution = MAPPING_ATTRIBUTION_OPENCYCLEMAP;
	}else if ([mapStyle isEqualToString:MAPPING_BASE_OS]) {
		mapAttribution = MAPPING_ATTRIBUTION_OS;
	}
	return mapAttribution;
}

+ ( NSObject <RMTileSource> *)tileSource {
	NSString *mapStyle = [MapViewController currentMapStyle];
	NSObject <RMTileSource> *tileSource;
	if ([mapStyle isEqualToString:MAPPING_BASE_OSM])
	{
		tileSource = [[RMOpenStreetMapSource alloc] init];
	}
	else if ([mapStyle isEqualToString:MAPPING_BASE_OPENCYCLEMAP])
	{
		//open cycle map
		tileSource = [[RMOpenCycleMapSource alloc] init];
	}
	else if ([mapStyle isEqualToString:MAPPING_BASE_OS])
	{
		//Ordnance Survey
		tileSource = [[RMOrdnanceSurveyStreetViewMapSource alloc] init];
	}
	else
	{
		//default to MAPPING_BASE_OSM.
		tileSource = [[RMOpenStreetMapSource alloc] init];
	}
	return tileSource;
}

+ (void)zoomMapView:(RMMapView *)mapView toLocation:(CLLocation *)newLocation {
	CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
	if (accuracy < 0) {
		accuracy = 2000;
	}
	int wantZoom = MAX_ZOOM_LOCATION;
	CLLocationAccuracy wantAccuracy = MAX_ZOOM_LOCATION_ACCURACY;
	while (wantAccuracy < accuracy) {
		wantZoom--;
		wantAccuracy = wantAccuracy * 2;
	}
	BetterLog(@"accuracy %f zoom %d", accuracy, wantZoom);
	[mapView moveToLatLong: newLocation.coordinate];
	[mapView.contents setZoom:wantZoom];
}


//
/***********************************************
 * @description			END CLASS METHODS
 ***********************************************/
//


- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.cycleStreets = [CycleStreets sharedInstance];
	popoverClass = [WEPopoverController class];
	
	
	[self initToolBarEntries];
	
	
	self.clearAlert = [[UIAlertView alloc]
					   initWithTitle:@"CycleStreets"
					   message:@"Clear current route?"
					   delegate:self
					   cancelButtonTitle:@"Cancel"
					   otherButtonTitles:@"OK", nil];
	
	//Necessary to start route-me service
	[RMMapView class];
	
	//get the configured map source.
	self.mapContents=[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]];
	
	
	// Initialize
	[mapView setDelegate:self];
	
	if (initialLocation == nil) {
		self.initialLocation = [[InitialLocation alloc] initWithMapView:mapView withController:self];
	}
	[initialLocation performSelector:@selector(initiateLocation) withObject:nil afterDelay:0.0];
	
	//clear up from last run.
	[self clearMarkers];
	
	//provide the points the line overlay needs, when it needs them, in screen co-ordinates
	[lineView setPointListProvider:self];
	
	[blueCircleView setLocationProvider:self];
	
	//set up the location manager.
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy=500;
	doingLocation = NO;
	
	self.programmaticChange = NO;
	singleTapDidOccur=NO;
	
	self.attributionLabel.text = [MapViewController mapAttribution];
	
	[self gotoState:stateStart];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didNotificationMapStyleChanged)
												 name:@"NotificationMapStyleChanged"
											   object:nil];	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateSelectedRoute)
												 name:CSROUTESELECTED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSelectNewRoutePlan:)
												 name:EVENTMAPROUTEPLAN
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadLocation)
												 name:CSLASTLOCATIONLOAD
											   object:nil];
	
	
	[[RouteManager sharedInstance] loadSavedSelectedRoute];
	
	
}


-(void)initToolBarEntries{
	
	
	self.locatingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	locatingIndicator.hidesWhenStopped=YES;
	
	self.activeLocationButton = [[UIBarButtonItem alloc] initWithCustomView:locatingIndicator ];
	self.activeLocationButton.style	= UIBarButtonItemStyleDone;
	
	self.locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_location_white.png"]
														   style:UIBarButtonItemStyleBordered
														  target:self
														  action:@selector(didLocation)];
	self.locationButton.width = 40;
	
	self.nameButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_search_white.png"]
													   style:UIBarButtonItemStyleBordered
													  target:self
													  action:@selector(didSearch)];
	self.nameButton.width = 40;
	
	self.deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_deletePoint_white.png"]
														 style:UIBarButtonItemStyleBordered
														target:self
														action:@selector(didDelete)];
	self.deleteButton.width = 40;
    
    self.planButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_routePlan_white.png"]
													   style:UIBarButtonItemStyleBordered
													  target:self
													  action:@selector(showRoutePlanMenu:)];
	self.planButton.width = 40;
	
	self.routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Plan Route" 
														style:UIBarButtonItemStyleBordered
													   target:self
													   action:@selector(didRoute)];
	
	ExpandedUILabel *startLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 14)];
	startLabel.text=@"Set Start";
	startLabel.font=[UIFont boldSystemFontOfSize:20];
	startLabel.shadowOffset=CGSizeMake(0, -1);
	startLabel.shadowColor=[UIColor darkGrayColor];
	startLabel.textColor=[UIColor whiteColor];
	self.startContextLabel=[[UIBarButtonItem alloc] initWithCustomView:startLabel];
	
	ExpandedUILabel *finishLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 14)];
	finishLabel.text=@"Set Finish";
	finishLabel.font=[UIFont boldSystemFontOfSize:20];
	finishLabel.shadowOffset=CGSizeMake(0, -1);
	finishLabel.shadowColor=[UIColor darkGrayColor];
	finishLabel.textColor=[UIColor whiteColor];
	self.finishContextLabel=[[UIBarButtonItem alloc] initWithCustomView:finishLabel];
	
	
	self.leftFlex=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	self.rightFlex=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
}



- (void) didNotificationMapStyleChanged {
	mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}

- (void)gotoState:(PlanningState)newPlanningState {
	
	BetterLog(@"changing state to %i",newPlanningState);
	
	self.planningState = newPlanningState;
	
	NSMutableArray *items;
	
	switch (self.planningState) {
		case stateStart:
			BetterLog(@"stateStart");
			
			
			items=[NSMutableArray arrayWithObjects:locationButton,nameButton,deleteButton, leftFlex, startContextLabel, rightFlex, nil];
			[self.toolBar setItems:items animated:YES ];
			
			self.deleteButton.enabled = NO;
			self.nameButton.enabled = YES;
			
			
			break;
		case stateLocatingStart:
			break;
		case stateEnd:
			BetterLog(@"stateEnd");
			
			
			self.deleteButton.enabled = YES;
			self.nameButton.enabled = YES;
			
			items=[NSMutableArray arrayWithObjects:locationButton,nameButton,deleteButton, leftFlex, finishContextLabel, rightFlex, nil];
			[self.toolBar setItems:items animated:YES ];
			
			
			break;
		case stateLocatingEnd:
			
			break;
		case statePlan:
			BetterLog(@"statePlan");
			
			self.routeButton.title = @"Plan route";
			self.routeButton.style = UIBarButtonItemStyleDone;
			self.deleteButton.enabled = YES;
			self.nameButton.enabled = NO;
			
			items=[NSMutableArray arrayWithObjects:locationButton,nameButton,deleteButton,leftFlex, routeButton, nil];
            
            [self.toolBar setItems:items animated:YES ];
			
			break;
		case stateRoute:
			BetterLog(@"stateRoute");
			
			self.routeButton.title = @"New route";
			self.routeButton.style = UIBarButtonItemStyleBordered;
			self.deleteButton.enabled = NO;
			self.nameButton.enabled = NO;
			items=[NSMutableArray arrayWithObjects:locationButton,nameButton,deleteButton,leftFlex, planButton,routeButton, nil];
            
            [self.toolBar setItems:items animated:NO ];
			
			break;
	}
}

- (void) clearMarkers {
	if ([[mapView.markerManager markers] containsObject:self.end]) {
		[mapView.markerManager removeMarker:self.end];
	}
	if ([[mapView.markerManager markers] containsObject:self.start]) {
		[mapView.markerManager removeMarker:self.start];
	}
}





#pragma mark RMMap delegates
//
/***********************************************
 * @description			RM MAP delegate methods
 ***********************************************/
//

- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point {
	
	if(singleTapDidOccur==NO){
		singleTapDidOccur=YES;
		singleTapPoint=point;
		[self performSelector:@selector(singleTapDelayExpired) withObject:nil afterDelay:ACCIDENTAL_TAP_DELAY];
		
	}
}

-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
	singleTapDidOccur=NO;
	
	float nextZoomFactor = [map.contents nextNativeZoomFactor];
	if (nextZoomFactor != 0)
		[map zoomByFactor:nextZoomFactor near:point animated:YES];
	
}


- (void) singleTapDelayExpired {
	if(singleTapDidOccur==YES){
		singleTapDidOccur=NO;
		CLLocationCoordinate2D location = [mapView pixelToLatLong:singleTapPoint];
		[self addLocation:location];
	}
}


- (void) afterMapChanged: (RMMapView*) map {
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	
	if (!self.programmaticChange) {
		//BetterLog(@"afterMapChanged, autolocating=NO, [self stopDoingLocation]");
		if (self.planningState == stateLocatingStart || self.planningState == stateLocatingEnd) {
			[self stopDoingLocation];
		}
	} else {
		//BetterLog(@"afterMapChanged, autolocating=YES");
	}
}


- (void) afterMapMove: (RMMapView*) map {
	[self afterMapChanged:map];
}

-(void)afterMapTouch:(RMMapView *)map{
	
	map.enableDragging=YES;
	
}


- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    
	[self afterMapChanged:map];
	[self saveLocation:map.contents.mapCenter];
}


#pragma marl RMMap marker

-(void)tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map{
	
	// for marker pop ups
	
}

// Should only return yes if marker is start/end and we have not a route drawn
- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	BetterLog(@"self.planningState=%i ",self.planningState);
	
	BOOL result=NO;
	
	if(self.planningState!=stateRoute){
		
		if (marker == start || marker == end) {
			activeMarker=marker;
			result=YES;
		}else{
			activeMarker=nil;
		}
		
	}
	
	mapView.enableDragging=!result;
	return result;
}


// we know we have touch began on marker markerdrag=yes;
// we know whne touch ended is not on marker
// if markerdrag==yes > re enable map drag
// we also know if markerdrag is yes and we start getting RMLayerCollection objects we should still be sending markerdrag data via didDragMarker


// NE: bug here where it's posible to lose the touch on the market by moving quickly
// will execute touchEnded
- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	NSSet *touches = [event touchesForView:blueCircleView]; 
	// note use of top View required, bcv should not be left top unless required by location?
	
	BetterLog(@"touches=%i",[touches count]);
	BetterLog(@"activeMarker=%@",activeMarker);
	
	for (UITouch *touch in touches) {
		CGPoint point = [touch locationInView:blueCircleView];
		CLLocationCoordinate2D location = [map pixelToLatLong:point];
		[[map markerManager] moveMarker:activeMarker AtLatLon:location];
	}
	
}



#pragma mark map location persistence
//
/***********************************************
 * @description			Saves Map location
 ***********************************************/
//

- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", mapView.contents.zoom] forKey:@"zoom"];
	[cycleStreets.files setMisc:misc];	
}

//
/***********************************************
 * @description			Loads any saved map lat/long and zoom
 ***********************************************/
//
-(void)loadLocation{
	
	BetterLog(@"");
	
	NSDictionary *misc = [cycleStreets.files misc];
	NSString *sLat = [misc valueForKey:@"latitude"];
	NSString *sLon = [misc valueForKey:@"longitude"];
	NSString *sZoom = [misc valueForKey:@"zoom"];
	
	CLLocationCoordinate2D initLocation;
	if (sLat != nil && sLon != nil) {
		initLocation.latitude = [sLat doubleValue];
		initLocation.longitude = [sLon doubleValue];
		[self.mapView moveToLatLong:initLocation];
		
		if ([mapView.contents zoom] < MAX_ZOOM) {
			[mapView.contents setZoom:[sZoom floatValue]];
		}
		[self zoomUpdate]; 
	}
}

- (BOOL)locationInBounds:(CLLocationCoordinate2D)location {
	CGRect bounds = mapView.contents.screenBounds;
	CLLocationCoordinate2D nw = [mapView pixelToLatLong:bounds.origin];
	CLLocationCoordinate2D se = [mapView pixelToLatLong:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
	
	if (nw.latitude < location.latitude) return NO;
	if (nw.longitude > location.longitude) return NO;
	if (se.latitude > location.latitude) return NO;
	if (se.longitude < location.longitude) return NO;
	
	return YES;
}

- (void)cancelAlert:(UIAlertView *)alert {
	BetterLog(@">>>");
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) firstAlert:(NSString *)message {
	
    [[HudManager sharedInstance] showHudWithType:HUDWindowTypeNone withTitle:message andMessage:nil];
}

- (void) showStartFinishAlert {
	if (self.startFinishAlert == nil) {
		self.startFinishAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
														   message:@"Move the map to set a finish point further away."
														  delegate:self
												 cancelButtonTitle:nil
												 otherButtonTitles:nil];
	}
	[self stopDoingLocation];
	[self.startFinishAlert show];
	[self performSelector:@selector(cancelAlert:) withObject:self.startFinishAlert afterDelay:2.0];
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (CLLocationDistance) distanceFromStart:(CLLocationCoordinate2D)locationLatLon {
	CLLocationCoordinate2D fromLatLon = [[mapView markerManager] latitudeLongitudeForMarker:start];
	CLLocation *from = [[CLLocation alloc] initWithLatitude:fromLatLon.latitude
												  longitude:fromLatLon.longitude];
	CLLocation *to = [[CLLocation alloc] initWithLatitude:locationLatLon.latitude
												longitude:locationLatLon.longitude];
	CLLocationDistance distance = [from getDistanceFrom:to];
	return distance;
}

- (void) startMarker:(CLLocationCoordinate2D)location {
	if (!self.start) {
		self.start = [Markers markerStart];
		self.start.enableDragging=YES;
	}
	if ([[self.mapView.markerManager markers] containsObject:self.start]) {
		[self.mapView.markerManager moveMarker:self.start AtLatLon:location];
	} else {
		[self.mapView.markerManager addMarker:self.start AtLatLong:location];
	}
}

- (void) endMarker:(CLLocationCoordinate2D)location {
	if (!self.end) {
		self.end = [Markers markerEnd];
	}
	if ([[self.mapView.markerManager markers] containsObject:self.end]) {
		[self.mapView.markerManager moveMarker:self.end AtLatLon:location];
	} else {
		[self.mapView.markerManager addMarker:self.end AtLatLong:location];
	}
}

// Use stateXXX and the existence of a marker, to decide whether we should be moving the marker,
// or adding a new one.
- (void) addLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"addLocation");
	
	//end is too near start, and is being done by autolocation.
	if (self.programmaticChange && self.planningState == stateLocatingEnd) {
		CLLocationDistance distanceFromStart = [self distanceFromStart:location];
		if (distanceFromStart < MIN_START_FINISH_DISTANCE) {
            [[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Point error" andMessage:@"Move the map to set a finish point further away."];
			[self gotoState:stateEnd];
			return;
		}
	}
	
	BetterLog(@"");
	
	//explicit click while autolocation was happening. Turn off auto, accept click.
	if (!self.programmaticChange) {
		if (self.planningState == stateLocatingEnd || self.planningState == stateLocatingStart) {
			[self performSelector:@selector(stopDoingLocation) withObject:nil afterDelay:0.0];
		}
	}
	
	
	
	//endpoint, whether autolocated or not.
	if (self.planningState == stateEnd || self.planningState == stateLocatingEnd) {
		[self endMarker:location];
		
		if ([SettingsManager sharedInstance].dataProvider.showRoutePoint==YES) {
            
            [[HudManager sharedInstance] showHudWithType:HUDWindowTypeIcon withTitle:@"Finish point set." andMessage:@"CSIcon_finish_wisp.png"];
		}
		if (self.planningState == stateEnd) {
			[self gotoState:statePlan];
		}		
	}
	
	//startpoint, whether autolocated or not.
	if (self.planningState == stateStart || self.planningState == stateLocatingStart) {
		[self startMarker:location];
		if ([SettingsManager sharedInstance].dataProvider.showRoutePoint==YES) {
            [[HudManager sharedInstance] showHudWithType:HUDWindowTypeIcon withTitle:@"Start point set." andMessage:@"CSIcon_start_wisp.png"];
		}
		if (self.planningState == stateStart) {
			[self gotoState:stateEnd];
		}
	}
	
	[self saveLocation:location];
}





#pragma mark toolbar actions

- (void)zoomUpdate {
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	[self stopDoingLocation];
}

- (IBAction) didZoomIn {
	BetterLog(@"zoomin");
	if ([mapView.contents zoom] < MAX_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] + 1];
	}
	[self zoomUpdate];
}

- (IBAction) didZoomOut {
	BetterLog(@"zoomout");
	if ([mapView.contents zoom] > MIN_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] - 1];
	}
	[self zoomUpdate];
}

- (void) didLocation {
	[self startDoingLocation];
}

- (void) didActiveLocation {
	[self stopDoingLocation];
}

- (IBAction) didSearch {
	
	// The data set is not ready for use.
	//POIListviewController *lv=[[POIListviewController alloc]initWithNibName:[POIListviewController nibName] bundle:nil];
	
	if (mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}
	mapLocationSearchView.locationReceiver = self;
	mapLocationSearchView.centreLocation = [[mapView contents] mapCenter];
	
	[self presentModalViewController:mapLocationSearchView	animated:YES];
	
}

//delete the last point, either start or end.
- (IBAction) didDelete {
	
	RMMarkerManager *markerManager = [mapView markerManager];
	
	if ([[markerManager markers] containsObject:self.end]) {
		[markerManager removeMarker:self.end];
		[self gotoState:stateEnd];
	} else {
		[markerManager removeMarker:self.start];
		[self gotoState:stateStart];
	}
}

- (IBAction) didRoute {
	BetterLog(@"route");
	
	if (self.planningState == statePlan) {
		RMMarkerManager *markerManager = [mapView markerManager];
		if (![[markerManager markers] containsObject:self.end] || ![[markerManager markers] containsObject:self.start]) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Routing"
															message:@"Need start and end markers to calculate a route."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			
		}
		
		
		
		
		CLLocationCoordinate2D fromLatLon = [markerManager latitudeLongitudeForMarker:start];
		CLLocation *from = [[CLLocation alloc] initWithLatitude:fromLatLon.latitude longitude:fromLatLon.longitude];
		CLLocationCoordinate2D toLatLon = [markerManager latitudeLongitudeForMarker:end];
		CLLocation *to = [[CLLocation alloc] initWithLatitude:toLatLon.latitude longitude:toLatLon.longitude];
		
		[[RouteManager sharedInstance] loadRouteForEndPoints:from to:to];
		
	} else if (self.planningState == stateRoute) {
		[self.clearAlert show];
	}
}



//
/***********************************************
 * @description			ROUTE PLAN POPUP METHODS
 ***********************************************/
//	

-(IBAction)showRoutePlanMenu:(id)sender{
	
    self.routeplanView=[[RoutePlanMenuViewController alloc]initWithNibName:@"RoutePlanMenuView" bundle:nil];
	routeplanView.plan=route.plan;
    
	self.routeplanMenu = [[popoverClass alloc] initWithContentViewController:routeplanView];
	self.routeplanMenu.delegate = self;
	
	[self.routeplanMenu presentPopoverFromBarButtonItem:planButton toolBar:toolBar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
	
}


-(void)didSelectNewRoutePlan:(NSNotification*)notification{
	
	NSDictionary *userInfo=notification.userInfo;
	
	[[RouteManager sharedInstance] loadRouteForRouteId:route.routeid withPlan:[userInfo objectForKey:@"planType"]];
	
	[routeplanMenu dismissPopoverAnimated:YES];
	
}


#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.routeplanMenu = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}



#pragma mark CoreLocation

- (void)stopDoingLocation {
	BetterLog(@"doingLocation=%i",doingLocation);
	
	if (!doingLocation) {
		return;
	}
	if (doingLocation) {
		BetterLog(@"");
		doingLocation = NO;
		locationButton.style = UIBarButtonItemStyleBordered;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
		[locationManager stopUpdatingLocation];
		
		[blueCircleView setNeedsDisplay];
		[UIView animateWithDuration:1.2f 
							  delay:.5 
							options:UIViewAnimationCurveEaseOut 
						 animations:^{ 
							 blueCircleView.alpha=0;
						 }
						 completion:^(BOOL finished){
						 }];
		
		[locatingIndicator stopAnimating];
		NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolBar.items];
		[items removeObjectAtIndex:0];
		[items insertObject:self.locationButton atIndex:0];
		self.toolBar.items = items;
		
		//Don't affect the state if we "just wanted to know our location".
		if (self.planningState == statePlan || self.planningState == stateRoute) {
			return;
		}
		
		//We used the location to find an endpoint, so now increment the state.
		if (self.planningState == stateLocatingEnd) {
			if (self.end) {
				[self gotoState:statePlan];
			} else {
				[self gotoState:stateEnd];
			}
		}
		
		if (self.planningState == stateLocatingStart) {
			if (self.start) {
				[self gotoState:stateEnd];
			} else {
				[self gotoState:stateStart];
			}
		}
	}
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)startDoingLocation {
	if (!doingLocation) {
		
		if(locationManager.locationServicesEnabled==YES){
			
			//nil the lastLocation so that the accuracy refining occurs for this request
			self.lastLocation=nil;
			
			doingLocation = YES;
			locationManager.delegate = self;
			locationManager.distanceFilter = LOC_DISTANCE_FILTER;
			
			[locationManager startUpdatingLocation];
			blueCircleView.alpha=0.5;
			
			
			NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolBar.items];
			[items removeObjectAtIndex:0];
			[items insertObject:self.activeLocationButton atIndex:0];
			[locatingIndicator startAnimating];
			self.toolBar.items = items;
			
			if (self.planningState == stateStart) {
				[self gotoState:stateLocatingStart];
			}
			if (self.planningState == stateEnd) {
				[self gotoState:stateLocatingEnd];
			}
		}else {
			
			UIAlertView *gpsAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
															   message:@"Location services for CycleStreets are off, please enable in Settings > General > Location Services to use location based features."
															  delegate:self
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
			[gpsAlert show];
			
		}
		
	}
}


#pragma mark location delegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	
	
	
	
	// Note: we need to doublecheck this flag as this method appears to get called
	// once even after we have told it to stop!
	// if left un checked it will call addLocation too many times for a planning session
	if(doingLocation==YES){
		
		self.programmaticChange = YES;
		
		BetterLog(@"newLocation.horizontalAccuracy=%f",newLocation.horizontalAccuracy);
		BetterLog(@"locationManager.desiredAccuracy=%f",locationManager.desiredAccuracy);
		
		[MapViewController zoomMapView:mapView toLocation:newLocation];
		[blueCircleView setNeedsDisplay];
		
		NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
		
		if (locationAge > 5.0) return;
		if (newLocation.horizontalAccuracy < 0) return;
		// test the measurement to see if it is more accurate than the previous measurement
		if (lastLocation == nil || lastLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
			// store the location as the "best effort"
			self.lastLocation = newLocation;
			
			// if we reach accuracy we switch off gps and add a start||finish point
			if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
				
				[self addLocation:newLocation.coordinate];
				[self stopDoingLocation];
				
			}
			
		}
		
		
		self.programmaticChange = NO;
		
	}
	
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	if (self.noLocationAlert == nil) {
		self.noLocationAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
														  message:@"Unable to retrieve location. Location services for CycleStreets may be off, please enable in Settings > General > Location Services to use location based features."
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
	}
	[self.noLocationAlert show];
}



#pragma mark Route Display
//
/***********************************************
 * @description			Route loading
 ***********************************************/
//	

-(void)updateSelectedRoute{
	
	BetterLog(@"");
	[self showRoute:[RouteManager sharedInstance].selectedRoute];
}

- (void) showRoute:(RouteVO *)newRoute {
	
	BetterLog(@"route=%@",newRoute);
	
	self.route = newRoute;
	
	if (route == nil || [route numSegments] == 0) {
		[self clearRoute];
	} else {
		[self newRoute];
	}
}

- (void) clearRoute {
	self.route = nil;
	[self clearMarkers];
	[self stopDoingLocation];
	
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	
	[self gotoState:stateStart];
	
	[[RouteManager sharedInstance] clearSelectedRoute];
}

- (void) newRoute {
	
	BetterLog(@"");
	CLLocationCoordinate2D ne=[route insetNorthEast];
	CLLocationCoordinate2D sw=[route insetSouthWest];
	[mapView zoomWithLatLngBoundsNorthEast:ne SouthWest:sw];
	
	[self clearMarkers];
	[self stopDoingLocation];
	
	CLLocationCoordinate2D startLocation = [[route segmentAtIndex:0] segmentStart];
	[self startMarker:startLocation];
	CLLocationCoordinate2D endLocation = [[route segmentAtIndex:[route numSegments] - 1] segmentEnd];
	[self endMarker:endLocation];
	
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	[self gotoState:stateRoute];
}







// List of points in display co-ordinates for the route highlighting.
+ (NSArray *) pointList:(RouteVO *)route withView:(RMMapView *)mapView {
	
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:10];
	if (route == nil) {
		return points;
	}
	
	for (int i = 0; i < [route numSegments]; i++) {
		if (i == 0)
		{	// start of first segment
			CSPointVO *p = [[CSPointVO alloc] init];
			SegmentVO *segment = [route segmentAtIndex:i];
			CLLocationCoordinate2D coordinate = [segment segmentStart];
			CGPoint pt = [mapView.contents latLongToPixel:coordinate];
			p.p = pt;
			[points addObject:p];			
		}
		// remainder of all segments
		SegmentVO *segment = [route segmentAtIndex:i];
		NSArray *allPoints = [segment allPoints];
		for (int i = 1; i < [allPoints count]; i++) {
			CSPointVO *latlon = [allPoints objectAtIndex:i];
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = latlon.p.y;
			coordinate.longitude = latlon.p.x;
			CGPoint pt = [mapView.contents latLongToPixel:coordinate];
			CSPointVO *screen = [[CSPointVO alloc] init];
			screen.p = pt;
			[points addObject:screen];
		}
	}	
	/*
	 for (int i = 0; i < [route numSegments]; i++) {
	 if (i == 0)
	 {	// start of first segment
	 CSPoint *p = [[[CSPoint alloc] init] autorelease];
	 Segment *segment = [route segmentAtIndex:i];
	 CGPoint pt = [mapView.contents latLongToPixel:[segment segmentStart]];
	 p.p = pt;
	 [points addObject:p];			
	 }
	 // end of all segments
	 CSPoint *p = [[[CSPoint alloc] init] autorelease];
	 Segment *segment = [route segmentAtIndex:i];
	 CGPoint pt = [mapView.contents latLongToPixel:[segment segmentEnd]];
	 p.p = pt;
	 [points addObject:p];
	 }
	 */
	return points;
}

- (NSArray *) pointList {
	return [MapViewController pointList:route withView:mapView];
}

#pragma mark handle alert dismissal

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView == self.clearAlert) {
		if (buttonIndex == self.clearAlert.cancelButtonIndex) {
			//Cancelled. Keep state the same.
		} else {
			//OK
			[[RouteManager sharedInstance] selectRoute:nil];
		}
		
	}
	
	if (alertView == self.noLocationAlert) {
		[self stopDoingLocation];
	}
}

#pragma mark location provider

- (float)getX {
	CGPoint p = [mapView.contents latLongToPixel:lastLocation.coordinate];
	return p.x;
}

- (float)getY {
	CGPoint p = [mapView.contents latLongToPixel:lastLocation.coordinate];
	return p.y;
}

- (float)getRadius {
	
	double metresPerPixel = [mapView.contents metersPerPixel];
	float locationRadius=(lastLocation.horizontalAccuracy / metresPerPixel);
	
	return MAX(locationRadius, 40.0f);
}



#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	[mapView moveToLatLong: location];
	[self addLocation:location];
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	[self stopDoingLocation];
}

#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)nullify {
	self.locationButton = nil;
	self.activeLocationButton = nil;
	self.locatingIndicator = nil;
	self.nameButton = nil;
	self.routeButton = nil;
	self.deleteButton = nil;
	self.attributionLabel = nil;
	
	cycleStreets = nil;
	mapView = nil;
	
	self.lineView = nil;
	self.blueCircleView = nil;
	
	locationManager = nil;
	lastLocation = nil;
	
	mapLocationSearchView = nil;
	route = nil;
	
	initialLocation = nil;
	
	self.firstAlert = nil;
	self.clearAlert = nil;
	self.startFinishAlert = nil;
	
	[self clearMarkers];
}

- (void)viewDidUnload {
	[self nullify];
    [super viewDidUnload];
}





@end