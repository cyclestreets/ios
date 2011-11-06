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


#import "PhotoMapViewController.h"
#import "MapViewController.h"
#import "RMMapLayer.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Query.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Route.h"
#import "SegmentVO.h"
#import <CoreLocation/CoreLocation.h>
#import "RMCloudMadeMapSource.h"
#import "RMCachedTileSource.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "QueryPhoto.h"
#import "PhotoMapImageLocationViewController.h"
#import "InitialLocation.h"
#import "Markers.h"
#import "MapLocationSearchViewController.h"
#import "RMMapView.h"
#import "CSPointVO.h"
#import "RouteLineView.h"
#import "RMMercatorToScreenProjection.h"
#import "Files.h"
#import "GlobalUtilities.h"
#import "ButtonUtilities.h"
#import "HudManager.h"
#import "PhotoManager.h"



@interface PhotoMapViewController(Private)


- (void) didNotificationMapStyleChanged;

@end



@implementation PhotoMapViewController

static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSTimeInterval FADE_DURATION = 1.7;
@synthesize mapView;
@synthesize blueCircleView;
@synthesize attributionLabel;
@synthesize gpslocateButton;
@synthesize showPhotosButton;
@synthesize locationManager;
@synthesize lastLocation;
@synthesize locationView;
@synthesize mapLocationSearchView;
@synthesize initialLocation;
@synthesize introView;
@synthesize introButton;
@synthesize photoMarkers;
@synthesize photomapQuerying;
@synthesize showingPhotos;
@synthesize locationManagerIsLocating;
@synthesize locationWasFound;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [mapView release], mapView = nil;
    [blueCircleView release], blueCircleView = nil;
    [attributionLabel release], attributionLabel = nil;
    [gpslocateButton release], gpslocateButton = nil;
    [showPhotosButton release], showPhotosButton = nil;
    [locationManager release], locationManager = nil;
    [lastLocation release], lastLocation = nil;
    [locationView release], locationView = nil;
    [mapLocationSearchView release], mapLocationSearchView = nil;
    [initialLocation release], initialLocation = nil;
    [introView release], introView = nil;
    [introButton release], introButton = nil;
    [photoMarkers release], photoMarkers = nil;
	
    [super dealloc];
}



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:MAPSTYLECHANGED];
	[notifications addObject:RETREIVELOCATIONPHOTOSRESPONSE];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:MAPSTYLECHANGED]){
        [self didNotificationMapStyleChanged];
    }
	
	if([notification.name isEqualToString:RETREIVELOCATIONPHOTOSRESPONSE]){
        [self refreshUIFromDataProvider];
    }
	
}


- (void) didNotificationMapStyleChanged {
	mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}


-(void)refreshUIFromDataProvider{
	
	PhotoMapListVO *photoList=[PhotoManager sharedInstance].locationPhotoList;
	
	[self clearPhotos];
	if (showingPhotos==NO) {
		photomapQuerying = NO;
		[[HudManager sharedInstance] removeHUD];
		return;
	}
	
	for (PhotoMapVO *photo in [photoList photos]) {
		RMMarker *marker = [Markers markerPhoto];
		marker.data = photo;
		[photoMarkers addObject:marker];
		[[mapView markerManager] addMarker:marker AtLatLong:[photo location]];
	}

	photomapQuerying = NO;
	[[HudManager sharedInstance] removeHUD];
	
	
}


//
/***********************************************
 * @description			View Methods
 ***********************************************/
//


- (void)viewDidLoad {
	
    [super viewDidLoad];
		
	[self createPersistentUI];
	
	
}


-(void)createPersistentUI{
	
	//Necessary to start route-me service
	[RMMapView class];
	[[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]] autorelease];
	[mapView setDelegate:self];
	[[mapView markerManager] removeMarkers];
	
	
	self.photoMarkers = [[[NSMutableArray alloc] init] autorelease];
	
	[blueCircleView setLocationProvider:self];
	
	//get the map attribution correct.
	self.attributionLabel.text = [MapViewController mapAttribution];
	
	//set up the location manager.
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy=500;
	locationManagerIsLocating = NO;
	locationWasFound=YES;
		
	showingPhotos = YES;
	
	//[self performSelector:@selector(requestPhotos) withObject:nil afterDelay:0.0];
	
	[ButtonUtilities styleIBButton:introButton type:@"green" text:@"OK"];
	
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




#pragma mark Photo Markers
//
/***********************************************
 * @description			Photo Marker Methods
 ***********************************************/
//	


- (void) requestPhotos {
	
	BetterLog(@"");
	
	if (photomapQuerying || !showingPhotos) return;
	photomapQuerying = YES;
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:nil andMessage:nil];
	
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

// DEPRECATED
- (PhotoMapVO *) randomPhoto {
	
	if (photoMarkers == nil || [photoMarkers count] == 0) return nil;
	srand( time( NULL));
	int i = random() % [photoMarkers count];
	return (PhotoMapVO *)((RMMarker *)[photoMarkers objectAtIndex:i]).data;
}


// TODO: All this will be moved the Photo Model

