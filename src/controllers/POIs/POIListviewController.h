//
//  POIListviewController.h
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "SuperViewController.h"
#import "POICategoryViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface POIListviewController : SuperViewController<UITableViewDelegate,UITableViewDataSource>{
	
}


@property (nonatomic, assign)	CLLocationCoordinate2D						nwCoordinate;
@property (nonatomic, assign)	CLLocationCoordinate2D						seCoordinate;


@end
