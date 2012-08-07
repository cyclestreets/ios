//
//  PhotoWizardLocationViewController.m
//  CycleStreets
//
//  Created by neil on 10/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardLocationViewController.h"
#import "GlobalUtilities.h"
#import "MapViewController.h"
#import "RMMarkerManager.h"
#import "Markers.h"
#import "UserLocationManager.h"


static NSTimeInterval ACCIDENTAL_TAP_DELAY = 0.5;
//static NSInteger MAX_ZOOM = 18;
//static NSInteger MIN_ZOOM = 1;

@interface PhotoWizardLocationViewController(Private)


- (void) singleTapDelayExpired;
- (void) addLocation:(CLLocationCoordinate2D)location;

-(void)showLocationOnMap:(CLLocation*)location;

-(void)markerLocationDidUpdate:(CLLocationCoordinate2D)coordinate;

@end



@implementation PhotoWizardLocationViewController
@synthesize mapView;
@synthesize mapContents;
@synthesize locationManager;
@synthesize photolocation;
@synthesize userlocation;
@synthesize locationLabel;
@synthesize closeButton;
@synthesize resetButton;
@synthesize updateButton;
@synthesize userMarker;
@synthesize avoidAccidentalTaps;
@synthesize singleTapDidOccur;
@synthesize singleTapPoint;



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
	[super listNotificationInterests];
	
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
	mapContents=[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]];
	[mapView setDelegate:self];
	
	if (!self.userMarker) {
		self.userMarker = [Markers markerPhoto];
		self.userMarker.enableDragging=YES;
	}
	
	
}



-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
	if (userlocation!=nil) {
		
		
		[self.mapView.markerManager addMarker:userMarker AtLatLong:userlocation.coordinate];
		
		[self showLocationOnMap:userlocation];
		
	}else {
		
		if(photolocation!=nil){
			
			[self.mapView.markerManager addMarker:userMarker AtLatLong:photolocation.coordinate];
			
			[self showLocationOnMap:photolocation];
		}else {
			
			[self.mapView.markerManager addMarker:userMarker AtLatLong:[UserLocationManager defaultCoordinate]];
			
			[self showLocationOnMap:[UserLocationManager defaultLocation]];
			
			[mapView.contents setZoom:6];
		}
		
	}
	
    
	resetButton.enabled=photolocation!=nil;
    
}



-(void)showLocationOnMap:(CLLocation*)location{
	
	locationLabel.text=[NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
	
	[self.mapView moveToLatLong:location.coordinate];
	
	if ([mapView.contents zoom] < 18) {
		[mapView.contents setZoom:15];
	}
	
}


//
/***********************************************
 * @description			Loads any saved map lat/long and zoom
 ***********************************************/
//
-(void)loadLocation{
	
	if (userlocation!=nil) {
		
		[self showLocationOnMap:userlocation];
		 
	}
}

//
/***********************************************
 * @description			RM  methods
 ***********************************************/
//
// Should only return yes is marker is start/end and we have not a route drawn
- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	BetterLog(@"");
	
	BOOL result=NO;
	if (marker==userMarker) {
		result=YES;
	}
	mapView.enableDragging=!result;
	return result;
}


- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	NSSet *touches = [event touchesForView:map]; 
	
	BetterLog(@"touches=%i",[touches count]);
	
	for (UITouch *touch in touches) {
		CGPoint point = [touch locationInView:map];
		CLLocationCoordinate2D location = [map pixelToLatLong:point];
		[[map markerManager] moveMarker:marker AtLatLon:location];
		[self markerLocationDidUpdate:location];
	}
	
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

- (void) addLocation:(CLLocationCoordinate2D)location{
	
	[self.mapView.markerManager addMarker:userMarker AtLatLong:location];
	[self markerLocationDidUpdate:location];
}



//
/***********************************************
 * @description			UI events
 ***********************************************/
//


-(IBAction)closeButtonSelected:(id)sender{
	
	[self dismissModalViewControllerAnimated:YES];
	
}

-(IBAction)resetButtonSelected:(id)sender{
	
	if(photolocation!=nil){
		[self.mapView.markerManager addMarker:userMarker AtLatLong:photolocation.coordinate];
		self.userlocation=nil;
		
		[self showLocationOnMap:photolocation];
		
	}
	
}

-(IBAction)updateButtonSelected:(id)sender{
	
	if([delegate respondsToSelector:@selector(UserDidUpdatePhotoLocation:)]){
        [delegate performSelector:@selector(UserDidUpdatePhotoLocation:) withObject:userlocation];
    }
	
	[self dismissModalViewControllerAnimated:YES];
	
}


//
/***********************************************
 * @description			View delegate method
 ***********************************************/
//
-(void)markerLocationDidUpdate:(CLLocationCoordinate2D)coordinate{
	
	self.userlocation=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	
	locationLabel.text=[NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];
	
    
   
}


#pragma mark Generic
//
/***********************************************
 * @description			generic
 ***********************************************/
//

-(void)viewDidUnload{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
