//
//  UserLocationManager.h
//
//  Created by Neil Edwards on 28/09/2012.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import  "FrameworkObject.h"
#import "SynthesizeSingleton.h"


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


@interface UserLocationManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserLocationManager)

@property (nonatomic, unsafe_unretained) id<UserLocationManagerDelegate>		 delegate;


// getters
@property ( nonatomic, readonly)	BOOL doesDeviceAllowLocation;
@property ( nonatomic, readonly)	BOOL systemLocationServicesEnabled;
@property ( nonatomic, readonly)	BOOL appLocationServicesEnabled;


// methods
-(BOOL)hasSubscriber:(NSString*)subscriber;

-(void)startUpdatingLocationForSubscriber:(NSString*)subscriberId;
-(void)stopUpdatingLocationForSubscriber:(NSString *)subscriberId;

-(BOOL)checkLocationStatus:(BOOL)showAlert;

// returns last loc and dict if unknown returns default loc
-(NSDictionary*)currentLocationDict;


-(void)resetLocating;

-(BOOL)requestAuthorisation;


// class methods
+ (CLLocationCoordinate2D)defaultCoordinate;
+ (CLLocation*)defaultLocation;

// checks accuracy of location updates
+(BOOL)isSignificantLocationChange:(CLLocationCoordinate2D)oldCordinate newLocation:(CLLocationCoordinate2D)newCoordinate accuracy:(int)accuracy;

// returns reduced accuracy coordinate
+(NSString*)optimisedCoordString:(CLLocationCoordinate2D)coordinate;

// reverse geocodes a location
+(void)reverseGeoCodeLocation:(CLLocation*)location;






@end
