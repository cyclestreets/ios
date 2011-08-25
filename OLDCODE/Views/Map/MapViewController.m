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

#import "Common.h"
#import "MapViewController.h"
#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Query.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "BusyAlert.h"
#import "Route.h"
#import "SegmentVO.h"
#import <CoreLocation/CoreLocation.h>
#import "RMCloudMadeMapSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMOpenCycleMapSource.h"
#import "RMOrdnanceSurveyStreetViewMapSource.h"
#import "RMTileSource.h"
#import "RMCachedTileSource.h"
#import "PhotoList.h"
#import "PhotoEntry.h"
#import "QueryPhoto.h"
#import "Markers.h"
#import "MapLocationSearchViewController.h"
#import "RMMapView.h"
#import "CSPoint.h"
#import "RouteLineView.h"
#import "RMMercatorToScreenProjection.h"
#import "Files.h"
#import "FavouritesViewController.h"
#import "InitialLocation.h"
#import "CustomButtonView.h"
#import "RouteManager.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "SettingsManager.h"

@interface MapViewController(Private)

-(void)showProgressHUDWithMessage:(NSString*)message;
-(void)removeHUD;
-(void)showSuccessHUD:(NSString*)message;
-(void)showErrorHUDWithMessage:(NSString*)error;
-(void)showHUDWithMessage:(NSString*)message;
-(void)showHUDWithMessage:(NSString*)message andIcon:(NSString*)icon withDelay:(NSTimeInterval)delay;

- (void) addLocation:(CLLocationCoordinate2D)location;
-(void)updateSelectedRoute;

// saved map loaction loading, separate from savedRoute
- (void)saveLocation:(CLLocationCoordinate2D)location;
- (void)zoomUpdate;
-(void)loadLocation;

@end


@implementation MapViewController

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

//handle when to switch off the GPS, and at what accuracy.
static CLLocationDistance LOC_DISTANCE_FILTER = 25;
/*
static CLLocationAccuracy ACCURACY_OK = 100;
static CLLocationAccuracy ACCURACY_BEST = 20;
static NSTimeInterval LOC_OFF_DELAY_BAD = 30.0;
static NSTimeInterval LOC_OFF_DELAY_OK = 3.0;
static NSTimeInterval LOC_OFF_DELAY_BEST = 1.0;
 */

static NSTimeInterval ACCIDENTAL_TAP_DELAY = 0.5;

//don't allow co-location of start/finish
static CLLocationDistance MIN_START_FINISH_DISTANCE = 100;

@synthesize toolBar;
@synthesize locationButton;
@synthesize activeLocationButton;
@synthesize locatingIndicator;
@synthesize nameButton;
@synthesize routeButton;
@synthesize deleteButton;
@synthesize contextLabel;
@synthesize attributionLabel;
@synthesize cycleStreets;
@synthesize mapView;
@synthesize lineView;
@synthesize blueCircleView;
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
@synthesize oldPlanningState;
@synthesize HUD;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [toolBar release], toolBar = nil;
    [locationButton release], locationButton = nil;
    [activeLocationButton release], activeLocationButton = nil;
    [locatingIndicator release], locatingIndicator = nil;
    [nameButton release], nameButton = nil;
    [routeButton release], routeButton = nil;
    [deleteButton release], deleteButton = nil;
    [contextLabel release], contextLabel = nil;
    [attributionLabel release], attributionLabel = nil;
    [cycleStreets release], cycleStreets = nil;
    [mapView release], mapView = nil;
    [lineView release], lineView = nil;
    [blueCircleView release], blueCircleView = nil;
    [initialLocation release], initialLocation = nil;
    [locationManager release], locationManager = nil;
    [lastLocation release], lastLocation = nil;
    [mapLocationSearchView release], mapLocationSearchView = nil;
    [route release], route = nil;
    [start release], start = nil;
    [end release], end = nil;
    [startEndPool release], startEndPool = nil;
    [firstAlert release], firstAlert = nil;
    [clearAlert release], clearAlert = nil;
    [startFinishAlert release], startFinishAlert = nil;
    [noLocationAlert release], noLocationAlert = nil;
    [HUD release], HUD = nil;
	
    [super dealloc];
}




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
		tileSource = [[[RMOpenStreetMapSource alloc] init] autorelease];
	}
	else if ([mapStyle isEqualToString:MAPPING_BASE_OPENCYCLEMAP])
	{
		//open cycle map
		tileSource = [[[RMOpenCycleMapSource alloc] init] autorelease];
	}
	else if ([mapStyle isEqualToString:MAPPING_BASE_OS])
	{
		//Ordnance Survey
		tileSource = [[[RMOrdnanceSurveyStreetViewMapSource alloc] init] autorelease];
	}
	else
	{
		//default to MAPPING_BASE_OSM.
		tileSource = [[[RMOpenStreetMapSource alloc] init] autorelease];
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
	DLog(@"accuracy %f zoom %d", accuracy, wantZoom);
	[mapView moveToLatLong: newLocation.coordinate];
	[mapView.contents setZoom:wantZoom];
}

