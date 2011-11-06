//
//  RouteMapViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 27/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteMapViewController.h"
#import "SettingsManager.h"
#import "CycleStreets.h"
#import "RouteManager.h"
#import "GlobalUtilities.h"
#import "POIListviewController.h"
#import "MapLocationSearchViewController.h"
// RM
#import "RMMapView.h"
#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "RMCloudMadeMapSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMOpenCycleMapSource.h"
#import "RMOrdnanceSurveyStreetViewMapSource.h"
#import "RMTileSource.h"
#import "RMCachedTileSource.h"
#import "RMMercatorToScreenProjection.h"

#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "Markers.h"
#import "CSPointVO.h"
#import "RouteLineView.h"



@interface RouteMapViewController(Private)




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
static CLLocationDistance MIN_START_FINISH_DISTANCE = 100;

@implementation RouteMapViewController








#pragma mark Route Loading
//
/***********************************************
 * @description			Route loading
 ***********************************************/
//	

-(void)updateSelectedRoute{
	[self showRoute:[RouteManager sharedInstance].selectedRoute];
}

- (void) showRoute:(RouteVO *)newRoute {
	
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
	//[blueCircleView setNeedsDisplay];
	
	[self gotoState:stateStart];
}

- (void) newRoute {
	
	[mapView zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)[route insetNorthEast]
								 SouthWest:(CLLocationCoordinate2D)[route insetSouthWest]];
	
	[self clearMarkers];
	[self stopDoingLocation];
	
	// need multi point support
	
	CLLocationCoordinate2D startLocation = [[route segmentAtIndex:0] segmentStart];
	[self startMarker:startLocation];
	CLLocationCoordinate2D endLocation = [[route segmentAtIndex:[route numSegments] - 1] segmentEnd];
	[self endMarker:endLocation];
	
	[lineView setNeedsDisplay];
	//[blueCircleView setNeedsDisplay];
	//[self gotoState:stateRoute];
}




#pragma mark UI Events
//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//


-(void)refreshMap{
	[lineView setNeedsDisplay];
	//[blueCircleView setNeedsDisplay];
	[self stopDoingLocation];
}


-(void)poiSelectionButtonSelected:(id)sender{
	
	POIListviewController *lv=[[POIListviewController alloc]initWithNibName:[POIListviewController nibName] bundle:nil];
	
	UINavigationController *ncontroller=[[UINavigationController alloc]initWithRootViewController:lv];
	ncontroller.navigationBar.tintColor=[[StyleManager sharedInstance] colorForType:@"navigationbar"];
	[self presentModalViewController:ncontroller	animated:YES];
	
	[ncontroller release];
	[lv release];
}


- (IBAction) locationSearchButtonSelected:(id)sender {
	
	
	 if (mapLocationSearchView == nil) {
		 self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	 }
	 mapLocationSearchView.locationReceiver = self;
	 mapLocationSearchView.centreLocation = [[mapView contents] mapCenter];
	[self presentModalViewController:mapLocationSearchView	animated:YES];
	
}

//delete the last point, either start or end.
- (IBAction) deletePointButtonSelected:(id)sender {
	
	// needs major work to support multi waypoints
	
	RMMarkerManager *markerManager = [mapView markerManager];
	
	if ([[markerManager markers] containsObject:self.end]) {
		[markerManager removeMarker:self.end];
		[self gotoState:stateEnd];
	} else {
		[markerManager removeMarker:self.start];
		[self gotoState:stateStart];
	}
}


- (IBAction) findRouteButtonSelected:(id)sender {
	
	BetterLog(@"");
	
	/*
	
	if (self.planningState == statePlan) {
		RMMarkerManager *markerManager = [mapView markerManager];
		if (![[markerManager markers] containsObject:self.end] || ![[markerManager markers] containsObject:self.start]) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Routing"
															message:@"Need start and end markers to calculate a route."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		}
		
		
		
		
		CLLocationCoordinate2D fromLatLon = [markerManager latitudeLongitudeForMarker:start];
		CLLocation *from = [[[CLLocation alloc] initWithLatitude:fromLatLon.latitude longitude:fromLatLon.longitude] autorelease];
		CLLocationCoordinate2D toLatLon = [markerManager latitudeLongitudeForMarker:end];
		CLLocation *to = [[[CLLocation alloc] initWithLatitude:toLatLon.latitude longitude:toLatLon.longitude] autorelease];
		
		[[RouteManager sharedInstance] loadRouteForEndPoints:from to:to];
		
	} else if (self.planningState == stateRoute) {
		[self.clearAlert show];
	}
	 
	 */
}




#pragma mark RM Map Delegate
//
/***********************************************
 * @description			RM Map delegate methods
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

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[self afterMapChanged:map];
	[self saveLocation:map.contents.mapCenter];
}

-(void)tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map{
	//BetterLog(@"");
	//mapView.enableDragging=NO;
	
}

// Should only return yes is marker is start/end and we have not a route drawn
- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	/*
	 if (marker == start || marker == end) {
	 BetterLog(@"shoulddrag");
	 return YES;
	 }
	 */
	return NO;
}

//TODO: bug here with marker dragging, doesnt recieve any touch updates: 
//NE: fix is, should ask for correct sub view, we have several overlayed, this needs to be optimised for this to work
- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	/*
	 NSSet *touches = [event touchesForView:lineView];
	 for (UITouch *touch in touches) {
	 CGPoint point = [touch locationInView:map];
	 CLLocationCoordinate2D location = [map pixelToLatLong:point];
	 [[map markerManager] moveMarker:marker AtLatLon:location];
	 }
	 */
}



#pragma mark Utility methods
//
/***********************************************
 * @description			Utility methods
 ***********************************************/
//

// Saves current map state, only recalled if SR==nil
- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", mapView.contents.zoom] forKey:@"zoom"];
	[cycleStreets.files setMisc:misc];	
}

//
/***********************************************
 * @description			Loads saved current map state, for Selected Route==nil
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


#pragma mark Class methods
//
/***********************************************
 * @description			Class methods
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
	[mapView moveToLatLong: newLocation.coordinate];
	[mapView.contents setZoom:wantZoom];
}

// List of points in display co-ordinates for the route highlighting.
+ (NSArray *) pointList:(RouteVO *)route withView:(RMMapView *)mapView {
	
	NSMutableArray *points = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	if (route == nil) {
		return points;
	}
	
	for (int i = 0; i < [route numSegments]; i++) {
		if (i == 0)
		{	// start of first segment
			CSPointVO *p = [[[CSPointVO alloc] init] autorelease];
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
			CSPointVO *screen = [[[CSPointVO alloc] init] autorelease];
			screen.p = pt;
			[points addObject:screen];
		}
	}	
	return points;
}

//
/***********************************************
 * @description			generic methods
 ***********************************************/
//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}



@end
