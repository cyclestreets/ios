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

//  RouteSegmentViewController.m
//  CycleStreets
//
//  Created by Alan Paxton on 12/03/2010.
//


#import "RouteSegmentViewController.h"
#import "SegmentVO.h"
#import "RMMarkerManager.h"
#import "MapViewController.h"
#import "AppDelegate.h"
#import "CycleStreets.h"
#import "QueryPhoto.h"
#import "PhotoMapListVO.h"
#import "PhotoMapVO.h"
#import "PhotoMapImageLocationViewController.h"
#import "Markers.h"
#import "BlueCircleView.h"
#import "CSPointVO.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "ExpandedUILabel.h"
#import "GradientView.h"
#import "CSSegmentFooterView.h"

@interface RouteSegmentViewController()

@property (nonatomic, strong) CSSegmentFooterView						* footerView;
@property (nonatomic) BOOL												footerIsHidden;
@property (nonatomic) BOOL												photoIconsVisisble;
@property (nonatomic, strong) IBOutlet RMMapView						* mapView;
@property (nonatomic, strong) IBOutlet BlueCircleView					* blueCircleView;
@property (nonatomic, strong) CLLocation								* lastLocation;
@property (nonatomic, strong) IBOutlet RouteLineView					* lineView;
@property (nonatomic, strong) IBOutlet UILabel							* attributionLabel;
@property (nonatomic, strong) RMMapContents								* mapContents;
@property (nonatomic, strong) NSMutableArray							* photoMarkers;
@property (nonatomic, strong) IBOutlet UIToolbar						* toolBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem					* locationButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem					* infoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem					* photoIconButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem					* prevPointButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem					* nextPointButton;
@property (nonatomic) NSInteger											photosIndex;
@property (nonatomic, strong) RMMarker									* markerLocation;
@property (nonatomic, strong) CLLocationManager							* locationManager;
@property (nonatomic) BOOL												doingLocation;
@property (nonatomic, strong) PhotoMapImageLocationViewController		* locationView;
@property (nonatomic, strong) QueryPhoto								* queryPhoto;


//toolbar
- (IBAction) backButtonSelected;
- (IBAction) didLocation;
- (IBAction) didPrev;
- (IBAction) didNext;
- (IBAction) didToggleInfo;
-(IBAction)photoIconButtonSelected;

- (void)setSegmentIndex:(NSInteger)newIndex;
-(void)updateFooterPositions;
-(void)updateMapPhotoMarkers;
- (void) clearPhotos;

@end




@implementation RouteSegmentViewController



- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//handle taps etc.
	[_mapView setDelegate:self];
	
	//Necessary to start route-me service
	[RMMapView class];
	
	//get the configured map source.
	self.mapContents=[[RMMapContents alloc] initWithView:_mapView tilesource:[MapViewController tileSource]];
	
	// set up location manager
	self.locationManager = [[CLLocationManager alloc] init];
	_doingLocation = NO;
	
	[_blueCircleView setLocationProvider:self];
	_blueCircleView.hidden = YES;
	
	[_lineView setPointListProvider:self];
	
	//photo & info default to ON state
	self.infoButton.style = UIBarButtonItemStyleDone;
	self.photoIconButton.style = UIBarButtonItemStyleDone;
	
	_photoIconsVisisble=YES;
	
	_footerIsHidden=NO;
	self.footerView=[[CSSegmentFooterView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 10)];
	[_mapView addSubview:_footerView];
	
	
	self.attributionLabel.backgroundColor=UIColorFromRGBAndAlpha(0x008000,0.2);
	self.attributionLabel.text = [MapViewController mapAttribution];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didNotificationMapStyleChanged)
												 name:@"NotificationMapStyleChanged"
											   object:nil];
	
	
	UIBarButtonItem *backButton=[CustomNavigtionBar createBackButtonItemwithSelector:@selector(backButtonSelected) target:self];
	NSMutableArray *toolbaritems=[_toolBar.items mutableCopy];
	[toolbaritems insertObject:backButton atIndex:0];
	_toolBar.items=toolbaritems;
	
	
	
	UISwipeGestureRecognizer *oneFingerSwipeUp =
	[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeDown:)];
	oneFingerSwipeUp.numberOfTouchesRequired=3;
	[oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionDown];
	[_footerView addGestureRecognizer:oneFingerSwipeUp];
}

