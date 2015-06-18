//
//  UserLocationManager.m
//
//  Created by Neil Edwards on 28/09/2012.
//

// Handles gobal lgps lookups

#import "UserLocationManager.h"

#import "GenericConstants.h"
#import "DeviceUtilities.h"
#import "GlobalUtilities.h"
#import <UIAlertView+BlocksKit.h>

@interface UserLocationManager()<CLLocationManagerDelegate>


@property (nonatomic, assign)	BOOL                            didFindDeviceLocation;
@property (nonatomic, assign)	ConnectLocationStates			locationState;
@property (nonatomic, assign)	BOOL                            isLocating;
@property (nonatomic, strong)	NSMutableArray                  *locationSubscribers;
@property (nonatomic, strong)	CLLocationManager               *locationManager;
@property (nonatomic, strong)	NSString                        *authorisationSubscriber;

@property (nonatomic, strong)	NSMutableArray                  *locationMeasurements;
@property (nonatomic, strong)	CLLocation                      *bestEffortAtLocation;



@end

@implementation UserLocationManager
SYNTHESIZE_SINGLETON_FOR_CLASS(UserLocationManager);


// class methods

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
		
		_didFindDeviceLocation=NO;
        _isLocating=NO;
		
		self.locationSubscribers=[NSMutableArray array];
		
		_locationState=kConnectLocationStateSingle;
		
        [self initialiseCorelocation];
        
		
	}
	return self;
}


-(void)resetLocating{
    
    [self stopUpdatingForAllSubscribers];
    _isLocating=NO;
    
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
    
    BOOL result=NO;
    if(status==kCLAuthorizationStatusAuthorized || status==kCLAuthorizationStatusAuthorizedWhenInUse){
        result=YES;
    }
    
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


-(void)displayUserLocationAlert{
	
	BOOL systemLocationON=self.systemLocationServicesEnabled;
		
	if(systemLocationON==YES){
		
		
		if(self.appLocationServicesEnabled){
			
			[self startUpdatingLocationForSubscriber:SYSTEM];
			
		}else{
			
			CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
			
			if(status==kCLAuthorizationStatusNotDetermined){
				
				[self requestAuthorisation];
				
			}else{
				
				UIAlertView *locationAlert=[UIAlertView bk_alertViewWithTitle:@"Location Services Disabled" message:@"Unable to retrieve location. Location services for the App are off. Please enable in Settings > Privacy > Location to use location based features."];
				
				[locationAlert bk_addButtonWithTitle:CANCEL handler:^{
					
				}];
				
				if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
					
					[locationAlert bk_addButtonWithTitle:@"Settings" handler:^{
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
					}];
					
					
				}
				
				[locationAlert show];
				
			}
			
			
		}

		
	}else{
		
			
		UIAlertView *locationAlert=[UIAlertView bk_alertViewWithTitle:@"System Location Services Disabled" message:@"Unable to retrieve location. Location services for the device are off. Please enable in Settings > Privacy > Location to use location based features."];
		
		[locationAlert bk_addButtonWithTitle:CANCEL handler:^{
			
		}];
		
				
		[locationAlert show];
		
		
	}
	
	
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	
    if(status==kCLAuthorizationStatusAuthorized || status==kCLAuthorizationStatusAuthorizedWhenInUse){
		
        // if this change is a result of an initial authorisation prompt execute the auth subscriber lookup
        if(_authorisationSubscriber!=nil){
            [self startUpdatingLocationForSubscriber:_authorisationSubscriber];
            _authorisationSubscriber=nil;
        }
        
        
    }
    
}


-(NSDictionary*)currentLocationDict{
    
    if([self doesDeviceAllowLocation]){
        
        return @{@"latitude":@(_bestEffortAtLocation.coordinate.latitude),@"longitude":@(_bestEffortAtLocation.coordinate.longitude)};
    }
    
    return @{@"latitude":@(52.00),@"longitude":@(0.0)};
}


// only execute if >OS8
-(BOOL)requestAuthorisation{
    
    #define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    
    
    if(IS_OS_8_OR_LATER){
        
        // if app is already authorised do normal location lookup
        if([self appLocationServicesEnabled]){
            
            [self startUpdatingLocationForSubscriber:SYSTEM];
            
            return NO;
        // else request authorisation prompt and set auth subcriber to SYSTEM
        }else{
            _authorisationSubscriber=SYSTEM;
            [_locationManager requestWhenInUseAuthorization];
        }
        
        return YES;
    }
    
    return NO;
}


#pragma mark CoreLocation updating

//
/***********************************************
 * @description			Check for CL system pref status
 ***********************************************/
