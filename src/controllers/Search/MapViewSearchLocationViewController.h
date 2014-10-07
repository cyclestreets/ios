//
//  MapLocationSearchViewContoller.h
//  CycleStreets
//
//  Created by Neil Edwards on 25/09/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@protocol LocationReceiver
- (void) didMoveToLocation:(CLLocationCoordinate2D)location;
@end

@interface MapViewSearchLocationViewController : SuperViewController

@property (nonatomic, assign) CLLocationCoordinate2D  centreLocation;
@property (nonatomic, strong) id<LocationReceiver>    locationReceiver;

@end