- (void)oneFingerSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
	CGPoint point = [recognizer locationInView:[self view]];
	NSLog(@"Swipe down - start location: %f,%f", point.x, point.y);
	
	[self didToggleInfo];
}




-(void)viewWillAppear:(BOOL)animated{
	
	[self setSegmentIndex:_index];
	
	[super viewWillAppear:animated];
}






- (void) didNotificationMapStyleChanged {
	_mapView.contents.tileSource = [MapViewController tileSource];
	self.attributionLabel.text = [MapViewController mapAttribution];
}



-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	BetterLog(@"");
}

- (NSArray *) pointList {
	BetterLog(@"");
	return [MapViewController pointList:self.route withView:_mapView];
}



//helper method for setSegmentIndex
- (void)setPrevNext {
	//set the prev/next/of
	[_prevPointButton setEnabled:YES];
	if (_index == 0) {
		[_prevPointButton setEnabled:NO];
	}
	[_nextPointButton setEnabled:YES];
	if (_index == [self.route numSegments]-1) {
		[_nextPointButton setEnabled:NO];
	}
	
	NSString *message = [NSString stringWithFormat:@"Stage: %d/%d", _index+1, [self.route numSegments]];
	_footerView.segmentIndexLabel.text=message;
	 
	
	[_lineView setNeedsDisplay];
}



#pragma mark Photo Icons
//
/***********************************************
 * @description			PHOTO ICON METHODS
 ***********************************************/
//


- (void) photoSuccess:(XMLRequest *)request results:(NSDictionary *)elements {
	
	BetterLog(@"");
	
	//Check we're still looking for the same page of photos	
	if (_index != _photosIndex) return;
	
	
	[self clearPhotos];
	
	if (_photoMarkers == nil) {
		self.photoMarkers = [[NSMutableArray alloc] initWithCapacity:10];
	}
	
	PhotoMapListVO *photoList = [[PhotoMapListVO alloc] initWithElements:elements];
	for (PhotoMapVO *photo in [photoList photos]) {
		RMMarker *marker = [Markers markerPhoto];
		marker.data = photo;
		[_photoMarkers addObject:marker];
		marker.hidden=!_photoIconsVisisble;
		[[_mapView markerManager] addMarker:marker AtLatLong:[photo location]];
	}
	self.queryPhoto = nil;
}


- (void) clearPhotos {
	//Clear out the previous list.
	if (_photoMarkers != nil) {
		//NSArray *oldMarkers = [photoMarkers copy];
		for (RMMarker *oldMarker in _photoMarkers) {
			[[_mapView markerManager] removeMarker:oldMarker];
		}
	}
}

- (void) photoFailureMessage:(NSString *)message {
	//is it even worth bothering to alert ?
	self.queryPhoto = nil;
}

//helper, could be shelled out as more general.
- (void)fetchPhotoMarkersNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw {
	
	BetterLog(@"");
	
	self.photosIndex = _index;//we are looking for the photos associated with this index
	self.queryPhoto = [[QueryPhoto alloc] initNorthEast:ne SouthWest:sw limit:4];
	[_queryPhoto runWithTarget:self onSuccess:@selector(photoSuccess:results:) onFailure:@selector(photoFailureMessage:)];
}


- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map {
	BetterLog(@"tapMarker");
	PhotoMapImageLocationViewController *lv=[[PhotoMapImageLocationViewController alloc] initWithNibName:@"PhotoMapImageLocationView" bundle:nil];

	if ([marker.data isKindOfClass: [PhotoMapVO class]]) {
		[self presentModalViewController:lv animated:YES];
		PhotoMapVO *photoEntry = (PhotoMapVO *)marker.data;
		[lv loadContentForEntry:photoEntry];
	}	
}

//
/***********************************************
 * @description			END PHOTO METHODS
 ***********************************************/
//


//
/***********************************************
 * @description			Update Map view by segment
 ***********************************************/
//

