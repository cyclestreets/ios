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
#import "AppDelegate.h"
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
#import "UserLocationManager.h"


static NSString *const LOCATIONSUBSCRIBERID=@"PhotoMap";


@interface PhotoMapViewController(Private)

-(void)didRecievePhotoResponse:(NSDictionary*)dict;
-(void)displayPhotosOnMap;
- (void) didNotificationMapStyleChanged;

-(void)displayLocationForMap:(CLLocationCoordinate2D)location;

-(void)locationDidFail:(NSNotification*)notification;
-(void)locationDidUpdate:(NSNotification*)notification;
-(void)locationDidComplete:(NSNotification*)notification;

-(void)removeLocationIndicator;

@end



@implementation PhotoMapViewController

static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSTimeInterval FADE_DURATION = 1.7;
@synthesize mapView;
@synthesize blueCircleView;
@synthesize attributionLabel;
@synthesize mapContents;
@synthesize gpslocateButton;
@synthesize photoWizardButton;
@synthesize locationManager;
@synthesize lastLocation;
@synthesize currentLocation;
@synthesize locationView;
@synthesize mapLocationSearchView;
@synthesize photoWizardView;
@synthesize initialLocation;
@synthesize introView;
@synthesize introButton;
@synthesize photoMarkers;
@synthesize photomapQuerying;
@synthesize showingPhotos;
@synthesize locationManagerIsLocating;
@synthesize locationWasFound;





//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:MAPSTYLECHANGED];
	[notifications addObject:RETREIVELOCATIONPHOTOSRESPONSE];
	[notifications addObject:GPSLOCATIONCOMPLETE];
	[notifications addObject:GPSLOCATIONUPDATE];
	[notifications addObject:GPSLOCATIONFAILED];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:MAPSTYLECHANGED]){
        [self didNotificationMapStyleChanged];
    }
	
	if([notification.name isEqualToString:RETREIVELOCATIONPHOTOSRESPONSE]){
        [self didRecievePhotoResponse:notification.object];
    }
	
	if([notification.name isEqualToString:GPSLOCATIONCOMPLETE]){
        [self locationDidComplete:notification];
    }
	if([notification.name isEqualToString:GPSLOCATIONUPDATE]){
        [self locationDidUpdate:notification];
    }
	if([notification.name isEqualToString:GPSLOCATIONFAILED]){
        [self locationDidFail:notification];
    }
	
}


- (void) didNotificationMapStyleChanged {
	mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}


-(void)didRecievePhotoResponse:(NSDictionary*)dict{
	
	NSString *status=[dict objectForKey:@"status"];
	
	if([status isEqualToString:SUCCESS]){
	
		[self displayPhotosOnMap];

		photomapQuerying = NO;
		
		
		// BUG fix: Map will not display markers on first load post initial location
		// data is fine but it requires another call to the server to get this to kick in?
		if(firstRun==YES){
			[self performSelector:@selector(requestPhotos) withObject:nil afterDelay:0];
			firstRun=NO;
		}
		
	}else{
		photomapQuerying=NO;
	}
	
	
}


-(void)displayPhotosOnMap{
	
	BetterLog(@"");
	
	PhotoMapListVO *photoList=[PhotoManager sharedInstance].locationPhotoList;
	
	[self clearPhotos];
	if (showingPhotos==NO) {
		photomapQuerying = NO;
		return;
	}
	
	for (PhotoMapVO *photo in [photoList photos]) {
		
		RMMarker *marker=nil;
		
		if([[PhotoManager sharedInstance] isUserPhoto:photo]){
			marker = [Markers markerUserPhoto];
		}else{
			marker = [Markers markerPhoto];
		}
		
		marker.data = photo;
		[photoMarkers addObject:marker];
		[[mapView markerManager] addMarker:marker AtLatLong:[photo location]];
	}
	
	
	
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
	
	displaysConnectionErrors=NO;
	firstRun=YES;
	
	//Necessary to start route-me service
	[RMMapView class];
	self.mapContents=[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]];
	[mapView setDelegate:self];
	[[mapView markerManager] removeMarkers];
	
	
	self.photoMarkers = [[NSMutableArray alloc] init];
	
	[blueCircleView setLocationProvider:self];
	
	//get the map attribution correct.
	self.attributionLabel.text = [MapViewController mapAttribution];
	
	//set up the location manager.
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy=500;
	locationManagerIsLocating = NO;
	locationWasFound=YES;
		
	showingPhotos = YES;
	
	[ButtonUtilities styleIBButton:introButton type:@"green" text:@"OK"];
	
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[[CycleStreets sharedInstance].files misc]];
	NSString *experienceLevel = [misc objectForKey:@"experienced"];
	if (experienceLevel != nil) {
		[self.introView removeFromSuperview];
	}
	
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated]; 
    
}


-(void)createNonPersistentUI{
    
    if([PhotoManager sharedInstance].autoLoadLocation!=nil){
		
		[self displayLocationForMap:[PhotoManager sharedInstance].autoLoadLocation.coordinate];
		
        [PhotoManager sharedInstance].autoLoadLocation=nil;
    }else{
		
		if([UserLocationManager sharedInstance].doesDeviceAllowLocation==YES){
			
			if(currentLocation==nil)
				[self locationButtonSelected:nil];
			
		}else{
			
			if(currentLocation==nil)
				[self displayLocationForMap:[UserLocationManager defaultCoordinate]];
		}
		
	}
    
}


