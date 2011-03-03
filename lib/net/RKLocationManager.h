//
//  WMLocationManager.h
//  wikimeety
//
//  Created by steve on 12/7/09.
//  Copyright 2009 Command Guru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RKLocationManager : NSObject<CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	NSTimer * timer;
	NSDate *detectionBeginTime;
	BOOL isLocating;
}
@property(nonatomic,retain) NSDate * detectionBeginTime;
@property(nonatomic,retain) CLLocation * currentLocation;
-(void)startDetectingCurrentLocation;
-(void)detectionTimeout:(NSTimer*)theTimer;
@end
