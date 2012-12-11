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


@interface PhotoMapViewController()


@property (nonatomic, weak) IBOutlet RMMapView		* mapView;
@property (nonatomic, weak) IBOutlet BlueCircleView		* blueCircleView;
@property (nonatomic, weak) IBOutlet UILabel		* attributionLabel;
@property (nonatomic, strong) RMMapContents		* mapContents;
@property (nonatomic, weak) IBOutlet UIBarButtonItem		* gpslocateButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem		* photoWizardButton;
@property (nonatomic, strong) CLLocationManager		* locationManager;
@property (nonatomic, strong) CLLocation		* lastLocation;
@property (nonatomic, strong) CLLocation		* currentLocation;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, strong) MapLocationSearchViewController		* mapLocationSearchView;
@property (nonatomic, strong) PhotoWizardViewController		* photoWizardView;
@property (nonatomic, strong) InitialLocation		* initialLocation;
@property (nonatomic, weak) IBOutlet UIView		* introView;
@property (nonatomic, weak) IBOutlet UIButton		* introButton;
@property (nonatomic, strong) NSMutableArray		* photoMarkers;
@property (nonatomic, assign) BOOL		 photomapQuerying;
@property (nonatomic, assign) BOOL		 showingPhotos;
@property (nonatomic, assign) BOOL		 locationManagerIsLocating;
@property (nonatomic, assign) BOOL		 locationWasFound;
@property (nonatomic, assign) BOOL		 firstRun;


- (IBAction) locationButtonSelected:(id)sender;
-(IBAction)  showPhotoWizard:(id)sender;
- (IBAction) didSearch;
- (IBAction) didIntroButton;
- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw;
- (void)startShowingPhotos;
- (void) requestPhotos;
- (void) clearPhotos;


-(void) didRecievePhotoResponse:(NSDictionary*)dict;
-(void) displayPhotosOnMap;
-(void) didNotificationMapStyleChanged;
-(void) displayLocationForMap:(CLLocationCoordinate2D)location;
-(void) locationDidFail:(NSNotification*)notification;
-(void) locationDidUpdate:(NSNotification*)notification;
-(void) locationDidComplete:(NSNotification*)notification;
-(void) removeLocationIndicator;

@end



@implementation PhotoMapViewController

static NSInteger MAX_ZOOM = 18;
static NSInteger MIN_ZOOM = 1;

static NSTimeInterval FADE_DURATION = 1.7;





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
	_mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}


-(void)didRecievePhotoResponse:(NSDictionary*)dict{
	
	NSString *status=[dict objectForKey:@"status"];
	
	if([status isEqualToString:SUCCESS]){
	
		[self displayPhotosOnMap];

		_photomapQuerying = NO;
		
		
		// BUG fix: Map will not display markers on first load post initial location
		// data is fine but it requires another call to the server to get this to kick in?
		if(_firstRun==YES){
			[self performSelector:@selector(requestPhotos) withObject:nil afterDelay:0];
			_firstRun=NO;
		}
		
	}else{
		_photomapQuerying=NO;
	}
	
	
}


-(void)displayPhotosOnMap{
	
	BetterLog(@"");
	
	PhotoMapListVO *photoList=[PhotoManager sharedInstance].locationPhotoList;
	
	[self clearPhotos];
	if (_showingPhotos==NO) {
		_photomapQuerying = NO;
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
		[_photoMarkers addObject:marker];
		[[_mapView markerManager] addMarker:marker AtLatLong:[photo location]];
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
	_firstRun=YES;
	
	//Necessary to start route-me service
	[RMMapView class];
	self.mapContents=[[RMMapContents alloc] initWithView:_mapView tilesource:[MapViewController tileSource]];
	[_mapView setDelegate:self];
	[[_mapView markerManager] removeMarkers];
	
	
	self.photoMarkers = [[NSMutableArray alloc] init];
	
	[_blueCircleView setLocationProvider:self];
	
	//get the map attribution correct.
	self.attributionLabel.text = [MapViewController mapAttribution];
	
	//set up the location manager.
	self.locationManager = [[CLLocationManager alloc] init];
	_locationManager.desiredAccuracy=500;
	_locationManagerIsLocating = NO;
	_locationWasFound=YES;
		
	_showingPhotos = YES;
	
	[ButtonUtilities styleIBButton:_introButton type:@"green" text:@"OK"];
	
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
			
			if(_currentLocation==nil)
				[self locationButtonSelected:nil];
			
		}else{
			
			if(_currentLocation==nil)
				[self displayLocationForMap:[UserLocationManager defaultCoordinate]];
		}
		
	}
    
}


-(void)displayLocationForMap:(CLLocationCoordinate2D)location{
	
	[_mapView moveToLatLong:location];
	
	if(_showingPhotos)
		[self startShowingPhotos];
	
	
}