- (id)init {
	BetterLog(@"");
	if (self = [super init]) {
	}
	return self;
}

- (void)logState {
	switch (self.planningState) {
		case stateStart:
			//DLog(@"stateStart");
			break;
		case stateEnd:
			//DLog(@"stateEnd");
			break;
		case stateLocatingStart:
			//DLog(@"stateLocatingStart");
			break;
		case stateLocatingEnd:
			//DLog(@"stateLocatingEnd");
			break;
		case statePlan:
			//DLog(@"statePlan");
			break;
		case stateRoute:
			//NSLog(@"stateRoute");
			break;
	}
}

- (void)gotoState:(PlanningState)newPlanningState {
	
	DLog(@"gotoState... before");
	[self logState];
	
	self.oldPlanningState=planningState;
	self.planningState = newPlanningState;
	
	NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolBar.items];
	
	DLog(@"gotoState... after");
	[self logState];
	
	switch (self.planningState) {
		case stateStart:
			DLog(@"stateStart");
			
			contextLabel.text=@"Set start";
			
			// will only execute if current i4 is not this label
			UILabel *cilabel=(UILabel*)[[items objectAtIndex:4] customView];
			if(cilabel==nil){
				UIBarButtonItem *label=[[UIBarButtonItem alloc] initWithCustomView:contextLabel];
				[items replaceObjectAtIndex:4 withObject:label];
				[label release];
				[self.toolBar setItems:items];
			}
			self.deleteButton.enabled = NO;
			self.nameButton.enabled = YES;
			
			break;
		case stateLocatingStart:
		break;
		case stateEnd:
			DLog(@"stateEnd");
			
			contextLabel.text = @"Set finish";
			
			// will only execute if current i4 is not this label
			UILabel *clabel=(UILabel*)[[items objectAtIndex:4] customView];
			if(clabel==nil){
				UIBarButtonItem *label=[[UIBarButtonItem alloc] initWithCustomView:contextLabel];
				[items replaceObjectAtIndex:4 withObject:label];
				[label release];
				[self.toolBar setItems:items];
			}
			
			self.deleteButton.enabled = YES;
			self.nameButton.enabled = YES;
			
			break;
		case stateLocatingEnd:
			
			break;
		case statePlan:
			DLog(@"statePlan");
			
			// replace the contextLabel
			[items replaceObjectAtIndex:4 withObject:routeButton];
			[self.toolBar setItems:items animated:NO];
			
			self.routeButton.title = @"Plan route";
			self.routeButton.style = UIBarButtonItemStyleDone;
			self.deleteButton.enabled = YES;
			self.nameButton.enabled = NO;
			break;
		case stateRoute:
			DLog(@"stateRoute");
			
			UILabel *colabel=(UILabel*)[[items objectAtIndex:4] customView];
			if(colabel!=nil){
				[items replaceObjectAtIndex:4 withObject:self.routeButton];
				[self.toolBar setItems:items ];
			}
			
			self.routeButton.title = @"New route";
			self.routeButton.style = UIBarButtonItemStyleBordered;
			self.deleteButton.enabled = NO;
			self.nameButton.enabled = NO;
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

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.cycleStreets = [CycleStreets sharedInstance];
	
	self.locatingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	locatingIndicator.hidesWhenStopped=YES;
	
	self.activeLocationButton = [[[UIBarButtonItem alloc] initWithCustomView:locatingIndicator ]autorelease];
	self.activeLocationButton.style	= UIBarButtonItemStyleDone;
	
	self.locationButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"74-location.png"]
															style:UIBarButtonItemStyleBordered
														   target:self
														   action:@selector(didLocation)]
						   autorelease];
	self.locationButton.width = 40;
	
	self.deleteButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CSBarButton_deletePoint_white.png"]
															style:UIBarButtonItemStyleBordered
														   target:self
														   action:@selector(didDelete)]
						   autorelease];
	self.deleteButton.width = 40;
	
	NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolBar.items];
	[items insertObject:self.locationButton atIndex:0];
	[items insertObject:self.deleteButton atIndex:2];
	self.toolBar.items = items;
	
	
	self.clearAlert = [[[UIAlertView alloc]
						initWithTitle:@"CycleStreets"
						message:@"Clear current route ?"
						delegate:self
						cancelButtonTitle:@"Cancel"
						otherButtonTitles:@"OK", nil] autorelease];
	
	//Necessary to start route-me service
	[RMMapView class];
	
	//get the configured map source.
	[[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]] autorelease];

	
	// Initialize
	[mapView setDelegate:self];
	if (initialLocation == nil) {
		initialLocation = [[InitialLocation alloc] initWithMapView:mapView withController:self];
	}
	[initialLocation performSelector:@selector(query) withObject:nil afterDelay:0.0];
	
	//clear up from last run.
	[self clearMarkers];
	
	//provide the points the line overlay needs, when it needs them, in screen co-ordinates
	[lineView setPointListProvider:self];
	
	[blueCircleView setLocationProvider:self];
	
	//set up the location manager.
	locationManager = [[CLLocationManager alloc] init];
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
	

	[[RouteManager sharedInstance] loadSavedSelectedRoute];
	
	// TODO: load saved route but then reset map to last l/l & zoom
	// need to update misc saving to suport int Zoom var
	//[self loadLocation];
	// DEPRECATED FOR V1.5
	
}


