//
//  POIListviewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CSOverlayTransitionAnimator.h"

@interface POIListviewController : SuperViewController<UITableViewDelegate,UITableViewDataSource,CSOverlayTransitionProtocol>{
	
}


@property (nonatomic, assign)	CLLocationCoordinate2D						nwCoordinate;
@property (nonatomic, assign)	CLLocationCoordinate2D						seCoordinate;


@end
