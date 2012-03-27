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

@implementation PhotoWizardLocationViewController
@synthesize mapView;
@synthesize locationManager;
@synthesize photolocation;
@synthesize userlocation;
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
	[[[RMMapContents alloc] initWithView:mapView tilesource:[MapViewController tileSource]] autorelease];
	[mapView setDelegate:self];
    
    
}



-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
    
    [self.mapView.markerManager addMarker:userMarker AtLatLong:photolocation.coordinate];
    
}

//
/***********************************************
 * @description			Loads any saved map lat/long and zoom
 ***********************************************/
//
-(void)loadLocation{
	
	if (userlocation!=nil) {
		
		[self.mapView moveToLatLong:userlocation.coordinate];
		
		if ([mapView.contents zoom] < 18) {
			[mapView.contents setZoom:4];
		}
		 
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
	}
	
}


//
/***********************************************
 * @description			View delegate method
 ***********************************************/
//
-(void)MarkerLocationDidUpdate:(CLLocation*)location{
    
    if([delegate respondsToSelector:@selector(UserDidUpdatePhotoLocation:)]){
        [delegate performSelector:@selector(UserDidUpdatePhotoLocation:) withObject:location];
    }
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
