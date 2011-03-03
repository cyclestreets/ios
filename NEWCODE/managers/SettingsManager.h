//
//  SettingsManager.h
//  CycleStreets
//
//  Created by neil on 22/02/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface SettingsManager : NSObject {
	
	NSString				*plan;
	NSString				*speed;
	NSString				*mapStyle;
	NSString				*imageSize;
	NSString				*routeUnit;
	
	NSDictionary			*dataProvider;

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SettingsManager);
@property (nonatomic, retain)		NSString		* plan;
@property (nonatomic, retain)		NSString		* speed;
@property (nonatomic, retain)		NSString		* mapStyle;
@property (nonatomic, retain)		NSString		* imageSize;
@property (nonatomic, retain)		NSString		* routeUnit;
@property (nonatomic, retain)		NSDictionary		* dataProvider;

@end