- (void)setSegmentIndex:(NSInteger)newIndex {
	self.index = newIndex;
	SegmentVO *segment = [self.route segmentAtIndex:_index];
	SegmentVO *nextSegment = nil;
	if (_index + 1 < [self.route numSegments]) {
		nextSegment = [self.route segmentAtIndex:_index+1];
	}
	
	// fill the labels from the segment we are showing
	_footerView.dataProvider=[segment infoStringDictionary];
	[_footerView updateLayout];
	[self updateFooterPositions];
	// centre the view around the segment
	CLLocationCoordinate2D start = [segment segmentStart];
	CLLocationCoordinate2D end = [segment segmentEnd];
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	if (start.latitude < end.latitude) {
		sw.latitude = start.latitude;
		ne.latitude = end.latitude;
	} else {
		sw.latitude = end.latitude;
		ne.latitude = start.latitude;
	}
	if (start.longitude < end.longitude) {
		sw.longitude = start.longitude;
		ne.longitude = end.longitude;
	} else {
		sw.longitude = end.longitude;
		ne.longitude = start.longitude;
	}
	[_mapView zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)sw];
	RMMarkerManager *markerManager = [_mapView markerManager];
	NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:0];
	//
	for (RMMarker *marker in [markerManager markers]) {
		[toRemove addObject:marker];
	}
	for (RMMarker *marker in toRemove) {
		if (marker != self.markerLocation) {
			//Not clear why this gets a 0 refcount in 3.1.3, but it does, so just leak it, it's small.
			[markerManager removeMarker:marker];
		}
	}
	[markerManager addMarker:[Markers markerBeginArrow:[segment startBearing]] AtLatLong:start];
	[markerManager addMarker:[Markers markerEndArrow:[nextSegment startBearing]] AtLatLong:end];
	
	[self setPrevNext];
	[self fetchPhotoMarkersNorthEast:ne SouthWest:sw];
	
	[_lineView setNeedsDisplay];
	[_blueCircleView setNeedsDisplay];
}


//
/***********************************************
 * @description			update info footer
 ***********************************************/
//

-(void)updateFooterPositions{
	
	if(_footerIsHidden==NO){
		CGRect	fframe=_footerView.frame;
		CGRect	aframe=_attributionLabel.frame;
		
		fframe.origin.y=SCREENHEIGHTWITHNAVIGATION-fframe.size.height;
		aframe.origin.y=fframe.origin.y-10-aframe.size.height;
		
		_footerView.frame=fframe;
		_attributionLabel.frame=aframe;
	}
}






 
//pop back to route overview
- (IBAction) backButtonSelected {
	[self.navigationController popViewControllerAnimated:YES];
}


// all the things that need fixed if we have asked (or been forced) to stop doing location.
- (void)stopDoingLocation {
	_doingLocation = NO;
	_locationButton.style = UIBarButtonItemStyleBordered;
	[_locationManager stopUpdatingLocation];
	[[_mapView markerManager] removeMarker:self.markerLocation];
	self.markerLocation=nil;
	_blueCircleView.hidden = YES;
}

// all the things that need fixed if we have asked (or been forced) to start doing location.
- (void)startDoingLocation {
	
	if([CLLocationManager locationServicesEnabled]==YES){
	
		_doingLocation = YES;
		_locationButton.style = UIBarButtonItemStyleDone;
		_locationManager.delegate = self;
		[_locationManager startUpdatingLocation];
		_blueCircleView.hidden = NO;
	}else {
		UIAlertView *gpsAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
														   message:@"Location services for CycleStreets are off, please enable in Settings > General > Location Services to use location based features."
														  delegate:self
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
		[gpsAlert show];
	}

}

