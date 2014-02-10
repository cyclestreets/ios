//
//  HCBackgroundLocationManager.m
//  CycleStreets
//
//  Created by Neil Edwards on 31/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "HCBackgroundLocationManager.h"
#import "SynthesizeSingleton.h"
#import "GlobalUtilities.h"
#import "TripManager.h"
#import "UserLocationManager.h"
#import "SettingsManager.h"

#import <CoreLocation/CoreLocation.h>


#define kDistanceCalculationInterval 10 // the interval (seconds) at which we calculate the user's distance
#define kNumLocationHistoriesToKeep 5 // the number of locations to store in history so that we can look back at them and determine which is most accurate
#define kValidLocationHistoryDeltaInterval 3 // the maximum valid age in seconds of a location stored in the location history
#define kMinLocationsNeededToUpdateDistance 3 // the number of locations needed in history before we will even update the current distance
#define kRequiredHorizontalAccuracy 50.0f // the required accuracy in meters for a location.  anything above this number will be discarded

static int const AUTOCOMPLETROUTEINTERVAL = 1*TIME_MINUTE;



@interface HCBackgroundLocationManager() <CLLocationManagerDelegate>

@property (nonatomic,strong)  CLLocationManager									*locationManager;
@property (nonatomic,strong)  NSMutableArray									*locationHistory;
@property (nonatomic,strong)  NSDate											*startTimestamp;
@property (nonatomic,assign)  int												lastDistanceCalculation;

@property (nonatomic,strong)  CLLocation										*currentRecordedLocation;
@property (nonatomic,strong)  CLLocation										*lastRecordedLocation;

@property (nonatomic,assign)  BOOL												deferringUpdates;

// background auto complete
@property (nonatomic,assign)  UIBackgroundTaskIdentifier						autoCompleteTask;
@property (nonatomic,strong)  NSTimer											*autoCompleteTimer;


@end



@implementation HCBackgroundLocationManager
SYNTHESIZE_SINGLETON_FOR_CLASS(HCBackgroundLocationManager);



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[notifications addObject:UIApplicationDidEnterBackgroundNotification];
	
	[notifications addObject:UIApplicationWillEnterForegroundNotification];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
		[self startBackgroundLocating];
	}
	
	if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
		[self stopBackgroundLocating];
	}
	
}


/**
 * Called by UIApplicationDidEnterBackgroundNotification, will create new location manager if Trip recording is active
 */
- (void)startBackgroundLocating {
	
	
	
	BOOL isRecording=[TripManager sharedInstance].isRecording;
	
	if(isRecording==YES){
		
		BetterLog(@"");
		
		if ([CLLocationManager locationServicesEnabled]) {
			self.locationManager = [[CLLocationManager alloc] init];
			self.locationManager.delegate = self;
			self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
			self.locationManager.distanceFilter = 5; // specified in meters
			self.locationManager.activityType=CLActivityTypeFitness;
			self.locationManager.pausesLocationUpdatesAutomatically = YES;
			
			[self.locationManager startUpdatingLocation];
		}
		
		self.locationHistory = [NSMutableArray arrayWithCapacity:kNumLocationHistoriesToKeep];
		
		
	}else{
		
		[self stopBackgroundLocating];
	}
	
}


/**
 *  Called by UIApplicationWillEnterForegroundNotification, will stop all updating and destroy this location manager
 At this point RM's location manager should start and take over delivering delegate calls to the app
 */
-(void)stopBackgroundLocating{
	
	BetterLog(@"");
	
	if(_locationManager!=nil){
		
		[self.locationManager stopUpdatingLocation];
		
		[self stopBackgroundAutoCompletion];
		
		self.locationManager=nil;
		
	}
	
}


