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
    
       
}

@property (nonatomic, strong) RMMarker								* userMarker;
@property (nonatomic, strong) CLLocation							* photolocation;
@property (nonatomic, strong) CLLocation							* userlocation;
@end
