//
//  LocationFeaturesManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 19/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "FrameworkObject.h"
#import <CoreLocation/CoreLocation.h>
#import "SynthesizeSingleton.h"

@interface LocationFeaturesManager : FrameworkObject{
	
	NSMutableArray					*locationDataProvider;
	
	CLLocation						*curentLocation;
	
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(LocationFeaturesManager)
@property (nonatomic, retain)	NSMutableArray		*locationDataProvider;
@property (nonatomic, retain)	CLLocation		*curentLocation;


-(void)retreiveFeaturesForLocation:(CLLocation*)location;

@end
