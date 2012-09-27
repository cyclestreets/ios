//
//  NewMapViewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 26/09/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "RMMapViewDelegate.h"
#import "RouteVO.h"
#import "RouteLineView.h"
#import "BlueCircleView.h"
#import "WEPopoverController.h"
#import "MapLocationSearchViewController.h"
#import "UserLocationManager.h"

@class CycleStreets;
@class RouteVO;
@class Location;
@class InitialLocation;


enum  {
	MapPlanningStateNoRoute,
	MapPlanningStateLocating,
	MapPlanningStateWaypoint,
	MapPlanningStatePlanning,
	MapPlanningStateRoute,
};
typedef int MapPlanningState;



@interface NewMapViewController : SuperViewController
<RMMapViewDelegate, CLLocationManagerDelegate, LocationReceiver, PointListProvider, LocationProvider, WEPopoverControllerDelegate,UserLocationManagerDelegate>{
	
	
	
	
	
}

@end