- (void) didNotificationMapStyleChanged {
	mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}

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
		//DLog(@"afterMapChanged, autolocating=NO, [self stopDoingLocation]");
		if (self.planningState == stateLocatingStart || self.planningState == stateLocatingEnd) {
			[self stopDoingLocation];
		}
	} else {
		//DLog(@"afterMapChanged, autolocating=YES");
	}
}

- (void) afterMapMove: (RMMapView*) map {
	[self afterMapChanged:map];
}

/*
- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
}
 */

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[self afterMapChanged:map];
	[self saveLocation:map.contents.mapCenter];
}

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
	DLog(@">>>");
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) firstAlert:(NSString *)message {
	
	[self showHUDWithMessage:message];
}

- (void) showStartFinishAlert {
	if (self.startFinishAlert == nil) {
		self.startFinishAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
															message:@"Move the map to set a finish point further away."
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:nil]
								 autorelease];
	}
	[self stopDoingLocation];
	[self.startFinishAlert show];
	[self performSelector:@selector(cancelAlert:) withObject:self.startFinishAlert afterDelay:2.0];
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (CLLocationDistance) distanceFromStart:(CLLocationCoordinate2D)locationLatLon {
	CLLocationCoordinate2D fromLatLon = [[mapView markerManager] latitudeLongitudeForMarker:start];
	CLLocation *from = [[[CLLocation alloc] initWithLatitude:fromLatLon.latitude
												   longitude:fromLatLon.longitude] autorelease];
	CLLocation *to = [[[CLLocation alloc] initWithLatitude:locationLatLon.latitude
												 longitude:locationLatLon.longitude] autorelease];
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
	DLog(@"addLocation");
	
	//end is too near start, and is being done by autolocation.
	if (self.programmaticChange && self.planningState == stateLocatingEnd) {
		CLLocationDistance distanceFromStart = [self distanceFromStart:location];
		if (distanceFromStart < MIN_START_FINISH_DISTANCE) {
			[self showHUDWithMessage:@"Move the map to set a finish point further away."];
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
			[self showHUDWithMessage:@"Finish point set." andIcon:@"CSIcon_finish_wisp.png" withDelay:1];
		}
		if (self.planningState == stateEnd) {
			[self gotoState:statePlan];
		}		
	}
	
	//startpoint, whether autolocated or not.
	if (self.planningState == stateStart || self.planningState == stateLocatingStart) {
		[self startMarker:location];
		if ([SettingsManager sharedInstance].dataProvider.showRoutePoint==YES) {
			[self showHUDWithMessage:@"Start point set." andIcon:@"CSIcon_start_wisp.png" withDelay:1];
		}
		if (self.planningState == stateStart) {
			[self gotoState:stateEnd];
		}
	}
	
	[self saveLocation:location];
}



