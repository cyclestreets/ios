//
//  HCSMapViewController
//  CycleStreets
//
//  Created by Neil Edwards on 20/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TripManager.h"
#import "TripPurposeDelegate.h"
#import "RouteLineView.h"
#import "SuperViewController.h"
@class RMMapView,Trip;


enum  {
	HCSMapViewModeSave=0,
	HCSMapViewModeShow=1
};
typedef int HCSMapViewMode;


@interface HCSMapViewController : SuperViewController <PointListProvider>
{
}

@property (nonatomic, assign) id <TripPurposeDelegate>				tripDelegate;

@property (nonatomic,assign)  HCSMapViewMode						viewMode;

@property (nonatomic, strong) Trip									*trip;


@end