// assess wether user has been in the same place too long
-(void)determineUserLocationStopped{
	
	BOOL autoCompleteActive = [SettingsManager sharedInstance].dataProvider.autoEndRoute;
	
	if(autoCompleteActive==YES){
		
		BOOL isSignificantLocationChange=[UserLocationManager isSignificantLocationChange:_currentRecordedLocation.coordinate newLocation:_lastRecordedLocation.coordinate accuracy:4];
		
		// if we are detemrined to be statci, start background timer task
		if(isSignificantLocationChange==NO){
			
			if(_autoCompleteTimer!=nil)
				[_autoCompleteTimer invalidate];
			
			__weak __typeof(&*self)weakSelf = self;
			
			// set up background task
			UIApplication*    app = [UIApplication sharedApplication];
			self.autoCompleteTask = [app beginBackgroundTaskWithExpirationHandler:^{
				[app endBackgroundTask:_autoCompleteTask];
				_autoCompleteTask = UIBackgroundTaskInvalid;
			}];
			
			// dispatch timer as task
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				
				self.autoCompleteTimer = [NSTimer timerWithTimeInterval:AUTOCOMPLETROUTEINTERVAL
																 target:weakSelf
															   selector:@selector(timerDidFinishForAutoComplete:)
															   userInfo:nil
																repeats:NO];
				
				[[NSRunLoop mainRunLoop] addTimer:_autoCompleteTimer  forMode:NSDefaultRunLoopMode];
			});
			
		
			// if we have moved stop the background timer and task
		}else{
			
			[self stopBackgroundAutoCompletion];
		}
		
	}
	
}

// Stop background task adn invalidate timer
-(void)stopBackgroundAutoCompletion{
	
	UIApplication*    app = [UIApplication sharedApplication];
	[app endBackgroundTask:_autoCompleteTask];
	_autoCompleteTask = UIBackgroundTaskInvalid;
	
	if(_autoCompleteTimer!=nil)
		[_autoCompleteTimer invalidate];
	
}


// timer completion selector, call auto complete on Trip manager then stops further background task execution
-(void)timerDidFinishForAutoComplete:(NSTimer*)timer{
	
	[[TripManager sharedInstance] completeTripAutomatically];
	
	[self stopBackgroundAutoCompletion];
	
}







	/**
 *  Note this a deprecated delegate method. Receives the gps updates and does some filtering so we only use useful, well spaced values
 *
 *  @param manager     our location manager
 *  @param newLocation the new location from the gps
 *  @param oldLocation the previous location from the gps
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	BetterLog(@"");
	
    if (oldLocation == nil) return;
	
    BOOL isStaleLocation = [oldLocation.timestamp compare:self.startTimestamp] == NSOrderedAscending;
	
	// if within required accuracy
    if (!isStaleLocation && newLocation.horizontalAccuracy >= 0.0f && newLocation.horizontalAccuracy < kRequiredHorizontalAccuracy) {
		
		// persist this location
        [self.locationHistory addObject:newLocation];
        if ([self.locationHistory count] > kNumLocationHistoriesToKeep) {
            [self.locationHistory removeObjectAtIndex:0];
        }
		
		// if it's ben more than interval since we last calculated the distacne travelled
        if ([NSDate timeIntervalSinceReferenceDate] - self.lastDistanceCalculation > kDistanceCalculationInterval) {
            self.lastDistanceCalculation = [NSDate timeIntervalSinceReferenceDate];
			
            CLLocation *lastLocation = (self.currentRecordedLocation != nil) ? self.currentRecordedLocation : oldLocation;
			
            CLLocation *bestLocation = nil;
            CGFloat bestAccuracy = kRequiredHorizontalAccuracy;
            for (CLLocation *location in self.locationHistory) {
                if ([NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate] <= kValidLocationHistoryDeltaInterval) {
                    if (location.horizontalAccuracy < bestAccuracy && location != lastLocation) {
                        bestAccuracy = location.horizontalAccuracy;
                        bestLocation = location;
                    }
                }
            }
            if (bestLocation == nil)
				bestLocation = newLocation;
			
			self.lastRecordedLocation=_currentRecordedLocation;
            self.currentRecordedLocation = bestLocation;
			
			if(_delegate!=nil)
				[_delegate didReceiveUpdatedLocations:@[_currentRecordedLocation]];
			
			// if auto complete is on this will assess wether we should stop the current trip
			[self determineUserLocationStopped];
			
        }
    }
}





// Deferred location delegate

/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
	if(_delegate!=nil)
		[_delegate didReceiveUpdatedLocations:locations];
	
	// Defer updates until a certain amount of time has passed.
	if (!self.deferringUpdates) {
		[_locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:5.0];
		self.deferringUpdates = YES;
	}
}
*/




@end
