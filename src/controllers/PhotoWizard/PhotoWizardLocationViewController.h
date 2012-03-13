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
    
    IBOutlet RMMapView *mapView;				//map of current area

	CLLocationManager *locationManager; 
	CLLocation *photolocation;		 // the exisitng photo location
    CLLocation *userlocation;		 // the  updated location
    
    RMMarker *userMarker;
    
    BOOL	avoidAccidentalTaps;
	BOOL	singleTapDidOccur;
	CGPoint	singleTapPoint;
    
    
    
}
@property (nonatomic, retain)	IBOutlet RMMapView			*mapView;
@property (nonatomic, retain)	CLLocationManager			*locationManager;
@property (nonatomic, retain)	CLLocation			*photolocation;
@property (nonatomic, retain)	CLLocation			*userlocation;
@property (nonatomic, retain)	RMMarker			*userMarker;
@property (nonatomic, assign)	BOOL			avoidAccidentalTaps;
@property (nonatomic, assign)	BOOL			singleTapDidOccur;
@property (nonatomic, assign)	CGPoint			singleTapPoint;
@end
