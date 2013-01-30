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
//#import "Query.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define ROUTEARCHIVEPATH @"userroutes"
#define OLDROUTEARCHIVEPATH @"routes"

@interface RouteManager : FrameworkObject 	{
	
	NSMutableDictionary					*routes;
	NSMutableArray						*legacyRoutes;
	
	RouteVO								*selectedRoute;
	
	NSString							*activeRouteDir;
	
	MKDirectionsRequest					*mapRoutingRequest; // temp storage for MapKit bug where Routing currentLocation is 0,0

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RouteManager);
@property (nonatomic, strong) NSMutableDictionary		* routes;
@property (nonatomic, strong) NSMutableArray		* legacyRoutes;
@property (nonatomic, strong) RouteVO		* selectedRoute;
@property (nonatomic, strong) NSString		* activeRouteDir;
@property (nonatomic, strong) MKDirectionsRequest		*mapRoutingRequest;

//- (void) runQuery:(Query *)query;
//- (void) runRouteIdQuery:(Query *)query;
- (void) selectRoute:(RouteVO *)route;

//new
-(void)loadRouteForRouteId:(NSString*)routeid; // route id remote loading
-(void)loadRouteForEndPoints:(CLLocation*)fromlocation to:(CLLocation*)tolocation;
-(void)loadRouteForCoordinates:(CLLocationCoordinate2D)fromcoordinate to:(CLLocationCoordinate2D)tocoordinate;
-(void)loadRouteForRouteId:(NSString*)routeid withPlan:(NSString*)plan;
-(void)loadRouteForWaypoints:(NSMutableArray*)waypoints;

-(void)loadRouteForRouting:(MKDirectionsRequest*)routingrequest;

-(void)loadSavedSelectedRoute;

-(RouteVO*)loadRouteForFileID:(NSString*)fileid;
- (void)saveRoute:(RouteVO *)route;

-(void)removeRoute:(RouteVO*)route;
- (void)removeRouteFile:(RouteVO*)route;
- (void)removeRouteByFileID:(NSString*)fileid;
-(void)removeOrphanedRoutes:(NSMutableArray*)savedRoutes;

- (void) clearSelectedRoute;
-(BOOL)hasSelectedRoute;
-(BOOL)routeIsSelectedRoute:(RouteVO*)route;

-(void)updateRoute:(RouteVO*)route;


// legacy
-(void)legacyRouteCleanup;
- (void)legacyRemoveRouteFile:(NSString*)routeid;
-(RouteVO*)legacyLoadRoute:(NSString*)routeid;

@end
