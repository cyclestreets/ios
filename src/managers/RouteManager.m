//
//  RouteModel.m
//  CycleStreets
//
//  Created by neil on 22/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteManager.h"
#import "Query.h"
#import "XMLRequest.h"
#import "Route.h"
#import "GlobalUtilities.h"
#import "CycleStreets.h"
#import "AppConstants.h"
#import "Files.h"
#import "RouteParser.h"
#import "HudManager.h"
#import "FavouritesManager.h"

@interface RouteManager(Private) 

- (void)warnOnFirstRoute;
- (void) querySuccess:(XMLRequest *)request results:(NSDictionary *)elements;
- (void) queryFailure:(XMLRequest *)request message:(NSString *)message;
- (void) queryRouteSuccess:(XMLRequest *)request results:(NSDictionary *)elements;

@end


@implementation RouteManager
SYNTHESIZE_SINGLETON_FOR_CLASS(RouteManager);
@synthesize routes;
@synthesize selectedRoute;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [routes release], routes = nil;
    [selectedRoute release], selectedRoute = nil;
	
    [super dealloc];
}




//
/***********************************************
 * @description			NETWORK EVENTS
 ***********************************************/
//
- (void) runQuery:(Query *)query {
	[query runWithTarget:self onSuccess:@selector(querySuccess:results:) onFailure:@selector(queryFailure:message:)];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Obtaining route from CycleStreets.net" andMessage:nil];

}

- (void) runRouteIdQuery:(Query *)query {
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Obtaining route by id from CycleStreets.net" andMessage:nil];
	
	[query runWithTarget:self onSuccess:@selector(queryRouteSuccess:results:) onFailure:@selector(queryFailure:message:)];
	
}


- (void) querySuccess:(XMLRequest *)request results:(NSDictionary *)elements {
	
	
	
	//update the table.
	self.selectedRoute = [[Route alloc] initWithElements:elements];
	
	if ([selectedRoute itinerary] == nil) {
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Could not plan valid route for selected endpoints." andMessage:nil];
	} else {
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Found Route, added path to map" andMessage:nil];
		
		BetterLog(@"");
		//save the route data to file.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		[cycleStreets.files setRoute:[[selectedRoute itinerary] intValue] data:request.data];
		
		[self warnOnFirstRoute];
		[self selectRoute:selectedRoute];		
	}
}


- (void) queryRouteSuccess:(XMLRequest *)request results:(NSDictionary *)elements {
	
	BetterLog(@"");
	
	//update the table.
	self.selectedRoute = [[Route alloc] initWithElements:elements];
	
	if ([selectedRoute itinerary] == nil) {
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Could not plan valid route for selected endpoints." andMessage:nil];
	} else {
		
		//save the route data to file.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		[cycleStreets.files setRoute:[[selectedRoute itinerary] intValue] data:request.data];
		
		[self warnOnFirstRoute];
		[self selectRoute:selectedRoute];	
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ROUTEDATARESPONSE object:nil];
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Found Route, this route is now selected." andMessage:nil];
	}
}

- (void) queryFailure:(XMLRequest *)request message:(NSString *)message {
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Could not fetch route for selected endpoints." andMessage:nil];
}



//
/***********************************************
 * @description			RESEPONSE EVENTS
 ***********************************************/
//

- (void) selectRoute:(Route *)route {
	
	BetterLog(@"");
	
	self.selectedRoute=route;
	
	Files *files=[CycleStreets sharedInstance].files;
	NSArray *oldFavourites = [files favourites];
	NSMutableArray *newFavourites = [[[NSMutableArray alloc] initWithCapacity:[oldFavourites count]+1] autorelease];
	[newFavourites addObjectsFromArray:oldFavourites];
	if ([route itinerary] != nil) {
		[newFavourites removeObject:[route itinerary]];
		[newFavourites insertObject:[route itinerary] atIndex:0];
		[files setMiscValue:[route itinerary] forKey:@"selectedroute"];
	}
	[files setFavourites:newFavourites];
	[[FavouritesManager sharedInstance] update];	
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CSROUTESELECTED object:[route itinerary]];
	
}

- (void)warnOnFirstRoute {
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	NSString *experienceLevel = [misc objectForKey:@"experienced"];
	
	if (experienceLevel == nil) {
		[misc setObject:@"1" forKey:@"experienced"];
		[cycleStreets.files setMisc:misc];
		
		UIAlertView *firstAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
													 message:@"Route quality cannot be guaranteed. Please proceed at your own risk. Do not use a mobile while cycling."
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
		[firstAlert show];		
		[firstAlert release];
	} else if ([experienceLevel isEqualToString:@"1"]) {
		[misc setObject:@"2" forKey:@"experienced"];
		[cycleStreets.files setMisc:misc];
		
		UIAlertView *optionsAlert = [[UIAlertView alloc] initWithTitle:@"Routing modes"
													   message:@"You can change between fastest / quietest / balanced routing type on the Settings page under 'More', before you plan a route."
													  delegate:self
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[optionsAlert show];
		[optionsAlert release];
	}	
	 
}


// loads and selects a route from disk by it's identifier
-(void)loadRouteWithIdentifier:(NSString*)identifier{
	
	Route *route=nil;
	
	if (identifier!=nil) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];	
		NSData *data = [cycleStreets.files route:[identifier intValue]];
		if(data!=nil){
			RouteParser *parsed = [RouteParser parse:data forElements:[Route routeXMLElementNames]];
			route = [[[Route alloc] initWithElements:parsed.elementLists] autorelease];
		}
	}
	
	if(route!=nil){
		[self selectRoute:route];
	}
}


// loads the currently saved selectedRoute by identifier
-(void)loadSavedSelectedRoute{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSString *selectedRouteID = [cycleStreets.files miscValueForKey:@"selectedroute"];
	if(selectedRouteID!=nil)
		[self loadRouteWithIdentifier:selectedRouteID];
	
	
}



@end
