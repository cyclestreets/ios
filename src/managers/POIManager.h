//
//  POIManager.h
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import "POICategoryVO.h"
#import <CoreLocation/CoreLocation.h>

#define LOCATIONRADIUS 5
#define LOCATIONRESULTSLIMIT 20

@interface POIManager : FrameworkObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(POIManager)

@property (nonatomic, strong)	NSMutableArray					*dataProvider;// list of all categories
@property (nonatomic, strong)	NSMutableDictionary				*categoryDataProvider;// list of locations in category from current location

@property(nonatomic,strong)  POICategoryVO						*selectedCategory;


-(void)requestPOIListingData;

-(void)removePOICategoryMapPointsForCategory:(POICategoryVO*)category;
-(void)removeAllPOICategoryMapPoints;

-(void)requestPOICategoryMapPointsForCategory:(POICategoryVO*)category withNWBounds:(CLLocationCoordinate2D)nw andSEBounds:(CLLocationCoordinate2D)se;

-(void)requestPOICategoryDataForCategory:(POICategoryVO*)category atLocation:(CLLocationCoordinate2D)location;


-(NSMutableArray*)newLeisurePOIArray;


+(POICategoryVO*)createNoneCategory;

@end