-(void)viewWillDisappear:(BOOL)animated{
	if([UserLocationManager sharedInstance].isLocating==YES)
		[[UserLocationManager sharedInstance] stopUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
	
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
	
	if (_photomapQuerying || !_showingPhotos) return;
	_photomapQuerying = YES;
	
	
	
	CGRect bounds = _mapView.contents.screenBounds;
	CLLocationCoordinate2D nw = [_mapView pixelToLatLong:bounds.origin];
	CLLocationCoordinate2D se = [_mapView pixelToLatLong:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];	
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
	
	if (_photoMarkers == nil || [_photoMarkers count] == 0) return nil;
	srand( time( NULL));
	int i = random() % [_photoMarkers count];
	return (PhotoMapVO *)((RMMarker *)[_photoMarkers objectAtIndex:i]).data;
}



- (void) clearPhotos {

	if (_photoMarkers != nil) {
		[[_mapView markerManager] removeMarkers:_photoMarkers];
		[_photoMarkers removeAllObjects];
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
	
	[_blueCircleView setNeedsDisplay];
	[self requestPhotos];
}


- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[_blueCircleView setNeedsDisplay];
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
	if ([_mapView.contents zoom] < MAX_ZOOM) {
		[_mapView.contents setZoom:[_mapView.contents zoom] + 1];
		[_blueCircleView setNeedsDisplay];
	}
	[self requestPhotos];
}

- (IBAction) didZoomOut {
	BetterLog(@"zoomout");
	if ([_mapView.contents zoom] > MIN_ZOOM) {
		[_mapView.contents setZoom:[_mapView.contents zoom] - 1];
		[_blueCircleView setNeedsDisplay];
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
			
			_gpslocateButton.style = UIBarButtonItemStyleDone;
			_blueCircleView.hidden = NO;
			_blueCircleView.alpha=0.5f;
			
		}
		
		[[UserLocationManager sharedInstance] startUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
	} else {
		
		_gpslocateButton.style = UIBarButtonItemStyleBordered;
		
		[self removeLocationIndicator];
		
		
		[[UserLocationManager sharedInstance] stopUpdatingLocationForSubscriber:LOCATIONSUBSCRIBERID];
		
		[self requestPhotos];
	}
}

-(void)removeLocationIndicator{
	
	[_blueCircleView setNeedsDisplay];
	[UIView animateWithDuration:1.2f 
						  delay:.5 
						options:UIViewAnimationCurveEaseOut 
					 animations:^{ 
						 _blueCircleView.alpha=0;
					 }
					 completion:^(BOOL finished){
						 _blueCircleView.hidden=YES;
					 }];
	
}


-(void)locationDidComplete:(NSNotification*)notification{
	
	BetterLog(@"");
	
	CLLocation *location=(CLLocation*)[notification object];
	
	[MapViewController zoomMapView:_mapView toLocation:location];
	[_blueCircleView setNeedsDisplay];
	
	_gpslocateButton.style = UIBarButtonItemStyleBordered;
	[self removeLocationIndicator];
	
	[self requestPhotos];
	
}

-(void)locationDidUpdate:(NSNotification*)notification{
	
	CLLocation *location=(CLLocation*)[notification object];
	
	[MapViewController zoomMapView:_mapView toLocation:location];
	[_blueCircleView setNeedsDisplay];
	
}

-(void)locationDidFail:(NSNotification*)notification{
	
	_gpslocateButton.style = UIBarButtonItemStyleBordered;
	_blueCircleView.hidden = YES;
	
}



#pragma mark Search

- (IBAction) didSearch {
	BetterLog(@"search");
	if (_mapLocationSearchView == nil) {
		self.mapLocationSearchView = [[MapLocationSearchViewController alloc] initWithNibName:@"MapLocationSearchView" bundle:nil];
	}	
	_mapLocationSearchView.locationReceiver = self;
	_mapLocationSearchView.centreLocation = [[_mapView contents] mapCenter];
	[self presentModalViewController:_mapLocationSearchView	animated:YES];
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
	
	[self presentModalViewController:photoWizard animated:YES];
	
}



- (void)startShowingPhotos {
	_showingPhotos = YES;
	[self requestPhotos];
}

#pragma mark location provider

- (float)getX {
	CGPoint p = [_mapView.contents latLongToPixel:_lastLocation.coordinate];
	return p.x;
}

- (float)getY {
	CGPoint p = [_mapView.contents latLongToPixel:_lastLocation.coordinate];
	return p.y;
}

- (float)getRadius {
	
	double metresPerPixel = [_mapView.contents metersPerPixel];
	float locationRadius=(_lastLocation.horizontalAccuracy / metresPerPixel);
	
	return MAX(locationRadius, 40.0f);
}





#pragma mark search response

- (void) didMoveToLocation:(CLLocationCoordinate2D)location {
	BetterLog(@"didMoveToLocation");
	[_mapView moveToLatLong: location];
}



- (void)saveLocation:(CLLocationCoordinate2D)location {
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[[CycleStreets sharedInstance].files misc]];
	[misc setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[misc setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[[CycleStreets sharedInstance].files setMisc:misc];	
}

- (void)fixLocationAndButtons:(CLLocationCoordinate2D)location {
	[_mapView moveToLatLong:location];
	[self saveLocation:location];	
}


#pragma mark generic class cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
	
	
	self.mapContents=nil;
	self.locationManager=nil;
	self.lastLocation=nil;
	self.currentLocation=nil;
	self.locationView=nil;
	self.mapLocationSearchView=nil;
	self.photoWizardView=nil;
	self.initialLocation=nil;
	self.photoMarkers=nil;
	

}


@end