// Note: this is disbled due a bug with didDragMarker not receiving drag updates
-(void)tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map{
	BetterLog(@"");
	//mapView.enableDragging=NO;
	
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	if (marker == start || marker == end) {
		BetterLog(@"");
		return YES;
	}
	return NO;
}
 
//TODO: bug here with marker dragging, doesnt recieve any touch updates
- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	NSSet *touches = [event touchesForView:map];
	for (UITouch *touch in touches) {
		BetterLog(@"");
		CGPoint point = [touch locationInView:map];
		CLLocationCoordinate2D location = [map pixelToLatLong:point];
		[[map markerManager] moveMarker:marker AtLatLon:location];
	}
}


#pragma mark toolbar actions

- (void)zoomUpdate {
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	[self stopDoingLocation];
}

- (IBAction) didZoomIn {
	DLog(@"zoomin");
	if ([mapView.contents zoom] < MAX_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] + 1];
	}
	[self zoomUpdate];
}

- (IBAction) didZoomOut {
	DLog(@"zoomout");
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
	DLog(@"search");
	if (mapLocationSearchView == nil) {
		mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
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
	DLog(@"route");
	
	if (self.planningState == statePlan) {
		RMMarkerManager *markerManager = [mapView markerManager];
		if (![[markerManager markers] containsObject:self.end] || ![[markerManager markers] containsObject:self.start]) {
			DLog(@"not enough locations.");
			[cycleStreets.appDelegate.errorAlert setMessage:@"Need start and end markers to calculate a route."];
			[cycleStreets.appDelegate.errorAlert show];
		}
		
		CLLocationCoordinate2D fromLatLon = [markerManager latitudeLongitudeForMarker:start];
		CLLocation *from = [[[CLLocation alloc] initWithLatitude:fromLatLon.latitude longitude:fromLatLon.longitude] autorelease];
		CLLocationCoordinate2D toLatLon = [markerManager latitudeLongitudeForMarker:end];
		CLLocation *to = [[[CLLocation alloc] initWithLatitude:toLatLon.latitude longitude:toLatLon.longitude] autorelease];
		Query *query = [[[Query alloc] initFrom:from to:to] autorelease];
		
		[[RouteManager sharedInstance] runQuery:query];
		
	} else if (self.planningState == stateRoute) {
		[self.clearAlert show];
	}
}

#pragma mark utility


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
		blueCircleView.hidden = YES;
		
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
			blueCircleView.hidden = NO;
			
			
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
			[gpsAlert release];
			
		}

	}
}

- (void) clearRoute {
	route = nil;
	[self clearMarkers];
	[self stopDoingLocation];
	
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	
	[self gotoState:stateStart];
}

- (void) newRoute {
	[mapView zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)[route insetNorthEast]
								 SouthWest:(CLLocationCoordinate2D)[route insetSouthWest]];
	
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

// A new route has successfully been calculated.
// Plot it, and replace the current stuff.

-(void)updateSelectedRoute{
	[self showRoute:[RouteManager sharedInstance].selectedRoute];
}

