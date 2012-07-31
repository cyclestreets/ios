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

#define ROUTEARCHIVEPATH @"userroutes"
#define OLDROUTEARCHIVEPATH @"routes"

@interface RouteManager : FrameworkObject 	{
	
	NSMutableDictionary					*routes;
	
	RouteVO								*selectedRoute;
	
	NSString							*activeRouteDir;

}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RouteManager);
@property (nonatomic, strong)	NSMutableDictionary		*routes;
@property (nonatomic, strong)	RouteVO		*selectedRoute;
@property (nonatomic, strong)	NSString		*activeRouteDir;


- (void) runQuery:(Query *)query;
- (void) runRouteIdQuery:(Query *)query;
- (void) selectRoute:(RouteVO *)route;

//new
-(void)loadRouteForRouteId:(NSString*)routeid; // route id remote loading
-(void)loadRouteForEndPoints:(CLLocation*)fromlocation to:(CLLocation*)tolocation;

-(void)loadRouteForRouteId:(NSString*)routeid withPlan:(NSString*)plan;
-(void)loadSavedSelectedRoute;

-(RouteVO*)loadRouteForFileID:(NSString*)fileid;
- (void)saveRoute:(RouteVO *)route;

-(void)removeRoute:(RouteVO*)route;
- (void)removeRouteFile:(RouteVO*)route;

- (void) clearSelectedRoute;
-(BOOL)hasSelectedRoute;


// legacy

- (void)legacyRemoveRouteFile:(NSString*)routeid;
-(RouteVO*)legacyLoadRoute:(NSString*)routeid;

@end
