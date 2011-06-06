//
//  SettingsVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 31/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsVO : NSObject {
	
	NSString				*plan;
	NSString				*speed;
	NSString				*mapStyle;
	NSString				*imageSize;
	NSString				*routeUnit;
	BOOL					showRoutePoint;
	

}
@property (nonatomic, retain)		NSString				* plan;
@property (nonatomic, retain)		NSString				* speed;
@property (nonatomic, retain)		NSString				* mapStyle;
@property (nonatomic, retain)		NSString				* imageSize;
@property (nonatomic, retain)		NSString				* routeUnit;
@property (nonatomic)		BOOL				 showRoutePoint;

-(NSString*)returnKilometerSpeedValue;
@end