- (void) showRoute:(Route *)newRoute {
	[newRoute retain];
	[route release];
	route = newRoute;
	
	if (route == nil || [route numSegments] == 0) {
		[self clearRoute];
	} else {
		[self newRoute];
	}
}

// List of points in display co-ordinates for the route highlighting.
+ (NSArray *) pointList:(Route *)route withView:(RMMapView *)mapView {
	
	NSMutableArray *points = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	if (route == nil) {
		return points;
	}
	
	for (int i = 0; i < [route numSegments]; i++) {
		if (i == 0)
		{	// start of first segment
			CSPoint *p = [[[CSPoint alloc] init] autorelease];
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
			CSPoint *latlon = [allPoints objectAtIndex:i];
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = latlon.p.y;
			coordinate.longitude = latlon.p.x;
			CGPoint pt = [mapView.contents latLongToPixel:coordinate];
			CSPoint *screen = [[[CSPoint alloc] init] autorelease];
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
	return (lastLocation.horizontalAccuracy / metresPerPixel);
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
		self.noLocationAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
														   message:@"Unable to retrieve location. Location services for CycleStreets may be off, please enable in Settings > General > Location Services to use location based features."
														  delegate:nil
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil]
								autorelease];
	}
	[self.noLocationAlert show];
}

#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	DLog(@"didMoveToLocation");
	[mapView moveToLatLong: location];
	[self addLocation:location];
	[lineView setNeedsDisplay];
	[blueCircleView setNeedsDisplay];
	[self stopDoingLocation];
}

#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.locationButton = nil;
	self.activeLocationButton = nil;
	self.locatingIndicator = nil;
		
	self.nameButton = nil;
	self.routeButton = nil;
	self.deleteButton = nil;
	
	self.attributionLabel = nil;
	
	[cycleStreets release];
	cycleStreets = nil;
	[mapView release];
	mapView = nil;
	
	self.lineView = nil;
	self.blueCircleView = nil;
	
	[locationManager release];
	locationManager = nil;
	[lastLocation release];
	lastLocation = nil;
	
	[mapLocationSearchView release];
	mapLocationSearchView = nil;
	[route release];
	route = nil;
	
	[initialLocation release];
	initialLocation = nil;
	
	self.firstAlert = nil;
	self.clearAlert = nil;
	self.startFinishAlert = nil;
	
	[self clearMarkers];
}

- (void)viewDidUnload {
	[self nullify];
    [super viewDidUnload];
	DLog(@">>>");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


//
/***********************************************
 * @description			HUDSUPPORT
 ***********************************************/
//


-(void)showProgressHUDWithMessage:(NSString*)message{
	
	HUD=[[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
    HUD.delegate = self;
	HUD.animationType=MBProgressHUDAnimationZoom;
	HUD.labelText=message;
	[HUD show:YES];
	
}

-(void)showHUDWithMessage:(NSString*)message{
	
	HUD=[[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclaim.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
	HUD.labelText=message;
	[HUD show:YES];
	[self performSelector:@selector(removeHUD) withObject:nil afterDelay:2];
}
-(void)showHUDWithMessage:(NSString*)message andIcon:(NSString*)icon withDelay:(NSTimeInterval)delay{
	
	HUD=[[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
	HUD.labelText=message;
	[HUD show:YES];
	[self performSelector:@selector(removeHUD) withObject:nil afterDelay:delay];
}


//
/***********************************************
 * @description			NOTE: These are only to be called if the hud has already been created!
 ***********************************************/
//

-(void)showSuccessHUD:(NSString*)message{
	
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkMark.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = message;
	[self performSelector:@selector(removeHUD) withObject:nil afterDelay:1];
}

-(void)showErrorHUDWithMessage:(NSString*)error{
	
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclaim.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Error";
	[self performSelector:@selector(removeHUD) withObject:nil afterDelay:2];
}


-(void)removeHUD{
	
	[HUD hide:YES];
	
}


-(void)hudWasHidden{
	
	[HUD removeFromSuperview];
	[HUD release];
	HUD=nil;
	
}


@end
