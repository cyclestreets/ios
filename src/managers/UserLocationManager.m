//
//  UserLocationManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 28/09/2012.
//  Copyright (c) 2012 CycleStreets. All rights reserved.
//

// Handles gobal lgps lookups

#import "UserLocationManager.h"
#import "DeviceUtilities.h"
#import "GlobalUtilities.h"
#import "GenericConstants.h"

@interface UserLocationManager(Private)

-(void)initialiseCorelocation;
-(void)resetLocationAndReAssess;
-(void)assessUserLocation;
- (void)stopUpdatingLocation:(NSString *)subscriberId;
-(void)UserLocationWasUpdated;

-(BOOL)addSubscriber:(NSString*)subscriberId;
-(BOOL)removeSubscriber:(NSString*)subscriberId;
-(NSUInteger)findSubscriber:(NSString*)subscriberId;
-(void)removeAllSubscribers;


@end

@implementation UserLocationManager
SYNTHESIZE_SINGLETON_FOR_CLASS(UserLocationManager);

@synthesize didFindDeviceLocation;
@synthesize locationState;
@synthesize isLocating;
@synthesize locationSubscribers;
@synthesize locationManager;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;
@synthesize delegate;
@synthesize authorisationSubscriber;


+ (CLLocationCoordinate2D)defaultCoordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 52.00;
	coordinate.longitude = 0.0;
	return coordinate;
}

+ (CLLocation*)defaultLocation {
	
	CLLocationCoordinate2D coordinate=[UserLocationManager defaultCoordinate];
	CLLocation *location=[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
	return location;
}



+(BOOL)isSignificantLocationChange:(CLLocationCoordinate2D)oldCordinate newLocation:(CLLocationCoordinate2D)newCoordinate accuracy:(int)accuracy{
	
	static NSNumberFormatter *_coordDecimalPlaceFormatter = nil;
	if ( _coordDecimalPlaceFormatter == nil )
		_coordDecimalPlaceFormatter = [[NSNumberFormatter alloc] init];
	[_coordDecimalPlaceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[_coordDecimalPlaceFormatter setMaximumFractionDigits:accuracy];
	
	// reduce decimal places
	NSNumber *newlatNumber=[NSNumber numberWithDouble:oldCordinate.latitude];
	NSNumber *newlongNumber=[NSNumber numberWithDouble:oldCordinate.longitude];
	NSNumber *newlat=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:newlatNumber] doubleValue]];
	NSNumber *newlongt=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:newlongNumber] doubleValue]];
	
	
	NSNumber *oldlatNumber=[NSNumber numberWithDouble:newCoordinate.latitude];
	NSNumber *oldlongNumber=[NSNumber numberWithDouble:newCoordinate.longitude];
	NSNumber *oldlat=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:oldlatNumber] doubleValue]];
	NSNumber *oldlongt=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:oldlongNumber] doubleValue]];

	return (![newlat  isEqualToNumber:oldlat] && ![newlongt isEqualToNumber:oldlongt] );
	
}

+(NSString*)optimisedCoordString:(CLLocationCoordinate2D)coordinate{
	
	static NSNumberFormatter *_coordDecimalPlaceFormatter = nil;
	if ( _coordDecimalPlaceFormatter == nil )
		_coordDecimalPlaceFormatter = [[NSNumberFormatter alloc] init];
	[_coordDecimalPlaceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[_coordDecimalPlaceFormatter setMaximumFractionDigits:4];
	
	NSNumber *newlatNumber=[NSNumber numberWithDouble:coordinate.latitude];
	NSNumber *newlongNumber=[NSNumber numberWithDouble:coordinate.longitude];
	NSNumber *newlat=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:newlatNumber] doubleValue]];
	NSNumber *newlongt=[NSNumber numberWithDouble:[[_coordDecimalPlaceFormatter stringFromNumber:newlongNumber] doubleValue]];
	
	return [NSString stringWithFormat:@"%@,%@",newlat,newlongt];
	
}


