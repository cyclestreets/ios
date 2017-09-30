//
//  PhotoWizardLocationViewController.m
//  CycleStreets
//
//  Created by neil on 10/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardLocationViewController.h"
#import "GlobalUtilities.h"
#import "UserLocationManager.h"
#import "CSPhotomapAnnotationView.h"
#import "CSPhotomapAnnotation.h"
#import <MapKit/MapKit.h>
#import "MKMapView+Additions.h"
#import "CSMapSource.h"
#import "CycleStreets.h"
#import "CSMapTileService.h"
#import "CSRetinaTileRenderer.h"
#import "MapViewSearchLocationViewController.h"

@interface PhotoWizardLocationViewController()<MKMapViewDelegate>


@property (nonatomic, weak) IBOutlet MKMapView						* mapView;
@property (nonatomic,strong)  CSMapSource							* activeMapSource;
@property (nonatomic, strong) IBOutlet UILabel						* locationLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* closeButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* resetButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* updateButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* searchButton;

@property (nonatomic) BOOL											avoidAccidentalTaps;
@property (nonatomic) BOOL											singleTapDidOccur;
@property (nonatomic) CGPoint										singleTapPoint;

@property (nonatomic, strong) IBOutlet UIToolbar					*modalToolBar;

@property (nonatomic,strong)  CSPhotomapAnnotation					*userAnnotation;

@property (nonatomic,strong)  UITapGestureRecognizer				*mapTapRecognizer;



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


- (void) didNotificationMapStyleChanged {
	
	
	NSArray *overlays=[_mapView overlaysInLevel:MKOverlayLevelAboveLabels];
	
	self.activeMapSource=[CycleStreets activeMapSource];
	
	[CSMapTileService updateMapStyleForMap:_mapView toMapStyle:_activeMapSource withOverlays:overlays];
	
	
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
    
	[_mapView setDelegate:self];
	
	self.mapTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnMap:)];
	_mapTapRecognizer.enabled=YES;
	[_mapView addGestureRecognizer:_mapTapRecognizer];
	
	_modalToolBar.clipsToBounds=YES;
	
	[self didNotificationMapStyleChanged];
		
}



-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
	if (_userlocation!=nil) {
		
		[self addAnnotationToMapAtCoorddinate:_userlocation.coordinate];
		
		[self showLocationOnMap:_userlocation];
		
	}else {
		
		if(_photolocation!=nil){
			
			[self addAnnotationToMapAtCoorddinate:_photolocation.coordinate];
			
			[self showLocationOnMap:_photolocation];
		}else {
			
			[self addAnnotationToMapAtCoorddinate:[UserLocationManager defaultCoordinate]];
			
			[self showLocationOnMap:[UserLocationManager defaultLocation]];
			
			[_mapView setCenterCoordinate:[UserLocationManager defaultCoordinate] zoomLevel:6 animated:YES];
		}
		
	}
	
    
	_resetButton.enabled=_photolocation!=nil;
    
}


-(void)addAnnotationToMapAtCoorddinate:(CLLocationCoordinate2D)coordinate{
	
	self.userAnnotation=[[CSPhotomapAnnotation alloc]init];
	_userAnnotation.coordinate=coordinate;
	_userAnnotation.isUserPhoto=YES;
	[_mapView addAnnotation:_userAnnotation];
	
}



-(void)showLocationOnMap:(CLLocation*)location{
	
	_locationLabel.text=[NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
	
	[_mapView setCenterCoordinate:location.coordinate zoomLevel:15 animated:YES];

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



//------------------------------------------------------------------------------------
#pragma mark - MapKit Overlays
//------------------------------------------------------------------------------------

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
	
	
	if ([overlay isKindOfClass:[MKTileOverlay class]]) {
		return [[CSRetinaTileRenderer alloc] initWithTileOverlay:overlay];
		
	}
	
	return nil;
}



#pragma mark - MKMap Annotations


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	
	static NSString *reuseId = @"CSPhotomapAnnotation";
	CSPhotomapAnnotationView *annotationView = (CSPhotomapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
	
	if (annotationView == nil){
		annotationView = [[CSPhotomapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
		annotationView.draggable=YES;
		
	} else {
		annotationView.annotation = annotation;
		annotationView.draggable=YES;
	}
	
	return annotationView;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	
	BetterLog(@"Fired");
	
	CSPhotomapAnnotation *annotation=(CSPhotomapAnnotation*)view.annotation;
	
	[self markerLocationDidUpdate:annotation.coordinate];
	
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
	
	BetterLog(@"From %lu to %lu",oldState, newState);
	
	CSPhotomapAnnotationView *annotationView=(CSPhotomapAnnotationView*)view;
	CSPhotomapAnnotation* annotation=view.annotation;
	
	
	if (newState == MKAnnotationViewDragStateEnding) {
		
		[annotationView setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
		[self markerLocationDidUpdate:annotation.coordinate];
		
    }else if (newState==MKAnnotationViewDragStateCanceling) {
		
		[annotationView setDragState:MKAnnotationViewDragStateNone]; //NOTE: doesnt seem to fire this for custom annotations
		
    }else if (newState==MKAnnotationViewDragStateDragging) {
		[self markerLocationDidUpdate:annotation.coordinate];
    }
	
	
}



- (void) didTapOnMap:(UITapGestureRecognizer*)recogniser {
	
	BetterLog(@"");
	
	CGPoint touchPoint = [recogniser locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
	
	_userAnnotation.coordinate=touchMapCoordinate;
	
	[self markerLocationDidUpdate:touchMapCoordinate];
	
}




- (void) addLocation:(CLLocationCoordinate2D)location{
	
	
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
		[_userAnnotation setCoordinate:_photolocation.coordinate];
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

- (IBAction)didSelectSearchLocationButton:(id)sender {
	
	
	MapViewSearchLocationViewController *controller=[[MapViewSearchLocationViewController alloc]initWithNibName:[MapViewSearchLocationViewController nibName] bundle:nil];
	
	[self.navigationController presentViewController:controller animated:YES completion:^{
		
	}];
	
	
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
	
	self.photolocation=nil;
	self.userlocation=nil;
	self.locationLabel=nil;
	self.closeButton=nil;
	self.resetButton=nil;
	self.updateButton=nil;
	

}

@end
