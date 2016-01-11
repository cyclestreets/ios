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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define ROUTEARCHIVEPATH @"userroutes"
#define OLDROUTEARCHIVEPATH @"routes"

@class WayPointVO,LeisureRouteVO;

@interface RouteManager : FrameworkObject 	{
	

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RouteManager);
@property (nonatomic, strong) NSMutableDictionary		* routes;
@property (nonatomic, strong) NSMutableArray			* legacyRoutes;
@property (nonatomic, strong) RouteVO					* selectedRoute;
@property (nonatomic, strong) NSString					* activeRouteDir;
@property (nonatomic, strong) MKDirectionsRequest		*mapRoutingRequest;// temp storage for MapKit bug where Routing currentLocation is 0,0


- (void) selectRoute:(RouteVO *)route;

//new
-(void)loadRouteForRouteId:(NSString*)routeid; // route id remote loading
-(void)loadRouteForEndPoints:(CLLocation*)fromlocation to:(CLLocation*)tolocation;
-(void)loadRouteForCoordinates:(CLLocationCoordinate2D)fromcoordinate to:(CLLocationCoordinate2D)tocoordinate;
-(void)loadRouteForRouteId:(NSString*)routeid withPlan:(NSString*)plan;
-(void)loadRouteForWaypoints:(NSMutableArray*)waypoints;

-(void)loadRouteForRouting:(MKDirectionsRequest*)routingrequest;

-(void)loadRouteForRoutingDict:(NSDictionary*)routingDict;

-(void)loadRouteForLeisure:(LeisureRouteVO*)leisureroute;

-(BOOL)loadSavedSelectedRoute;
-(BOOL)hasSavedSelectedRoute;

-(RouteVO*)loadRouteForFileID:(NSString*)fileid;
- (void)saveRoute:(RouteVO *)route;
-(void)saveRoutesInBackground:(NSMutableArray*)arr;

-(void)removeRoute:(RouteVO*)route;
- (void)removeRouteFile:(RouteVO*)route;

- (void) clearSelectedRoute;
-(BOOL)hasSelectedRoute;
-(BOOL)routeIsSelectedRoute:(RouteVO*)route;

-(void)updateRoute:(RouteVO*)route;

-(void)loadMetaDataForWaypoint:(WayPointVO*)waypoint;


// legacy
-(void)legacyRouteCleanup;
- (void)legacyRemoveRouteFile:(NSString*)routeid;
-(RouteVO*)legacyLoadRoute:(NSString*)routeid;

@end
