//
//  LeisureRouteVO.h
//  CycleStreets
//
//  Created by Neil Edwards on 26/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, LeisureRouteType) {
    LeisureRouteTypeDistance,
    LeisureRouteTypeDuration
};


@interface LeisureRouteVO : NSObject

@property (nonatomic,assign) LeisureRouteType          routeType;
@property (nonatomic,assign) NSInteger                 routeValue;
@property (nonatomic,assign) CLLocationCoordinate2D    routeCoordinate;


@property(nonatomic,readonly)  NSString					*coordinateString;

// update
-(LeisureRouteType)changeRouteType:(NSInteger)index;


// validate
-(BOOL)isValid;

-(BOOL)validateValues;


// getters

-(NSString*)readoutString;


// class
+(NSArray*)routeTypesStrings;

+(NSArray*)typeRangeArrayForRouteType:(LeisureRouteType)type;

+(NSDictionary*)endPointsForRouteType:(LeisureRouteType)type;

@end
