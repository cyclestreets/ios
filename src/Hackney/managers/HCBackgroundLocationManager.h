//
//  HCBackgroundLocationManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 31/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"

#import <CoreLocation/CoreLocation.h>

@protocol HCBackgroundLocationManagerDelegate <NSObject>


-(void)didReceiveUpdatedLocations:(NSArray*)locations;

@end


@interface HCBackgroundLocationManager : FrameworkObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HCBackgroundLocationManager);


@property (nonatomic, assign) id <HCBackgroundLocationManagerDelegate> delegate;


-(void)startBackgroundLocating;

-(void)stopBackgroundLocating;

@end