-(id)init{
	
	if (self = [super init])
	{
        BetterLog(@"");
		
		didFindDeviceLocation=NO;
        isLocating=NO;
		
		
		self.locationSubscribers=[NSMutableArray array];
		
		locationState=kConnectLocationStateSingle;
		
        [self initialiseCorelocation];
        
		
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


- (BOOL)hasSubscriber:(NSString*)subscriber{
	
	NSUInteger index=[self findSubscriber:subscriber];
	
	return index!=NSNotFound;
    
}


-(BOOL)systemLocationServicesEnabled{
	
	BOOL result=[CLLocationManager locationServicesEnabled];
	
	return result;
	
}

-(BOOL)appLocationServicesEnabled{
	
	CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
	
	BOOL result=status==kCLAuthorizationStatusAuthorized;
	
	return result;
	
}

-(BOOL)doesDeviceAllowLocation{
	
	return [self systemLocationServicesEnabled] && [self appLocationServicesEnabled];
	
}


-(BOOL)checkLocationStatus:(BOOL)showAlert{
	
	
	if([self doesDeviceAllowLocation]==NO){
        
		if(showAlert==YES){
			
			UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
																			message:@"Unable to retrieve location. Location services for the App may be off, please enable in Settings > General > Location Services to use location based features."
																		   delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
			[servicesDisabledAlert show];
		}
		
	}
	
	
	return [self doesDeviceAllowLocation];
	
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if(status==kCLAuthorizationStatusAuthorized){
        
        if(authorisationSubscriber!=nil){
            [self startUpdatingLocationForSubscriber:authorisationSubscriber];
            authorisationSubscriber=nil;
        }
        
        
    }
    
}


-(void)requestAuthorisation{
	
	#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
	if(IS_OS_8_OR_LATER){
		[locationManager requestAlwaysAuthorization];
		[self startUpdatingLocationForSubscriber:SYSTEM];
	}
	
}


#pragma mark CoreLocation updating

//
/***********************************************
 * @description			Check for CL system pref status
 ***********************************************/
//
-(void)initialiseCorelocation{
	
	if(locationManager==nil){
			self.locationManager = [[CLLocationManager alloc] init];
			locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			locationManager.distanceFilter =kCLDistanceFilterNone;
			locationManager.delegate=self;
		
    }
		
}



//
/***********************************************
 * @description			LOCATION LOOKUP AND ASSESSMENT
 ***********************************************/
//


-(void)resetLocationAndReAssess{
	
	self.bestEffortAtLocation=nil;
	
	[self startUpdatingLocationForSubscriber:nil];
	
}



//
/***********************************************
 * @description			Location subscribers
 ***********************************************/
//
-(BOOL)addSubscriber:(NSString*)subscriberId{
	
	NSUInteger index=[self findSubscriber:subscriberId];
	
	if(index==NSNotFound){
		
		[locationSubscribers addObject:subscriberId];
		return YES;
		
	}
	return NO;
	
}

-(BOOL)removeSubscriber:(NSString*)subscriberId{
	
	NSUInteger index=[self findSubscriber:subscriberId];
	
	if(index!=NSNotFound){
		
		[locationSubscribers removeObjectAtIndex:index];
		return YES;
		
	}
	return NO;
}

-(void)removeAllSubscribers{
	
	[locationSubscribers removeAllObjects];
	
}


-(NSUInteger)findSubscriber:(NSString*)subscriberId{
	
	NSUInteger index=[locationSubscribers indexOfObject:subscriberId];
	
	return index;
}



// both start and stop need to maintain a list of subscribers
// so only 1 can affect it, ie if we recieve a stop command it will only take affect if there is only 1 subscriber

-(void)startUpdatingLocationForSubscriber:(NSString*)subscriberId{
	
	BetterLog(@"");
    
    if(isLocating==NO){
		
		if([self doesDeviceAllowLocation]==YES){
			
			BOOL result=[self addSubscriber:subscriberId];
			
			if(result==YES){
                
                BetterLog(@"[MESSAGE]: Starting location...");
                didFindDeviceLocation=NO;
				[locationManager startUpdatingLocation];
				[self performSelector:@selector(stopUpdatingLocation:) withObject:subscriberId afterDelay:3000];
			}else{
                
                BetterLog(@"[WARNING]: unable to add subscriber");
                
            }
			
		}else {
            
            BetterLog(@"[WARNING]: GPSLOCATIONDISABLED");
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONDISABLED object:nil userInfo:nil];
            
            CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
            
            if(status==kCLAuthorizationStatusNotDetermined){
                
                authorisationSubscriber=subscriberId;
				didFindDeviceLocation=NO;
                [locationManager startUpdatingLocation];
                [self performSelector:@selector(stopUpdatingLocation:) withObject:SYSTEM afterDelay:0.1];
                
            }else{
                
                BetterLog(@"[WARNING]: GPS AUTHORISATION IS: kCLAuthorizationStatusDenied");
            }
		}
            
    }else{
		
		[self addSubscriber:subscriberId];
        
    }
    
}


//
/***********************************************
 * @description			CLLocationManager  delegate callback, receives new updated location. Asses wether this is inside our preferred accuracy
 ***********************************************/
//
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	
	// option #1 last request was recent and we already have a location use this
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	
	BetterLog(@"locationAge=%f bestEffortAtLocation=%@ didFindDeviceLocation=%i",locationAge,bestEffortAtLocation,didFindDeviceLocation);
	
    if (locationAge < 5.0){
		
		if(bestEffortAtLocation!=nil){
			
			didFindDeviceLocation=YES;
			[self UserLocationWasUpdated];
			if (locationState==kConnectLocationStateSingle)
				[self stopUpdatingLocationForSubscriber:SYSTEM];
			return;
		}
		
	}
	
	// option #2  accuracy is poor
    if (newLocation.horizontalAccuracy < 0) return;
	
    // option #3 test for new location's accuracy compared to the last one
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
		
        self.bestEffortAtLocation = newLocation;
        
		BetterLog(@"newLocation.horizontalAccuracy=%f",newLocation.horizontalAccuracy);
		BetterLog(@"locationManager.desiredAccuracy=%f",locationManager.desiredAccuracy);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONUPDATE object:bestEffortAtLocation userInfo:nil];
		
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
			
			self.bestEffortAtLocation = newLocation;
			didFindDeviceLocation=YES;
			
        }
	
	// option #4 we have a location with desired accuracy
    }else{
		
		didFindDeviceLocation=YES;
	}
	
	
	switch(locationState){
			
		case kConnectLocationStateSingle:
			
			if (didFindDeviceLocation==YES){
                
				[self UserLocationWasUpdated];
				[self stopUpdatingLocationForSubscriber:SYSTEM];
				
			}
			break;
		case kConnectLocationStateTracking:
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONUPDATE object:bestEffortAtLocation userInfo:nil];
			
		break;
			
	}
    
	
	
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
	BetterLog(@" Error:=%@",error.localizedDescription);
    
    isLocating=NO;
	
	[self removeAllSubscribers];
    
    [self stopUpdatingLocation:SYSTEM];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONFAILED object:[NSNumber numberWithBool:didFindDeviceLocation] userInfo:nil];
	
	
	
}