//
-(void)initialiseCorelocation{
	
	if(_locationManager==nil){
			self.locationManager = [[CLLocationManager alloc] init];
			_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			_locationManager.distanceFilter =kCLDistanceFilterNone;
            _locationManager.delegate=self;
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
    
    if(subscriberId==nil)
        return NO;
	
	NSUInteger index=[self findSubscriber:subscriberId];
	
	if(index==NSNotFound){
		
		[_locationSubscribers addObject:subscriberId];
		return YES;
		
	}
	return NO;
	
}

-(BOOL)removeSubscriber:(NSString*)subscriberId{
	
	NSUInteger index=[self findSubscriber:subscriberId];
	
	if(index!=NSNotFound){
		
		[_locationSubscribers removeObjectAtIndex:index];
		return YES;
		
	}
	return NO;
}

-(void)removeAllSubscribers{
	
	[_locationSubscribers removeAllObjects];
	
}


-(NSUInteger)findSubscriber:(NSString*)subscriberId{
	
	NSUInteger index=[_locationSubscribers indexOfObject:subscriberId];
	
	return index;
}



// both start and stop need to maintain a list of subscribers
// so only 1 can affect it, ie if we recieve a stop command it will only take affect if there is only 1 subscriber

-(void)startUpdatingLocationForSubscriber:(NSString*)subscriberId{
	
	BetterLog(@"");
    
    if(_isLocating==NO){
		
		if([self doesDeviceAllowLocation]==YES){
			
			BOOL result=[self addSubscriber:subscriberId];
			
			if(result==YES){
                
                BetterLog(@"[MESSAGE]: Starting location...");
                _didFindDeviceLocation=NO;
                _isLocating=YES;
				[_locationManager startUpdatingLocation];
				[self performSelector:@selector(stopUpdatingLocation:) withObject:subscriberId afterDelay:3000];
			}else{
                
                BetterLog(@"[WARNING]: unable to add subscriber");
                
            }
			
		}else {
            
            BetterLog(@"[WARNING]: GPSLOCATIONDISABLED");
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONDISABLED object:nil userInfo:nil];
            
            CLAuthorizationStatus status=[CLLocationManager authorizationStatus];
            
            if(status==kCLAuthorizationStatusNotDetermined){
                
                 _authorisationSubscriber=subscriberId;
                _didFindDeviceLocation=NO;
                
                // if require OS8's new auth
                BOOL isAuthrequired=[self requestAuthorisation];
                
                if(isAuthrequired){
                    
                    // requestAuthorisation will call back on this method
                    
                }else{
                    [_locationManager startUpdatingLocation];
                    _isLocating=YES;
                    [self performSelector:@selector(stopUpdatingLocation:) withObject:SYSTEM afterDelay:0.1];
                    
                }
               
                
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
    
    if(_isLocating==NO)
        return;
	
	
	// option #1 last request was recent and we already have a location use this
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	
	BetterLog(@"locationAge=%f bestEffortAtLocation=%@ didFindDeviceLocation=%i",locationAge,_bestEffortAtLocation,_didFindDeviceLocation);
	
    if (locationAge < 5.0){
		
		if(_bestEffortAtLocation!=nil){
			
			_didFindDeviceLocation=YES;
			[self UserLocationWasUpdated];
			if (_locationState==kConnectLocationStateSingle)
				[self stopUpdatingLocationForSubscriber:SYSTEM];
			return;
		}
		
	}
	
	// option #2  accuracy is poor
    if (newLocation.horizontalAccuracy < 0) return;
	
    // option #3 test for new location's accuracy compared to the last one
    if (_bestEffortAtLocation == nil || _bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
		
        self.bestEffortAtLocation = newLocation;
        
		BetterLog(@"newLocation.horizontalAccuracy=%f",newLocation.horizontalAccuracy);
		BetterLog(@"locationManager.desiredAccuracy=%f",_locationManager.desiredAccuracy);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONUPDATE object:_bestEffortAtLocation userInfo:nil];
		
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
			
			self.bestEffortAtLocation = newLocation;
			_didFindDeviceLocation=YES;
			
        }
	
	// option #4 we have a location with desired accuracy
    }else{
		
		_didFindDeviceLocation=YES;
	}
	
	
	switch(_locationState){
			
		case kConnectLocationStateSingle:
			
			if (_didFindDeviceLocation==YES){
                
				[self UserLocationWasUpdated];
				[self stopUpdatingLocationForSubscriber:SYSTEM];
				
			}
			break;
		case kConnectLocationStateTracking:
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONUPDATE object:_bestEffortAtLocation userInfo:nil];
			
		break;
			
	}
    
	
	
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
	BetterLog(@" Error:=%@",error.localizedDescription);
    
    _isLocating=NO;
	
	[self removeAllSubscribers];
    
    [self stopUpdatingLocation:SYSTEM];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONFAILED object:[NSNumber numberWithBool:_didFindDeviceLocation] userInfo:nil];
	
	
	
}


//
/***********************************************
 * @description		notify UI that the location has been determined
 ***********************************************/
//
-(void)UserLocationWasUpdated{
	
	BetterLog(@"bestEffortAtLocation=%@",_bestEffortAtLocation);
	
	if(_bestEffortAtLocation!=nil)
		[[NSNotificationCenter defaultCenter] postNotificationName:GPSLOCATIONCOMPLETE object:_bestEffortAtLocation userInfo:nil];
	
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
		
	}else{
		
		[self removeSubscriber:subscriberId];
		
	}
	
	if([_locationSubscribers count]==0){
        
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        
		_isLocating=NO;
        
		[_locationManager stopUpdatingLocation];
		
	}
	
}


-(void)stopUpdatingForAllSubscribers{
    
    for (NSString *subscriber in _locationSubscribers) {
        [self stopUpdatingLocation:subscriber];
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

