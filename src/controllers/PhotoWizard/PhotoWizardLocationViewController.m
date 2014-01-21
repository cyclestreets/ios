//
//  PhotoWizardLocationViewController.m
//  CycleStreets
//
//  Created by neil on 10/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardLocationViewController.h"
#import "GlobalUtilities.h"
#import "Markers.h"
#import "UserLocationManager.h"


static NSTimeInterval ACCIDENTAL_TAP_DELAY = 0.5;
//static NSInteger MAX_ZOOM = 18;
//static NSInteger MIN_ZOOM = 1;

@interface PhotoWizardLocationViewController()


@property (nonatomic, weak) IBOutlet RMMapView						* mapView;
@property (nonatomic, strong) CLLocationManager						* locationManager;
@property (nonatomic, strong) UILabel								* locationLabel;
@property (nonatomic, strong) UIBarButtonItem						* closeButton;
@property (nonatomic, strong) UIBarButtonItem						* resetButton;
@property (nonatomic, strong) UIBarButtonItem						* updateButton;
@property (nonatomic) BOOL											avoidAccidentalTaps;
@property (nonatomic) BOOL											singleTapDidOccur;
@property (nonatomic) CGPoint										singleTapPoint;



- (void) singleTapDelayExpired;
- (void) addLocation:(CLLocationCoordinate2D)location;
-(void)showLocationOnMap:(CLLocation*)location;
-(void)markerLocationDidUpdate:(CLLocationCoordinate2D)coordinate;


@end



@implementation PhotoWizardLocationViewController


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
	[_mapView setDelegate:self];
	
	if (!self.userMarker) {
		self.userMarker = [Markers markerPhoto];
		//self.userMarker.enableDragging=YES;
	}
	
	
}



-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
	if (_userlocation!=nil) {
		
		
		//[_mapView.markerManager addMarker:_userMarker AtLatLong:_userlocation.coordinate];
		
		[self showLocationOnMap:_userlocation];
		
	}else {
		
		if(_photolocation!=nil){
			
			//[_mapView.markerManager addMarker:_userMarker AtLatLong:_photolocation.coordinate];
			
			[self showLocationOnMap:_photolocation];
		}else {
			
			//[_mapView.markerManager addMarker:_userMarker AtLatLong:[UserLocationManager defaultCoordinate]];
			
			[self showLocationOnMap:[UserLocationManager defaultLocation]];
			
			[_mapView setZoom:6];
		}
		
	}
	
    
	_resetButton.enabled=_photolocation!=nil;
    
}



-(void)showLocationOnMap:(CLLocation*)location{
	
	_locationLabel.text=[NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
	
	[_mapView setCenterCoordinate:location.coordinate];
	
	if ([_mapView zoom] < 18) {
		[_mapView setZoom:15];
	}
	
}


//
/***********************************************
 * @description			Loads any saved map lat/long and zoom
 ***********************************************/
//
-(void)loadLocation{
	
	if (_userlocation!=nil) {
		
		[self showLocationOnMap:_userlocation];
		 
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
	if (marker==_userMarker) {
		result=YES;
	}
	_mapView.enableDragging=!result;
	return result;
	
}


- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	NSSet *touches = [event touchesForView:map]; 
	
	BetterLog(@"touches=%i",[touches count]);
	
	for (UITouch *touch in touches) {
		CGPoint point = [touch locationInView:map];
		CLLocationCoordinate2D location = [map pixelToCoordinate:point];
		//[[map markerManager] moveMarker:_userMarker AtLatLon:location];
		[self markerLocationDidUpdate:location];
	}
	
	
	
}

- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point {
	
	if(_singleTapDidOccur==NO){
		_singleTapDidOccur=YES;
		_singleTapPoint=point;
		[self performSelector:@selector(singleTapDelayExpired) withObject:nil afterDelay:ACCIDENTAL_TAP_DELAY];
		
	}
}

-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
	_singleTapDidOccur=NO;
	
	float nextZoomFactor = [map nextNativeZoomFactor];
	if (nextZoomFactor != 0)
		[map zoomByFactor:nextZoomFactor near:point animated:YES];
	
}


- (void) singleTapDelayExpired {
	if(_singleTapDidOccur==YES){
		_singleTapDidOccur=NO;
		CLLocationCoordinate2D location = [_mapView pixelToCoordinate:_singleTapPoint];
		[self addLocation:location];
	}
}

- (void) addLocation:(CLLocationCoordinate2D)location{
	
	//[_mapView.markerManager addMarker:_userMarker AtLatLong:location];
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
	
	if(_photolocation!=nil){
		//[_mapView.markerManager addMarker:_userMarker AtLatLong:_photolocation.coordinate];
		self.userlocation=nil;
		
		[self showLocationOnMap:_photolocation];
		
	}
	
}

-(IBAction)updateButtonSelected:(id)sender{
	
	if([delegate respondsToSelector:@selector(UserDidUpdatePhotoLocation:)]){
        [delegate performSelector:@selector(UserDidUpdatePhotoLocation:) withObject:_userlocation];
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
	
	_locationLabel.text=[NSString stringWithFormat:@"%f, %f",coordinate.latitude,coordinate.longitude];
	
    
   
}


#pragma mark Generic
//
/***********************************************
 * @description			generic
 ***********************************************/
//


- (void)didReceiveMemoryWarning{
	
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
	
	self.locationManager=nil;
	self.photolocation=nil;
	self.userlocation=nil;
	self.locationLabel=nil;
	self.closeButton=nil;
	self.resetButton=nil;
	self.updateButton=nil;
	self.userMarker=nil;
	

}

@end
