//
//  SavedLocationVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "BUCodableObject.h"

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, SavedLocationType) {
	SavedLocationTypeOther,
	SavedLocationTypeHome,
	SavedLocationTypeWork
};


@interface SavedLocationVO : BUCodableObject

@property(nonatomic,readonly)  NSString									*locationID;

@property (nonatomic,strong)  NSString									*title;

@property (nonatomic,strong)  NSNumber									*latitude;
@property (nonatomic,strong)  NSNumber									*longitude;

@property (nonatomic,assign)  SavedLocationType							locationType;



-(NSString*)locationIcon;

-(CLLocationCoordinate2D)coordinate;

@end
