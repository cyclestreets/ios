//
//  WayPointVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 05/11/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RMMarker.h"

enum  {
	
	WayPointTypeStart,
	WayPointTypeFinish,
	WayPointTypeIntermediate
	
};
typedef int WayPointType;

@interface WayPointVO : NSObject

@property(nonatomic,strong)  NSString						*name;
@property(nonatomic,strong)  NSString						*locationname;
@property(nonatomic,assign)  CLLocationCoordinate2D			coordinate;
@property(nonatomic,assign)  WayPointType					waypointType;
@property(nonatomic,strong)  RMMarker						*marker;


// getters
@property(nonatomic,readonly)  NSString						*coordinateString;

-(void)updateWaypointTypeForIndex:(int)index;

@end
