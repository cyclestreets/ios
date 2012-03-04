//
//  UserLocationManager.h
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import <CoreLocation/CoreLocation.h>

#define LocationFoundTesting 0  // gps couldnt find location, show odds allow user to refresh loation
#define AllowedLocationTesting 0 // gps found location and is disallowed do not show betting ui
#define LocationServicesTesting 0 // gps is off show odds and allow user to switch on and try again


enum  {
	kConnectLocationStateNone,
	kConnectLocationStateSingle, // one-off location update
	kConnectLocationStateTracking // continous updates (ie gps tracking)
};
typedef int ConnectLocationStates;

@interface UserLocationManager : FrameworkObject<CLLocationManagerDelegate>{
    
    BOOL                doesDeviceAllowLocation;
    BOOL                didFindDeviceLocation;
    int                 locationState;
    
    BOOL                        isLocating;
    
    CLLocationManager			*locationManager;
	NSMutableArray				*locationMeasurements;
    CLLocation					*bestEffortAtLocation;
    
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserLocationManager)
@property (nonatomic, assign)	BOOL			doesDeviceAllowLocation;
@property (nonatomic, assign)	BOOL			didFindDeviceLocation;
@property (nonatomic, assign)	int			locationState;
@property (nonatomic, assign)	BOOL			isLocating;
@property (nonatomic, retain)	CLLocationManager			*locationManager;
@property (nonatomic, retain)	NSMutableArray			*locationMeasurements;
@property (nonatomic, retain)	CLLocation			*bestEffortAtLocation;


-(void)startUpdatingLocation;
- (void)stopUpdatingLocation:(NSString *)state;

@end
