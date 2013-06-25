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


@protocol UserLocationManagerDelegate <NSObject>

@optional
-(void)locationDidFail:(NSNotification*)notification;
-(void)locationDidUpdate:(NSNotification*)notification;
-(void)locationDidComplete:(NSNotification*)notification;

@end


@interface UserLocationManager : FrameworkObject<CLLocationManagerDelegate>{
    

    BOOL						didFindDeviceLocation;
    ConnectLocationStates       locationState;
    
    BOOL                        isLocating;
	
	
	NSMutableArray				*locationSubscribers; // array of objects using manager
    
    CLLocationManager			*locationManager;
	NSMutableArray				*locationMeasurements;
    CLLocation					*bestEffortAtLocation;
	
	id<UserLocationManagerDelegate>		__unsafe_unretained delegate;

    
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserLocationManager)

@property (nonatomic, assign)	BOOL			didFindDeviceLocation;
@property (nonatomic, assign)	ConnectLocationStates			locationState;
@property (nonatomic, assign)	BOOL			isLocating;
@property (nonatomic, strong)	NSMutableArray			*locationSubscribers;
@property (nonatomic, strong)	CLLocationManager			*locationManager;
@property (nonatomic, strong)	NSMutableArray			*locationMeasurements;
@property (nonatomic, strong)	CLLocation			*bestEffortAtLocation;

@property (nonatomic, strong)	NSString			*authorisationSubscriber;


@property (nonatomic, unsafe_unretained) id<UserLocationManagerDelegate>		 delegate;

@property ( nonatomic, readonly)	BOOL doesDeviceAllowLocation;
@property ( nonatomic, readonly)	BOOL systemLocationServicesEnabled;
@property ( nonatomic, readonly)	BOOL appLocationServicesEnabled;


- (BOOL)hasSubscriber:(NSString*)subscriber;


-(void)startUpdatingLocationForSubscriber:(NSString*)subscriberId;
- (void)stopUpdatingLocationForSubscriber:(NSString *)subscriberId;

-(BOOL)checkLocationStatus:(BOOL)showAlert;


+ (CLLocationCoordinate2D)defaultCoordinate;
+ (CLLocation*)defaultLocation;

@end