- (IBAction) didLocation {
	//turn on/off use of location to automatically move from one map position to the next...
	BetterLog(@"location");
	_locationManager.delegate = self;
	if (!_doingLocation) {
		[self startDoingLocation];
	} else {
		[self stopDoingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if (!self.markerLocation) {
		//first location, construct the marker
		self.markerLocation = [Markers markerWaypoint];
		[[_mapView markerManager] addMarker:self.markerLocation AtLatLong: newLocation.coordinate];
	}
	[[_mapView markerManager] moveMarker:self.markerLocation AtLatLon: newLocation.coordinate];
	
	self.lastLocation = newLocation;
	
	// zooms map to show bounding box for location & segment point
	[_mapView zoomWithLatLngBoundsNorthEast:[self.route maxNorthEastForLocation:_lastLocation] SouthWest:[self.route maxSouthWestForLocation:_lastLocation]];
	
	[_lineView setNeedsDisplay];
	[_blueCircleView setNeedsDisplay];
	_blueCircleView.hidden=NO;
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	//TODO alert: What exactly does the location finding do in this view?
	[self stopDoingLocation];
	
	UIAlertView *gpsAlert = [[UIAlertView alloc] initWithTitle:@"CycleStreets"
													   message:@"Unable to retrieve location. Location services for CycleStreets may be off, please enable in Settings > General > Location Services to use location based features."
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
	[gpsAlert show];
}


//
/***********************************************
 * @description			UI button events
 ***********************************************/
//


- (IBAction) didPrev {
	if (index > 0) {
		[self setSegmentIndex:_index-1];
	}
}

- (IBAction) didNext {
	if (_index < [self.route numSegments]-1) {
		[self setSegmentIndex:_index+1];
	}
}

- (IBAction) didToggleInfo {
	
	if (_footerIsHidden==NO) {
		
		CGRect	fframe=_footerView.frame;
		CGRect	aframe=_attributionLabel.frame;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		
		fframe.origin.y=SCREENHEIGHTWITHNAVIGATION;
		aframe.origin.y=fframe.origin.y-aframe.size.height-10;
		
		_footerView.frame=fframe;
		_footerView.alpha=0;
		_attributionLabel.frame=aframe;
		
		[UIView commitAnimations];
		
		_footerIsHidden=YES;
		
	} else {
		
		CGRect	fframe=_footerView.frame;
		CGRect	aframe=_attributionLabel.frame;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		
		fframe.origin.y=SCREENHEIGHTWITHNAVIGATION-fframe.size.height;
		aframe.origin.y=fframe.origin.y-10-aframe.size.height;
		
		_footerView.frame=fframe;
		_footerView.alpha=1;
		_attributionLabel.frame=aframe;
		
		[UIView commitAnimations];
		
		_footerIsHidden=NO;
	}
}


-(IBAction)photoIconButtonSelected{
	
	_photoIconsVisisble=!_photoIconsVisisble;
	
	for (RMMarker *marker in _photoMarkers) {
		marker.hidden=!_photoIconsVisisble;
	}
	
	if(_photoIconsVisisble==YES){
		self.photoIconButton.style=UIBarButtonItemStyleDone;
	}else {
		self.photoIconButton.style=UIBarButtonItemStyleBordered;
	}

	
}


#pragma mark Location provider

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

#pragma mark mapView delegate

- (void) afterMapMove: (RMMapView*) map {
	[_lineView setNeedsDisplay];
	[_blueCircleView setNeedsDisplay];
}


- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[_lineView setNeedsDisplay];
	[_blueCircleView setNeedsDisplay];
}


-(void)updateMapPhotoMarkers{
	
	CGRect bounds = _mapView.contents.screenBounds;

	CLLocationCoordinate2D nw = [_mapView pixelToLatLong:bounds.origin];
	CLLocationCoordinate2D se = [_mapView pixelToLatLong:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
	CLLocationCoordinate2D ne;
	CLLocationCoordinate2D sw;
	ne.latitude = nw.latitude;
	ne.longitude = se.longitude;
	sw.latitude = se.latitude;
	sw.longitude = nw.longitude;
	[self fetchPhotoMarkersNorthEast:ne SouthWest:sw];
}


#pragma mark hygiene

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.footerView=nil;
	
	self.mapView = nil;
	self.blueCircleView = nil;	//overlay GPS location
	self.lineView = nil;
	self.attributionLabel = nil;
	
	//toolbar
	self.locationButton = nil;
	self.infoButton = nil;
	self.prevPointButton = nil;
	self.nextPointButton = nil;
	
	_markerLocation = nil;
	_locationManager = nil;
	_locationView = nil;
	
	self.queryPhoto = nil;
}

- (void)viewDidUnload {
	
	[self nullify];
	[super viewDidUnload];
	BetterLog(@">>>");
}


@end
