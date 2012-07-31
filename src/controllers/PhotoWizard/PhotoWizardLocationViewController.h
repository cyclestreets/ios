//
//  PhotoWizardLocationViewController.h
//  CycleStreets
//
//  Created by neil on 10/03/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "RMMapView.h"
#import "RMMapViewDelegate.h"
#import <CoreLocation/CoreLocation.h>


@interface PhotoWizardLocationViewController : SuperViewController<RMMapViewDelegate, CLLocationManagerDelegate>{
    
    IBOutlet RMMapView						*mapView;				//map of current area
	RMMapContents							*mapContents;

	CLLocationManager						*locationManager; 
	CLLocation								*photolocation;		 // the exisitng photo location
    CLLocation								*userlocation;		 // the  updated location
	
	
	UILabel									*locationLabel;
	UIBarButtonItem							*closeButton;
	UIBarButtonItem							*resetButton;
	UIBarButtonItem							*updateButton;
	
    
    RMMarker								*userMarker;
    
    BOOL									avoidAccidentalTaps;
	BOOL									singleTapDidOccur;
	CGPoint									singleTapPoint;
    
    
    
}
@property (nonatomic, strong) IBOutlet RMMapView		* mapView;
@property (nonatomic, strong) RMMapContents		* mapContents;
@property (nonatomic, strong) CLLocationManager		* locationManager;
@property (nonatomic, strong) CLLocation		* photolocation;
@property (nonatomic, strong) CLLocation		* userlocation;
@property (nonatomic, strong) UILabel		* locationLabel;
@property (nonatomic, strong) UIBarButtonItem		* closeButton;
@property (nonatomic, strong) UIBarButtonItem		* resetButton;
@property (nonatomic, strong) UIBarButtonItem		* updateButton;
@property (nonatomic, strong) RMMarker		* userMarker;
@property (nonatomic) BOOL		 avoidAccidentalTaps;
@property (nonatomic) BOOL		 singleTapDidOccur;
@property (nonatomic) CGPoint		 singleTapPoint;
@end