-(void)displayLocationForMap:(CLLocationCoordinate2D)location{
	
	[mapView moveToLatLong:location];
	
	if(showingPhotos)
		[self startShowingPhotos];
	
	
}




-(void)viewWillDisappear:(BOOL)animated{
	if([UserLocationManager sharedInstance].isLocating==YES)
		[[UserLocationManager sharedInstance] stopUpdatingLocatioForSubscriber:LOCATIONSUBSCRIBERID];
	
}




#pragma mark Photo Markers
//
/***********************************************
 * @description			Photo Marker Methods
 ***********************************************/
//

// view call photomapQuerying=YES
// manager call - show hud
// manager call completes > start remove delay
// view response = photomapQuerying=NO
// view call photomapQuerying=YES



- (void) requestPhotos {
	
	BetterLog(@"");
	
	if (photomapQuerying || !showingPhotos) return;
	photomapQuerying = YES;
	
	
	
	CGRect bounds = mapView.contents.screenBounds;
	CLLocationCoordinate2D nw = [mapView pixelToLatLong:bounds.origin];
	CLLocationCoordinate2D se = [mapView pixelToLatLong:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];	
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	ne.latitude = nw.latitude;
	ne.longitude = se.longitude;
	sw.latitude = se.latitude;
	sw.longitude = nw.longitude;
	
	self.currentLocation=[[CLLocation alloc]initWithLatitude:nw.latitude longitude:nw.longitude];
	
	[self fetchPhotoMarkersNorthEast:ne SouthWest:sw];	
}

// DEPRECATED
- (PhotoMapVO *) randomPhoto {
	
	if (photoMarkers == nil || [photoMarkers count] == 0) return nil;
	srand( time( NULL));
	int i = random() % [photoMarkers count];
	return (PhotoMapVO *)((RMMarker *)[photoMarkers objectAtIndex:i]).data;
}



- (void) clearPhotos {

	if (photoMarkers != nil) {
		[[mapView markerManager] removeMarkers:photoMarkers];
		[photoMarkers removeAllObjects];
	}
	
}


- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	BetterLog(@"");
	
	[[PhotoManager sharedInstance] retrievePhotosForLocationBounds:ne withEdge:sw];
	
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


#pragma mark Location
//
/***********************************************
 * @description			Location Methods
 ***********************************************/
//

- (IBAction) locationButtonSelected:(id)sender {
	
	BetterLog(@"");
	
	if ([UserLocationManager sharedInstance].isLocating==NO) {
		
		BOOL enabled=[[UserLocationManager sharedInstance] checkLocationStatus:YES];
		
		if(enabled==YES){
			
			gpslocateButton.style = UIBarButtonItemStyleDone;
			blueCircleView.hidden = NO;
			blueCircleView.alpha=0.5f;
			
		}
		
		[[UserLocationManager sharedInstance] startUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
	} else {
		
		gpslocateButton.style = UIBarButtonItemStyleBordered;
		
		[self removeLocationIndicator];
		
		
		[[UserLocationManager sharedInstance] stopUpdatingLocatioForSubscriber:LOCATIONSUBSCRIBERID];
		
		[self requestPhotos];
	}
}

-(void)removeLocationIndicator{
	
	[blueCircleView setNeedsDisplay];
	[UIView animateWithDuration:1.2f 
						  delay:.5 
						options:UIViewAnimationCurveEaseOut 
					 animations:^{ 
						 blueCircleView.alpha=0;
					 }
					 completion:^(BOOL finished){
						 blueCircleView.hidden=YES;
					 }];
	
}


-(void)locationDidComplete:(NSNotification*)notification{
	
	BetterLog(@"");
	
	CLLocation *location=(CLLocation*)[notification object];
	
	[MapViewController zoomMapView:mapView toLocation:location];
	[blueCircleView setNeedsDisplay];
	
	gpslocateButton.style = UIBarButtonItemStyleBordered;
	[self removeLocationIndicator];
	
	[self requestPhotos];
	
}

-(void)locationDidUpdate:(NSNotification*)notification{
	
	CLLocation *location=(CLLocation*)[notification object];
	
	[MapViewController zoomMapView:mapView toLocation:location];
	[blueCircleView setNeedsDisplay];
	
}

-(void)locationDidFail:(NSNotification*)notification{
	
	gpslocateButton.style = UIBarButtonItemStyleBordered;
	blueCircleView.hidden = YES;
	
}



#pragma mark Search

- (IBAction) didSearch {
	BetterLog(@"search");
	if (mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}	
	mapLocationSearchView.locationReceiver = self;
	mapLocationSearchView.centreLocation = [[mapView contents] mapCenter];
	[self presentModalViewController:mapLocationSearchView	animated:YES];
}

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
	
	BetterLog(@"");
	
	PhotoMapImageLocationViewController *lv = [[PhotoMapImageLocationViewController alloc] initWithNibName:@"PhotoMapImageLocationView" bundle:nil];

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




#pragma mark PhotoWizard support


-(IBAction)showPhotoWizard:(id)sender{
	
	PhotoWizardViewController *photoWizard=[[PhotoWizardViewController alloc]initWithNibName:[PhotoWizardViewController nibName] bundle:nil];
	photoWizard.isModal=YES;
	
	[self presentViewController:photoWizard animated:YES completion:nil];
	
}



- (void)startShowingPhotos {
	showingPhotos = YES;
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
	float locationRadius=(lastLocation.horizontalAccuracy / metresPerPixel);
	
	return MAX(locationRadius, 40.0f);
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
