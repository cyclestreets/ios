//
//  UserLocationManager.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//  Wrapper for GPS lookups

#import "UserLocationManager.h"
#import "DeviceUtilities.h"
#import "GlobalUtilities.h"

@interface UserLocationManager(Private) 

-(void)initialiseCorelocation;
-(void)resetLocationAndReAssess;
-(void)assessUserLocation;
- (void)stopUpdatingLocation:(NSString *)state;
-(void)UserLocationWasUpdated;


@end

@implementation UserLocationManager
SYNTHESIZE_SINGLETON_FOR_CLASS(UserLocationManager);
@synthesize doesDeviceAllowLocation;
@synthesize didFindDeviceLocation;
@synthesize locationState;
@synthesize isLocating;
@synthesize locationManager;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;



//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [locationManager release], locationManager = nil;
    [locationMeasurements release], locationMeasurements = nil;
    [bestEffortAtLocation release], bestEffortAtLocation = nil;
    
    [super dealloc];
}



-(id)init{
	
	if (self = [super init])
	{
        BetterLog(@"");
		
		doesDeviceAllowLocation=YES;
		didFindDeviceLocation=NO;
		locationState=-1;
        isLocating=NO;
		
        [self initialiseCorelocation];
        
        if(doesDeviceAllowLocation==YES){
            [self assessUserLocation];
        }else {
            [self UserLocationWasUpdated];
        }
		
	}
	return self;
}


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{

	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	
}


#pragma mark CoreLocation updating

//
/***********************************************
 * @description			Check for CL system pref status
 ***********************************************/
//
-(void)initialiseCorelocation{
	
#if LocationServicesTesting
	
	self.doesDeviceAllowLocation=YES;
	
#else
    
	if([DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR){
        self.doesDeviceAllowLocation=YES;
	}else {
		
        self.doesDeviceAllowLocation=[CLLocationManager locationServicesEnabled];
        
        if (doesDeviceAllowLocation == NO) {
            UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" 
																			message:@"Unable to retrieve location. Location services for CycleStreets may be off, please enable in Settings > General > Location Services to use location based features." 
																		   delegate:nil 
                                                                  cancelButtonTitle:@"OK" 
                                                                  otherButtonTitles:nil];
            [servicesDisabledAlert show];
            
        }
    }
	
#endif
    
    
	
}



//
/***********************************************
 * @description			LOCATION LOOKUP AND ASSESSMENT
 ***********************************************/
//


-(void)resetLocationAndReAssess{
	
	self.bestEffortAtLocation=nil;
	didFindDeviceLocation=NO;
	
	[self assessUserLocation];
	
}



//
/***********************************************
 * @description		init CL location tracking	
 ***********************************************/
//
-(void)assessUserLocation{
    
    if([DeviceUtilities detectDevice]==MODEL_IPHONE_SIMULATOR){
        
		locationState=kConnectLocationStateNone;
		self.bestEffortAtLocation=[[CLLocation alloc] initWithLatitude:52.25096932352704 longitude:0.02471057283893221];
		didFindDeviceLocation=YES;
        
	}else {
        
		locationState=kConnectLocationStateSingle;
        
		if(locationManager==nil){
			self.locationManager = [[CLLocationManager alloc] init];
			locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
			locationManager.distanceFilter =kCLDistanceFilterNone;
		}
		
        
	}
	
}


-(void)startUpdatingLocation{
    
    if(isLocating==NO){
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:3000];
    }else{
        
    }
    
}


//
/***********************************************
 * @description			CLLocationManager  delegate callback, receives new updated location. Asses wether this is inside our preferred accuracy
 ***********************************************/
//
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	BetterLog(@"");
	
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	
    if (locationAge > 5.0) return;
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        
        // TODO: send current location 
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONUPDATE object:bestEffortAtLocation userInfo:nil];
        
		
		BetterLog(@"newLocation.horizontalAccuracy=%f",newLocation.horizontalAccuracy);
		BetterLog(@"locationManager.desiredAccuracy=%f",locationManager.desiredAccuracy);
		
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
			
        }
    }
	
	
	switch(locationState){
			
		case kConnectLocationStateSingle:
			
			if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
				self.bestEffortAtLocation = newLocation;
				
				if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
					[self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
					[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
                    
                    [self UserLocationWasUpdated];
				}
			}
			break;
		case kConnectLocationStateTracking:
			
			// for real time tracking via a map
			
            break;
			
	}
    
	
	
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
	BetterLog(@" Error:=%@",error.localizedDescription);
    
    isLocating=NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONFAILED object:[NSNumber numberWithBool:didFindDeviceLocation] userInfo:nil];
	
	
	
}


//
/***********************************************
 * @description		notify UI that the location has been determined	
 ***********************************************/
//
-(void)UserLocationWasUpdated{
    
    isLocating=NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONCOMPLETE object:bestEffortAtLocation userInfo:nil];
	
}


//
/***********************************************
 * @description		Stop Location tacking, can be called via an valid response or on a timeout error	
 ***********************************************/
//
- (void)stopUpdatingLocation:(NSString *)state {
	
	BetterLog(@"");
	
	// remove the delayed timeout selector
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
	
	
#if LocationFoundTesting
	didFindDeviceLocation=NO;
	
	[self UserLocationWasUpdated];
	
#else
	
	didFindDeviceLocation=YES;
#endif
    isLocating=NO;
	
	locationState=kConnectLocationStateNone;
    [locationManager stopUpdatingLocation];
	
}

@end
