//
//  LocationSearchManager.h
//  CycleStreets
//
//  Created by neil on 06/04/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, LocationSearchFilterType) {
	LocationSearchFilterLocal,
	LocationSearchFilterNational,
	LocationSearchFilterRecent,
	LocationSearchFilterContacts
};

typedef NS_ENUM(NSUInteger, LocationSearchRequestType) {
	LocationSearchRequestTypeMap,
	LocationSearchRequestTypePhoto,
	LocationSearchRequestTypeNone
};


@interface LocationSearchManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(LocationSearchManager);

@property (nonatomic, assign)	LocationSearchFilterType	activeFilterType;
@property (nonatomic, assign)	LocationSearchRequestType	activeRequestType;

	

-(void)searchForLocation:(NSString*)searchString withFilter:(LocationSearchFilterType)filterType forRequestType:(LocationSearchRequestType)requestType atLocation:(CLLocationCoordinate2D)centerLocation;

-(void)searchForLocation:(NSString*)searchString withFilter:(LocationSearchFilterType)filterType forRequestType:(LocationSearchRequestType)requestType atLocation:(CLLocationCoordinate2D)centerLocation usingRegion:(MKCoordinateRegion)region;

+ (LocationSearchRequestType)locationrequestStringTypeToConstant:(NSString*)stringType;
+ (NSString*)locationrequestConstantToString:(LocationSearchRequestType)requestType;

@end
