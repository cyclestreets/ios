//
//  RKLocationManager.m
//  Racing UK
//
//  Created by neil on 12/11/09.
//  Copyright 2009 Chroma. All rights reserved.
//

#import "RKLocationManager.h"

static const NSTimeInterval kDetectionTimeoutInSeconds = 6.0;

@implementation RKLocationManager
@synthesize detectionBeginTime,currentLocation;


- (id)init
{
	if (self = [super init])
	{
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		isLocating = NO;
	}
	return self;
}

- (void)dealloc;
{
    [locationManager setDelegate:nil];
    [locationManager release],locationManager=nil;
	[detectionBeginTime release],detectionBeginTime=nil;
    [currentLocation release],currentLocation=nil;
    [super dealloc];
}

-(void)startDetectingCurrentLocation {
	if (!isLocating)
	{
		NSDate *now = [[NSDate alloc]init];
		
		if ((locationManager.location == nil) || ([now timeIntervalSinceDate:locationManager.location.timestamp] > 30))
		{
			self.detectionBeginTime = now;
			isLocating = YES;
			timer = [NSTimer scheduledTimerWithTimeInterval:kDetectionTimeoutInSeconds target:self selector:@selector(detectionTimeout:) userInfo:nil repeats:NO];
			[locationManager startUpdatingLocation];
		}
		[now release];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//NSLog([NSString stringWithFormat:@"Old:%@",[oldLocation description]]);
	//NSLog([NSString stringWithFormat:@"New:%@",[newLocation description]]);	  
	//NSLog([NSString stringWithFormat:@"Loc:%@",[manager.location description]]);	  
	//NSLog([NSString stringWithFormat:@"detectionBeginTime:%@",[detectionBeginTime description]]);	 
	NSComparisonResult dateComparison = [detectionBeginTime compare: newLocation.timestamp];
	if ((dateComparison != NSOrderedDescending) && (!signbit(newLocation.horizontalAccuracy)) )
	{
		if (self.currentLocation == nil)
		{
			self.currentLocation = newLocation;
		}
		else
		{
			double distance = [newLocation distanceFromLocation:self.currentLocation];
			if (distance < 0) distance = - distance;
			if (distance > 100)
			{
				self.currentLocation = newLocation;
			}
		}
	}
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	BOOL shouldStop = YES;
	if ([error domain] == kCLErrorDomain)
	{
		//handle CoreLocation-related errors here
		switch ([error code]) 
		{
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
				//
			case kCLErrorDenied:
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, keep waiting or prompt the user.
				//
			case kCLErrorLocationUnknown:
				shouldStop = NO;
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				break;
		}
	}
	
	if (shouldStop)
	{
		[timer invalidate];
		timer = nil;
		[locationManager stopUpdatingLocation];
		isLocating = NO;
	}
}

-(void)detectionTimeout:(NSTimer*)theTimer
{
	[timer invalidate];
	timer = nil;
	[locationManager stopUpdatingLocation];

	if (locationManager.location == nil) 
	{
		isLocating = NO;
	}
	else  if ((self.currentLocation ==nil) || (abs([locationManager.location distanceFromLocation:self.currentLocation]) > 100))
	{
		self.currentLocation = locationManager.location;
	}
	else
	{
		isLocating = NO;
	}
}



@end
