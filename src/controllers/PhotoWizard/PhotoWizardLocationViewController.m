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
#import "RMMarker.h"
#import "RMAnnotation.h"



@interface PhotoWizardLocationViewController()


@property (nonatomic, weak) IBOutlet RMMapView						* mapView;
@property (nonatomic, strong) IBOutlet UILabel						* locationLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* closeButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* resetButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				* updateButton;
@property (nonatomic) BOOL											avoidAccidentalTaps;
@property (nonatomic) BOOL											singleTapDidOccur;
@property (nonatomic) CGPoint										singleTapPoint;

@property (nonatomic, strong) IBOutlet UIToolbar					*modalToolBar;

@property (nonatomic,strong)  RMAnnotation							*userAnnotation;


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
	
	_mapView.enableDragging=YES;
	
	_modalToolBar.clipsToBounds=YES;
		
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
			
			[_mapView setZoom:6];
		}
		
	}
	
    
	_resetButton.enabled=_photolocation!=nil;
    
}


-(void)addAnnotationToMapAtCoorddinate:(CLLocationCoordinate2D)coordinate{
	
	
	self.userAnnotation = [RMAnnotation annotationWithMapView:_mapView coordinate:coordinate andTitle:nil];
	_userAnnotation.enabled=YES;
	_userAnnotation.title=@"Here is a title";
	_userAnnotation.annotationIcon = [UIImage imageNamed:@"UIIcon_userphotomap.png"];
	_userAnnotation.anchorPoint = CGPointMake(0.5, 1.0);
		
	[_mapView addAnnotation:_userAnnotation];
	
	
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



#pragma mark - RM Map delegate methods


- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation
{
	
	RMMapLayer *marker = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
    
    return marker;
}




- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
	
	BetterLog(@"");
	
	
	[self markerLocationDidUpdate:annotation.coordinate];
	
}


- (BOOL)mapView:(RMMapView *)map shouldDragAnnotation:(RMAnnotation *)annotation {
	
	BetterLog(@"");
	
	return YES;
	
}


- (void)mapView:(RMMapView *)map didDragAnnotation:(RMAnnotation *)annotation withDelta:(CGPoint)delta{
	
	BetterLog(@" %f %f",annotation.coordinate.latitude,annotation.coordinate.longitude);
	
	CGPoint screenPosition = CGPointMake(annotation.position.x - delta.x, annotation.position.y - delta.y);
	CGPoint screenPositionOffset = CGPointMake(annotation.position.x - delta.x, annotation.position.y - delta.y);
	
    annotation.coordinate = [_mapView pixelToCoordinate:screenPosition];
    annotation.position = screenPositionOffset;
	
	[self markerLocationDidUpdate:annotation.coordinate];
	
}


- (void)mapView:(RMMapView *)map didEndDragAnnotation:(RMAnnotation *)annotation{
	
	[self markerLocationDidUpdate:annotation.coordinate];
	
}



- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point {
	
	_userAnnotation.coordinate=[_mapView pixelToCoordinate:point];
	_userAnnotation.position=point;
	
	[self markerLocationDidUpdate:[_mapView pixelToCoordinate:point]];
	
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
	self.userMarker=nil;
	

}

@end