- (void) clearPhotos {

	if (photoMarkers != nil) {
		[[mapView markerManager] removeMarkers:photoMarkers];
		[photoMarkers removeAllObjects];
	}
	
}

- (void) didSucceedPhoto:(XMLRequest *)request results:(NSDictionary *)elements {
	
	BetterLog(@"");
	
	[self clearPhotos];
	if (showingPhotos==NO) {
		photomapQuerying = NO;
		[[HudManager sharedInstance] removeHUD];
		return;
	}
	
	
	PhotoMapListVO *photoList = [[PhotoMapListVO alloc] initWithElements:elements];
	for (PhotoMapVO *photo in [photoList photos]) {
		RMMarker *marker = [Markers markerPhoto];
		marker.data = photo;
		[photoMarkers addObject:marker];
		[[mapView markerManager] addMarker:marker AtLatLong:[photo location]];
	}
	[photoList release];
	photomapQuerying = NO;
	[[HudManager sharedInstance] removeHUD];
}

- (void) didFailPhoto:(XMLRequest *)request message:(NSString *)message {
	[self clearPhotos];
	photomapQuerying = NO;
	[[HudManager sharedInstance] removeHUD];
}

//helper, could be shelled out as more general.
- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	BetterLog(@"");
	
	[[PhotoManager sharedInstance] retrievePhotosForLocationBounds:ne withEdge:sw];
	
	/*
	QueryPhoto *queryPhoto = [[QueryPhoto alloc] initNorthEast:ne SouthWest:sw];
	[queryPhoto runWithTarget:self onSuccess:@selector(didSucceedPhoto:results:) onFailure:@selector(didFailPhoto:message:)];
	[queryPhoto release];
	 */
}


//
/***********************************************
 * @description			MapView delegate methods
 ***********************************************/
//


-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
}

- (void) afterMapMove: (RMMapView*) map {
	
	BetterLog(@"");
	
	[blueCircleView setNeedsDisplay];
	[self requestPhotos];
}


- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[blueCircleView setNeedsDisplay];
	[self requestPhotos];
}






#pragma mark toolbar actions
//
/***********************************************
 * @description			UI Events
 ***********************************************/
//

- (IBAction) didZoomIn {
	BetterLog(@"zoomin");
	if ([mapView.contents zoom] < MAX_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] + 1];
		[blueCircleView setNeedsDisplay];
	}
	[self requestPhotos];
}

- (IBAction) didZoomOut {
	BetterLog(@"zoomout");
	if ([mapView.contents zoom] > MIN_ZOOM) {
		[mapView.contents setZoom:[mapView.contents zoom] - 1];
		[blueCircleView setNeedsDisplay];
	}
	[self requestPhotos];
}

- (IBAction) didLocation {
	BetterLog(@"location");
	if (!locationManagerIsLocating) {
		[self startlocationManagerIsLocating];
	} else {
		[self stoplocationManagerIsLocating];
	}
}

- (IBAction) didShowPhotos {
	BetterLog(@"showPhotos");
	if (!showingPhotos) {
		[self startShowingPhotos];
	} else {
		[self stopShowingPhotos];
	}
}

- (IBAction) didSearch {
	BetterLog(@"search");
	if (mapLocationSearchView == nil) {
		mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}	
	mapLocationSearchView.locationReceiver = self;
	mapLocationSearchView.centreLocation = [[mapView contents] mapCenter];
	[self presentModalViewController:mapLocationSearchView	animated:YES];
}

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
	BetterLog(@"tapMarker");
	//if (locationView == nil) {
		PhotoMapImageLocationViewController *lv = [[PhotoMapImageLocationViewController alloc] initWithNibName:@"PhotoMapImageLocationView" bundle:nil];
	//}
	if ([marker.data isKindOfClass: [PhotoMapVO class]]) {
		[self presentModalViewController:lv animated:YES];
		PhotoMapVO *photoEntry = (PhotoMapVO *)marker.data;
		[lv loadContentForEntry:photoEntry];
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
//
/***********************************************
 * @description			Location Manager methods
 ***********************************************/
//

// called from toggled ui button, stops CL and removes circle view
- (void)stoplocationManagerIsLocating {
	locationManagerIsLocating = NO;
	gpslocateButton.style = UIBarButtonItemStyleBordered;
	[locationManager stopUpdatingLocation];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
	blueCircleView.hidden = YES;
}

// called from ui button, starts CL and shows circle view
- (void)startlocationManagerIsLocating {
	
	if([CLLocationManager locationServicesEnabled]==YES){
		
		locationManagerIsLocating = YES;
		locationWasFound=NO;
		gpslocateButton.style = UIBarButtonItemStyleDone;
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
			[self requestPhotos];
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

#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	[mapView moveToLatLong: location];
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


#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.gpslocateButton = nil;

	mapView = nil;
	
	self.attributionLabel = nil;
	self.blueCircleView = nil;
	self.introView = nil;
	self.introButton = nil;
	locationManager = nil;
	locationView = nil;
	lastLocation = nil;
	initialLocation = nil;
	mapLocationSearchView = nil;	
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
	BetterLog(@">>>");
}



@end
