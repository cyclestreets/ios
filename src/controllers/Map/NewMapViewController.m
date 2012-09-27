//
//  NewMapViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 26/09/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "NewMapViewController.h"
#import "GlobalUtilities.h"
#import "RMMapView.h"
#import "RoutePlanMenuViewController.h"
#import "ExpandedUILabel.h"
#import "MapMarkerTouchView.h"
#import "CSPointVO.h"
#import "SegmentVO.h"
#import "SettingsManager.h"

#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "RMOpenStreetMapSource.h"
#import "RMOpenCycleMapSource.h"
#import "RMOrdnanceSurveyStreetViewMapSource.h"
#import "RMTileSource.h"
#import "RMCachedTileSource.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "Markers.h"
#import "MapLocationSearchViewController.h"
#import "RMMapView.h"
#import "CSPointVO.h"
#import "RMMercatorToScreenProjection.h"
#import "Files.h"
#import "InitialLocation.h"
#import "RouteManager.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "POIListviewController.h"
#import "HudManager.h"


static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSInteger MAX_ZOOM_LOCATION = 16;
static NSInteger MAX_ZOOM_LOCATION_ACCURACY = 200;

static CLLocationDistance LOC_DISTANCE_FILTER = 25;
static NSTimeInterval ACCIDENTAL_TAP_DELAY = 0.5;

//don't allow co-location of start/finish
static CLLocationDistance MIN_START_FINISH_DISTANCE = 100;

static NSString *const LOCATIONSUBSCRIBERID=@"MapView";



@interface NewMapViewController(Private)

// tool bar
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

//rmmap
@property (nonatomic, strong) IBOutlet RMMapView		* mapView;
@property (nonatomic, strong) RMMapContents		* mapContents;
@property (nonatomic, strong) CLLocation		* lastLocation;

// sub views
@property (nonatomic, strong) RoutePlanMenuViewController		* routeplanView;
@property (nonatomic, strong) WEPopoverController		* routeplanMenu;
@property (nonatomic, strong) MapLocationSearchViewController		* mapLocationSearchView;

// ui
@property (nonatomic, strong) IBOutlet UILabel		* attributionLabel;
@property (nonatomic, strong) IBOutlet RouteLineView		* lineView;
@property (nonatomic, strong) IBOutlet BlueCircleView		* blueCircleView;
@property (nonatomic, strong) IBOutlet MapMarkerTouchView		* markerTouchView;

// waypoint ui
// will need ui for editing waypoints

@property (nonatomic, strong) InitialLocation		* initialLocation; // deprecate

// data
@property (nonatomic, strong) RouteVO				* route;
@property (nonatomic, strong) NSMutableArray		* routeMarkerArray;
@property (nonatomic, strong) RMMarker				* activeMarker;

// state
@property (nonatomic, assign) BOOL		 doingLocation;
@property (nonatomic, assign) BOOL		 programmaticChange;
@property (nonatomic, assign) BOOL		 avoidAccidentalTaps;
@property (nonatomic, assign) BOOL		 singleTapDidOccur;
@property (nonatomic, assign) CGPoint		 singleTapPoint;
@property (nonatomic, assign) MapPlanningState	mapPlanningState;



@end



@implementation NewMapViewController


-(void)listNotificationInterests{
	
	
	[notifications addObject:CSMAPSTYLECHANGED];
	[notifications addObject:CSROUTESELECTED];
	[notifications addObject:EVENTMAPROUTEPLAN];
	[notifications addObject:CSLASTLOCATIONLOAD];
	
	[notifications addObject:GPSLOCATIONCOMPLETE];
	[notifications addObject:GPSLOCATIONUPDATE];
	[notifications addObject:GPSLOCATIONFAILED];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	NSDictionary	*dict=[notification userInfo];
	
	
	// if ULM has this subscriber do gps methods
	
}

#pragma mark notification response methods


- (void) didNotificationMapStyleChanged {
	self.mapView.contents.tileSource = [NewMapViewController tileSource];
	self.attributionLabel.text = [NewMapViewController mapAttribution];
}



