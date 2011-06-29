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

//  PhotoMap.m
//  CycleStreets
//
//  Created by Alan Paxton on 06/06/2010.
//

#import "Common.h"
#import "PhotoMapViewController.h"
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
#import "RMCachedTileSource.h"
#import "PhotoList.h"
#import "PhotoEntry.h"
#import "QueryPhoto.h"
#import "PhotoMapImageLocationViewController.h"
#import "InitialLocation.h"
#import "Markers.h"
#import "MapLocationSearchViewController.h"
#import "RMMapView.h"
#import "CSPoint.h"
#import "RouteLineView.h"
#import "RMMercatorToScreenProjection.h"
#import "Files.h"
#import "GlobalUtilities.h"

@implementation PhotoMapViewController

static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSTimeInterval FADE_DURATION = 1.7;
@synthesize mapView;
@synthesize blueCircleView;
@synthesize attributionLabel;
@synthesize locationManager;
@synthesize locationView;
@synthesize lastLocation;
@synthesize progressHud;
@synthesize initialLocation;
@synthesize locationButton;
@synthesize showPhotosButton;
@synthesize mapLocationSearchView;
@synthesize introView;
@synthesize introButton;
@synthesize photoMarkers;
@synthesize photomapQuerying;
@synthesize showingPhotos;
@synthesize locationManagerIsLocating;
@synthesize locationWasFound;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [mapView release], mapView = nil;
    [blueCircleView release], blueCircleView = nil;
    [attributionLabel release], attributionLabel = nil;
    [locationManager release], locationManager = nil;
    [locationView release], locationView = nil;
    [lastLocation release], lastLocation = nil;
    [progressHud release], progressHud = nil;
    [initialLocation release], initialLocation = nil;
    [locationButton release], locationButton = nil;
    [showPhotosButton release], showPhotosButton = nil;
    [mapLocationSearchView release], mapLocationSearchView = nil;
    [introView release], introView = nil;
    [introButton release], introButton = nil;
    [photoMarkers release], photoMarkers = nil;
	
    [super dealloc];
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.mapView.hidden = YES;
	
		
	//Necessary to start route-me service
	[RMMapView class];
	
	[[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]] autorelease];

	
	// Initialize
	[mapView setDelegate:self];
	if (initialLocation == nil) {
		initialLocation = [[InitialLocation alloc] initWithMapView:mapView withController:self];
	}
	[initialLocation performSelector:@selector(query) withObject:nil afterDelay:0.0];
	
	//clear up from last run.
	[[mapView markerManager] removeMarkers];
	
	[blueCircleView setLocationProvider:self];
	
	//get the map attribution correct.
	self.attributionLabel.text = [MapViewController mapAttribution];
	
	//set up the location manager.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy=500;
	locationManagerIsLocating = NO;
	locationWasFound=YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didNotificationMapStyleChanged)
												 name:@"NotificationMapStyleChanged"
											   object:nil];	
	
	self.progressHud=[[MBProgressHUD alloc] initWithView:mapView];
	[mapView addSubview:progressHud];
	progressHud.alpha=0.6;
	progressHud.hidden=YES;
	progressHud.delegate = self;
	
	showingPhotos = YES;
	[self performSelector:@selector(requestPhotos) withObject:nil afterDelay:0.0];
	
	[GlobalUtilities styleIBButton:introButton type:@"green" text:@"OK"];
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[[CycleStreets sharedInstance].files misc]];
	NSString *experienceLevel = [misc objectForKey:@"experienced"];
	if (experienceLevel != nil) {
		[self.introView removeFromSuperview];
	}
}



-(void)viewWillDisappear:(BOOL)animated{
	if(locationManagerIsLocating==YES)
		[self stoplocationManagerIsLocating];
	
}


- (void) didNotificationMapStyleChanged {
	mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}


- (void) requestPhotos {
	
	if (photomapQuerying || !showingPhotos) return;
	
	photomapQuerying = YES;
	[self showProgressHud:YES];
	CGRect bounds = mapView.contents.screenBounds;
	CLLocationCoordinate2D nw = [mapView pixelToLatLong:bounds.origin];
	CLLocationCoordinate2D se = [mapView pixelToLatLong:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];	
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	ne.latitude = nw.latitude;
	ne.longitude = se.longitude;
	sw.latitude = se.latitude;
	sw.longitude = nw.longitude;
	[self fetchPhotoMarkersNorthEast:ne SouthWest:sw];	
}

