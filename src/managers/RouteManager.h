//
//  RouteModel.h
//  CycleStreets
//
//  Created by neil on 22/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkObject.h"
#import "SynthesizeSingleton.h"
#import "RouteVO.h"
#import "Query.h"
#import <CoreLocation/CoreLocation.h>

@interface RouteManager : FrameworkObject 	{
	
	NSMutableDictionary					*routes;
	
	RouteVO								*selectedRoute;

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RouteManager);
@property (nonatomic, retain)	NSMutableDictionary	*routes;
@property (nonatomic, retain)	RouteVO	*selectedRoute;

- (void) runQuery:(Query *)query;
- (void) runRouteIdQuery:(Query *)query;
- (void) selectRoute:(RouteVO *)route;

//new
-(void)loadRouteForEndPoints:(CLLocation*)fromlocation to:(CLLocation*)tolocation;
-(void)loadRouteForRouteId:(NSString*)routeid;

-(void)loadRouteWithIdentifier:(NSString*)routeid;
-(void)loadSavedSelectedRoute;

@end