//
/***********************************************
 * @description		notify UI that the location has been determined
 ***********************************************/
//
-(void)UserLocationWasUpdated{
	
	BetterLog(@"bestEffortAtLocation=%@",bestEffortAtLocation);
	
	if(bestEffortAtLocation!=nil)
		[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONCOMPLETE object:bestEffortAtLocation userInfo:nil];
	
}


//
/***********************************************
 * @description		Stop Location tracking, can be called via an valid response or on a timeout error
 ***********************************************/
//
- (void)stopUpdatingLocationForSubscriber:(NSString *)subscriberId {
	
	BetterLog(@"");
	
	
	if(subscriberId==SYSTEM){
		
		[self removeAllSubscribers];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GPSSYSTEMLOCATIONCOMPLETE object:bestEffortAtLocation userInfo:nil];
		
	}else{
		
		[self removeSubscriber:subscriberId];
		
	}
	
	if([locationSubscribers count]==0){
        
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        
		isLocating=NO;
        
		[locationManager stopUpdatingLocation];
		
	}
	
}

-(void)stopUpdatingLocation:(NSString *)subscriberId{
	
	[self stopUpdatingLocationForSubscriber:subscriberId];
}


//------------------------------------------------------------------------------------
#pragma mark - GeoCoding
//------------------------------------------------------------------------------------

+(void)reverseGeoCodeLocation:(CLLocation*)location{
    
    CLGeocoder *geocoder=[[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if([placemarks count]>0){
            [[NSNotificationCenter defaultCenter] postNotificationName:REVERSEGEOLOCATIONCOMPLETE object:[placemarks objectAtIndex:0] userInfo:nil];
        }else{
            // what is the error?
        }
        
    } ];
    
}

@end