-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
}

- (void) afterMapMove: (RMMapView*) map {
	//DLog(@"afterMapMove");
	[blueCircleView setNeedsDisplay];
	[self requestPhotos];
}

/*
 - (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
 }
 */

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	//DLog(@"afterMapZoom");
	[blueCircleView setNeedsDisplay];
	[self requestPhotos];
}

- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[[CycleStreets sharedInstance].files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[[CycleStreets sharedInstance].files setMisc:misc];	
}

- (void)fixLocationAndButtons:(CLLocationCoordinate2D)location {
	[mapView moveToLatLong:location];
	[self saveLocation:location];	
}

- (PhotoEntry *) randomPhoto {
	if (photoMarkers == nil || [photoMarkers count] == 0) return nil;
	srand( time( NULL));
	int i = random() % [photoMarkers count];
	return (PhotoEntry *)((RMMarker *)[photoMarkers objectAtIndex:i]).data;
}

#pragma mark toolbar actions

- (IBAction) didZoomIn {
	DLog(@"zoomin");
	if ([mapView.contents zoom] < MAX_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] + 1];
		[blueCircleView setNeedsDisplay];
	}
	[self requestPhotos];
}

- (IBAction) didZoomOut {
	DLog(@"zoomout");
	if ([mapView.contents zoom] > MIN_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] - 1];
		[blueCircleView setNeedsDisplay];
	}
	[self requestPhotos];
}

- (IBAction) didLocation {
	DLog(@"location");
	if (!locationManagerIsLocating) {
		[self startlocationManagerIsLocating];
	} else {
		[self stoplocationManagerIsLocating];
	}
}

- (IBAction) didShowPhotos {
	DLog(@"showPhotos");
	if (!showingPhotos) {
		[self startShowingPhotos];
	} else {
		[self stopShowingPhotos];
	}
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

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
	DLog(@"tapMarker");
	if (locationView == nil) {
		locationView = [[PhotoMapImageLocationViewController alloc] init];
	}
	if ([marker.data isKindOfClass: [PhotoEntry class]]) {
		[self presentModalViewController:locationView animated:YES];
		PhotoEntry *photoEntry = (PhotoEntry *)marker.data;
		[locationView loadContentForEntry:photoEntry];
	}
}

- (IBAction) didIntroButton {
	[UIView beginAnimations:@"InitialPhotomapAnimation" context:nil];
	[UIView setAnimationDuration:FADE_DURATION];
	[self.introView setAlpha:0.0];
	[UIView commitAnimations];
	[self.introView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:FADE_DURATION];			
}

#pragma mark utility



// all the things that need fixed if we have asked (or been forced) to stop doing location.
- (void)stopShowingPhotos {
	showingPhotos = NO;
	showPhotosButton.style = UIBarButtonItemStyleBordered;
	[self clearPhotos];
}

// all the things that need fixed if we have asked (or been forced) to start doing location.
- (void)startShowingPhotos {
	showingPhotos = YES;
	showPhotosButton.style = UIBarButtonItemStyleDone;
	[self requestPhotos];
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

// called from toggled ui button, stops CL and removes circle view
- (void)stoplocationManagerIsLocating {
	locationManagerIsLocating = NO;
	locationButton.style = UIBarButtonItemStyleBordered;
	[locationManager stopUpdatingLocation];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
	blueCircleView.hidden = YES;
}

// called from ui button, starts CL and shows circle view
- (void)startlocationManagerIsLocating {
	
	if(locationManager.locationServicesEnabled==YES){
		
		locationManagerIsLocating = YES;
		locationWasFound=NO;
		locationButton.style = UIBarButtonItemStyleDone;
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
		[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:30];
		blueCircleView.hidden = NO;
		
	}else {
		UIAlertView *gpsAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
														   message:@"Location services for CycleStreets are off, please enable in Settings > General > Location Services to use location based features."
														  delegate:nil
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
		[gpsAlert show];
		[gpsAlert release];
	}

}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
	
	BetterLog(@"newLocation.horizontalAccuracy=%f",newLocation.horizontalAccuracy);
	BetterLog(@"locationManager.desiredAccuracy=%f",locationManager.desiredAccuracy);
	
	[MapViewController zoomMapView:mapView toLocation:newLocation];
	[blueCircleView setNeedsDisplay];
	
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	
	BetterLog(@"locationAge=%i",locationAge);
	
    if (locationAge > 5.0) return;
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (lastLocation == nil || lastLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.lastLocation = newLocation;
		
		BetterLog(@"");
		
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			BetterLog(@"");
            [self stopUpdatingLocation:@"Acquired Location"];
			
        }
		
		
    }
	
}

