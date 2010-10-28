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
#import "PhotoMap.h"
#import "Map.h"
#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Query.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "BusyAlert.h"
#import "Route.h"
#import "Segment.h"
#import <CoreLocation/CoreLocation.h>
#import "RMCloudMadeMapSource.h"
#import "RMCachedTileSource.h"
#import "PhotoList.h"
#import "PhotoEntry.h"
#import "QueryPhoto.h"
#import "Location2.h"
#import "InitialLocation.h"
#import "Markers.h"
#import "Namefinder2.h"
#import "RMMapView.h"
#import "CSPoint.h"
#import "RouteLineView.h"
#import "RMMercatorToScreenProjection.h"
#import "Files.h"
#import "UIButton+Blue.h"

@implementation PhotoMap

static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSTimeInterval FADE_DURATION = 3.0;

@synthesize locationButton;
@synthesize showPhotosButton;
@synthesize mapView;
@synthesize blueCircleView;
@synthesize loading;
@synthesize attributionLabel;

@synthesize introView;
@synthesize introButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.mapView.hidden = YES;
	
	cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	[cycleStreets retain];
	
	//Necessary to start route-me service
	[RMMapView class];
	
	[[[RMMapContents alloc] initWithView:mapView tilesource:[Map tileSource]] autorelease];

	
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
	self.attributionLabel.text = [Map mapAttribution];
	
	//set up the location manager.
	locationManager = [[CLLocationManager alloc] init];
	doingLocation = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didNotificationMapStyleChanged)
												 name:@"NotificationMapStyleChanged"
											   object:nil];		
	
	showingPhotos = YES;
	[self performSelector:@selector(requestPhotos) withObject:nil afterDelay:0.0];
	
	[self.introButton setupBlue];
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	NSString *experienceLevel = [misc objectForKey:@"experienced"];
	if (experienceLevel != nil) {
		[self.introView removeFromSuperview];
	}
}

- (void) didNotificationMapStyleChanged {
	mapView.contents.tileSource = [Map tileSource];
	self.attributionLabel.text = [Map mapAttribution];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

/*
 - (void) beforeMapMove: (RMMapView*) map {
 }
 */

- (void) requestPhotos {
	
	if (photomapQuerying || !showingPhotos) return;
	
	photomapQuerying = YES;
	[loading startAnimating];
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

- (void) afterMapMove: (RMMapView*) map {
	DLog(@"afterMapMove");
	[blueCircleView setNeedsDisplay];
	[self requestPhotos];
}

/*
 - (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
 }
 */

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	DLog(@"afterMapZoom");
	[blueCircleView setNeedsDisplay];
	[self requestPhotos];
}

- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[cycleStreets.files setMisc:misc];	
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
	if (!doingLocation) {
		[self startDoingLocation];
	} else {
		[self stopDoingLocation];
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
	if (namefinder == nil) {
		namefinder = [[Namefinder2 alloc] initWithNibName:@"Namefinder2" bundle:nil];
	}	
	namefinder.locationReceiver = self;
	namefinder.centreLocation = [[mapView contents] mapCenter];
	[self presentModalViewController:namefinder	animated:YES];
}

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
	DLog(@"tapMarker");
	if (locationView == nil) {
		locationView = [[Location2 alloc] init];
	}
	if ([marker.data isKindOfClass: [PhotoEntry class]]) {
		[self presentModalViewController:locationView animated:YES];
		PhotoEntry *photoEntry = (PhotoEntry *)marker.data;
		[locationView loadEntry:photoEntry];
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
- (void)stopDoingLocation {
	doingLocation = NO;
	locationButton.style = UIBarButtonItemStyleBordered;
	[locationManager stopUpdatingLocation];
	blueCircleView.hidden = YES;
}

// all the things that need fixed if we have asked (or been forced) to start doing location.
- (void)startDoingLocation {
	doingLocation = YES;
	locationButton.style = UIBarButtonItemStyleDone;
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
	blueCircleView.hidden = NO;
}

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

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	//carefully replace the location.
	CLLocation *oldLastLocation = lastLocation;
	[newLocation retain];
	lastLocation = newLocation;
	[oldLastLocation release];
	
	[Map zoomMapView:mapView toLocation:newLocation];
	[blueCircleView setNeedsDisplay];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self stopDoingLocation];
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
	[self clearPhotos];
	if (!showingPhotos) {
		photomapQuerying = NO;
		[loading stopAnimating];
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
	[loading stopAnimating];
}

- (void) didFailPhoto:(XMLRequest *)request message:(NSString *)message {
	[self clearPhotos];
	photomapQuerying = NO;
	[loading stopAnimating];
}

//helper, could be shelled out as more general.
- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	QueryPhoto *queryPhoto = [[QueryPhoto alloc] initNorthEast:ne SouthWest:sw];
	[queryPhoto runWithTarget:self onSuccess:@selector(didSucceedPhoto:results:) onFailure:@selector(didFailPhoto:message:)];
	[queryPhoto release];
}

#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	DLog(@"didMoveToLocation");
	[mapView moveToLatLong: location];
}

#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.locationButton = nil;
	
	[cycleStreets release];
	cycleStreets = nil;
	[mapView release];
	mapView = nil;
	
	self.attributionLabel = nil;
	self.blueCircleView = nil;
	self.introView = nil;
	self.introButton = nil;
	
	[locationManager release];
	locationManager = nil;
	[locationView release];
	locationView = nil;
	[lastLocation release];
	lastLocation = nil;
	[initialLocation release];
	initialLocation = nil;
	[loading release];
	loading = nil;
	
	[namefinder release];
	namefinder = nil;	
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end