//
/***********************************************
 * @description			View Methods
 ***********************************************/
//

-(void)viewDidLoad{
	
	
	
}


-(void)viewDidAppear:(BOOL)animated{
	
	
	
}


-(void)createPersistentUI{
	
	popoverClass = [WEPopoverController class];
	
	
	[self initToolBarEntries];
	
	
	//Necessary to start route-me service
	[RMMapView class];
	
	//get the configured map source.
	self.mapContents=[[RMMapContents alloc] initWithView:mapView tilesource:[NewMapViewController tileSource]];
	
	
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
	
	
	self.programmaticChange = NO;
	singleTapDidOccur=NO;
	
	self.attributionLabel.text = [NewMapViewController mapAttribution];
	
	[self gotoState:MapPlanningStateNoRoute];
	
	
	[[RouteManager sharedInstance] loadSavedSelectedRoute];

	
	
	
}


-(void)createNonPersistentUI{
	
	
	
	
	
}




//
/***********************************************
 * @description			State Update
 ***********************************************/
//

- (void)gotoState:(PlanningState)newPlanningState{
	
	
	
}




//
/***********************************************
 * @description			Location Manager methods
 ***********************************************/
//

-(void)startLocating{
	
	// check with location manager
	
	// update ui state
	
	
}

-(void)stopLocating{
	
	// tel ULM to remove this subscriber
	
}


-(void)locationDidComplete:(NSNotification *)notification{
	
	// update ui state
	
	// update map
	
}

-(void)locationDidUpdate:(NSNotification *)notification{
	
	// update map
	
	
}

-(void)locationDidFail:(NSNotification *)notification{
	
	// update ui state
	
}



//
/***********************************************
 * @description			Waypoints
 ***********************************************/
//


// add waypoint

// remove waypoint at index

// reset waypoints



//
/***********************************************
 * @description			UIAlerts
 ***********************************************/
//

// create alert with Type


//
/***********************************************
 * @description			UIEvents
 ***********************************************/
//

#pragma mark toolbar actions



- (void) locationButtonSelected {
	
}



- (IBAction) searchButtonSelected {
	
	
	if (mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}
	mapLocationSearchView.locationReceiver = self;
	mapLocationSearchView.centreLocation = [[mapView contents] mapCenter];
	
	[self presentModalViewController:mapLocationSearchView	animated:YES];
	
}

// likey deprecated due to waypoints
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

- (IBAction) routeButtonSelected {
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


-(void)waypointButtonSelected{
	
	
	
}



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




#pragma mark RMMap delegate methods
//
/***********************************************
 * @description			RMMap Touch delegates
 ***********************************************/
//




#pragma marks Class Methods

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
		mapStyle = [[NewMapViewController mapStyles] objectAtIndex:0];
	}
	
	return mapStyle;
}

+ (NSString *)mapAttribution {
	NSString *mapStyle = [NewMapViewController currentMapStyle];
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
	NSString *mapStyle = [NewMapViewController currentMapStyle];
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



#pragma mark delegates
//
/***********************************************
 * @description			DELEGATE METHODS
 ***********************************************/
//


#pragma mark Mapsearch delegateß

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	[self.mapView moveToLatLong: location];
	/*
	[self addLocation:location];
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	[self stopDoingLocation];
	 */
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


#pragma mark point list provider 
// PointListProvider
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
	
	return points;
}

- (NSArray *) pointList {
	return [NewMapViewController pointList:self.route withView:self.mapView];
}

// LocationProvider
#pragma mark location provider

- (float)getX {
	CGPoint p = [self.mapView.contents latLongToPixel:self.lastLocation.coordinate];
	return p.x;
}

- (float)getY {
	CGPoint p = [self.mapView.contents latLongToPixel:self.lastLocation.coordinate];
	return p.y;
}

- (float)getRadius {
	
	double metresPerPixel = [self.mapView.contents metersPerPixel];
	float locationRadius=(self.lastLocation.horizontalAccuracy / metresPerPixel);
	
	return MAX(locationRadius, 40.0f);
}


@end