// called from CL when accuracy was reached or timed out. Removes UI
- (void)stopUpdatingLocation:(NSString *)state {
	
	BetterLog(@"");
	
	if(locationManagerIsLocating==YES){
		
		if([state isEqualToString:@"Acquired Location"]){
			// 
		}
		
		[self stoplocationManagerIsLocating];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	[self stoplocationManagerIsLocating];
	
	UIAlertView *gpsAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
													   message:@"Unable to retrieve location. Location services for CycleStreets may be off, please enable in Settings > General > Location Services to use location based features."
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
	[gpsAlert show];
	[gpsAlert release];
}

#pragma mark photomap functions

- (void) clearPhotos {
	//Clear out the previous list.
	if (photoMarkers != nil) {
		NSArray *oldMarkers = [photoMarkers copy];
		for (RMMarker *oldMarker in photoMarkers) {
			[[mapView markerManager] removeMarker:oldMarker];
		}
		[oldMarkers release];
	}
}

- (void) didSucceedPhoto:(XMLRequest *)request results:(NSDictionary *)elements {
	
	BetterLog(@"");
	
	[self clearPhotos];
	if (!showingPhotos) {
		photomapQuerying = NO;
		[self showProgressHud:NO];
		return;
	}
	if (photoMarkers == nil) {
		photoMarkers = [[NSMutableArray alloc] initWithCapacity:10];
	}
	
	//build the list of photos, and add them as markers.
	PhotoList *photoList = [[PhotoList alloc] initWithElements:elements];
	for (PhotoEntry *photo in [photoList photos]) {
		RMMarker *marker = [Markers markerPhoto];
		marker.data = photo;
		[photoMarkers addObject:marker];
		[[mapView markerManager] addMarker:marker AtLatLong:[photo location]];
	}
	[photoList release];
	photomapQuerying = NO;
	[self showProgressHud:NO];
}

- (void) didFailPhoto:(XMLRequest *)request message:(NSString *)message {
	[self clearPhotos];
	photomapQuerying = NO;
	[self showProgressHud:NO];
}

//helper, could be shelled out as more general.
- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	BetterLog(@"");
	QueryPhoto *queryPhoto = [[QueryPhoto alloc] initNorthEast:ne SouthWest:sw];
	[queryPhoto runWithTarget:self onSuccess:@selector(didSucceedPhoto:results:) onFailure:@selector(didFailPhoto:message:)];
	[queryPhoto release];
}

#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	DLog(@"didMoveToLocation");
	[mapView moveToLatLong: location];
}



//
/***********************************************
 * @description			HUD support
 ***********************************************/
//

-(void)showProgressHud:(BOOL)show{
	if(show==YES){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeHUD) object:nil];
		if(progressHud.hidden==YES)
			progressHud.hidden=NO;		
	}else {
		[self performSelector:@selector(removeHUD) withObject:nil afterDelay:0.3];
		
	}

}

-(void)removeHUD{
	progressHud.hidden=YES;
}


-(void)hudWasHidden{
	
}


#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.locationButton = nil;

	mapView = nil;
	
	self.attributionLabel = nil;
	self.blueCircleView = nil;
	self.introView = nil;
	self.introButton = nil;
	locationManager = nil;
	locationView = nil;
	lastLocation = nil;
	initialLocation = nil;
	progressHud = nil;
	mapLocationSearchView = nil;	
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}



@end
