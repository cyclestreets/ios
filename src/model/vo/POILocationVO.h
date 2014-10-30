//
//  POILocationVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BUCodableObject.h"

@interface POILocationVO : BUCodableObject

@property (nonatomic,strong)  NSString						*poiType;

@property (nonatomic, strong)	NSString					*locationid;

@property (nonatomic, assign)	CLLocationCoordinate2D		coordinate;
@property (nonatomic, strong)	NSString					*name;
@property (nonatomic, strong)	NSString					*notes;
@property (nonatomic, strong)	NSString					*website;

@end
