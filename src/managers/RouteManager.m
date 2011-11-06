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
#import "ValidationVO.h"
#import "NetResponse.h"
#import "NetRequest.h"
#import "SettingsManager.h"
#import "SavedRoutesManager.h"
#import "Model.h"

@interface RouteManager(Private) 

- (void)warnOnFirstRoute;

- (void) querySuccess:(XMLRequest *)request results:(NSDictionary *)elements;
- (void) queryRouteSuccess:(XMLRequest *)request results:(NSDictionary *)elements;

- (void) queryFailure:(XMLRequest *)request message:(NSString *)message;

-(void)loadRouteForEndPointsResponse:(ValidationVO*)validation;
-(void)loadRouteForRouteIdResponse:(ValidationVO*)validation;

- (NSString *) routesDirectory;
- (NSString *) oldroutesDirectory;


-(void)evalRouteArchiveState;

@end

static NSString *layer = @"6";
static NSString *useDom = @"1";


@implementation RouteManager
SYNTHESIZE_SINGLETON_FOR_CLASS(RouteManager);
@synthesize routes;
@synthesize selectedRoute;
@synthesize activeRouteDir;


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [routes release], routes = nil;
    [selectedRoute release], selectedRoute = nil;
    [activeRouteDir release], activeRouteDir = nil;
	
    [super dealloc];
}



//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        self.routes = [[NSMutableDictionary alloc]init];
		self.activeRouteDir=OLDROUTEARCHIVEPATH;
		[self evalRouteArchiveState];
    }
    return self;
}




//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	BetterLog(@"");
	
	[notifications addObject:REQUESTDIDCOMPLETEFROMSERVER];
	[notifications addObject:DATAREQUESTFAILED];
	[notifications addObject:REMOTEFILEFAILED];
	
	[self addRequestID:CALCULATEROUTE];
	[self addRequestID:RETRIEVEROUTEBYID];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	NSDictionary	*dict=[notification userInfo];
	NetResponse		*response=[dict objectForKey:RESPONSE];
	
	NSString	*dataid=response.dataid;
	BetterLog(@"response.dataid=%@",response.dataid);
	
	if([self isRegisteredForRequest:dataid]){
		
		if([notification.name isEqualToString:REQUESTDIDCOMPLETEFROMSERVER]){
			
			if ([response.dataid isEqualToString:CALCULATEROUTE]) {
				
				[self loadRouteForEndPointsResponse:response.dataProvider];
				
			}else if ([response.dataid isEqualToString:RETRIEVEROUTEBYID]) {
				
				[self loadRouteForRouteIdResponse:response.dataProvider];
				
			}
			
		}
		
	}
	
	if([notification.name isEqualToString:REMOTEFILEFAILED] || [notification.name isEqualToString:DATAREQUESTFAILED]){
		[[HudManager sharedInstance] removeHUD];
	}
	
	
}




//
/***********************************************
 * @description			NEW NETWORK METHODS
 ***********************************************/
//

-(void)loadRouteForEndPoints:(CLLocation*)fromlocation to:(CLLocation*)tolocation{
    
    
    CycleStreets *cycleStreets = [CycleStreets sharedInstance];
    SettingsVO *settingsdp = [SettingsManager sharedInstance].dataProvider;
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey,@"key",
                                     [NSNumber numberWithFloat:fromlocation.coordinate.longitude],@"start_longitude",
                                     [NSNumber numberWithFloat:fromlocation.coordinate.latitude],@"start_latitude",
                                     [NSNumber numberWithFloat:tolocation.coordinate.longitude],@"finish_longitude",
                                     [NSNumber numberWithFloat:tolocation.coordinate.latitude],@"finish_latitude",
                                     layer,@"layer",
                                     useDom,@"useDom",
                                     settingsdp.plan,@"plan",
                                     [settingsdp returnKilometerSpeedValue],@"speed",
                                     cycleStreets.files.clientid,@"clientid", 
                                     nil];
    
    NetRequest *request=[[NetRequest alloc]init];
    request.dataid=CALCULATEROUTE;
    request.requestid=ZERO;
    request.parameters=parameters;
    request.revisonId=0;
    request.source=USER;
    
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
    [dict release];
    [request release];
    
    [[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Obtaining route from CycleStreets.net" andMessage:nil];
    
}



-(void)loadRouteForEndPointsResponse:(ValidationVO*)validation{
    
    
    switch(validation.validationStatus){
        
        case ValidationCalculateRouteSuccess:
            
            self.selectedRoute = [validation.responseDict objectForKey:CALCULATEROUTE];
            
            [[SavedRoutesManager sharedInstance] addRouteToDataProvider:selectedRoute dp:SAVEDROUTE_RECENTS];
			
			// legacy support only
			CycleStreets *cycleStreets = [CycleStreets sharedInstance];
			[cycleStreets.files setRoute:[[selectedRoute routeid] intValue] data:selectedRoute];
			
                
            [self warnOnFirstRoute];
            [self selectRoute:selectedRoute];	
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CALCULATEROUTERESPONSE object:nil];
            
            [[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Found Route, added path to map" andMessage:nil];
        
        break;
            
            
        case ValidationCalculateRouteFailed:
            
            [self queryFailure:nil message:@"Could not plan valid route for selected endpoints."];
            
        break;
        
        
    }
    

    
}


-(void)loadRouteForRouteId:(NSString*)routeid{
    
	
    SettingsVO *settingsdp = [SettingsManager sharedInstance].dataProvider;
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[CycleStreets sharedInstance].APIKey,@"key",
                                     useDom,@"useDom",
                                     settingsdp.plan,@"plan",
                                     routeid,@"itinerary",
                                     nil];
    
    NetRequest *request=[[NetRequest alloc]init];
    request.dataid=RETRIEVEROUTEBYID;
    request.requestid=ZERO;
    request.parameters=parameters;
    request.revisonId=0;
    request.source=USER;
    
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:request,REQUEST,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTDATAREFRESH object:nil userInfo:dict];
    [dict release];
    [request release];

    [[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:[NSString stringWithFormat:@"Searching for route %@ on CycleStreets",routeid] andMessage:nil];
}


-(void)loadRouteForRouteIdResponse:(ValidationVO*)validation{
    
	BetterLog(@"");
    
    switch(validation.validationStatus){
            
        case ValidationCalculateRouteSuccess:
            
            self.selectedRoute=[validation.responseDict objectForKey:RETRIEVEROUTEBYID];
            
            [[SavedRoutesManager sharedInstance] addRouteToDataProvider:selectedRoute dp:SAVEDROUTE_RECENTS];
            
            [self selectRoute:selectedRoute];	
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NEWROUTEBYIDRESPONSE object:nil];
            
            [[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Found Route, this route is now selected." andMessage:nil];
            
            break;
            
            
        case ValidationCalculateRouteFailed:
            
            [self queryFailure:nil message:@"Unable to find a route with this number."];
            
        break;
            
            
    }
    
    
}


//
/***********************************************
 * @description			Old Route>New Route conversion evaluation
 ***********************************************/
//

-(void)evalRouteArchiveState{
	
	// this should get the saved routes array
	// and use this
	
	
	// do we have a old route folder
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	BOOL doesDirExist=[fileManager fileExistsAtPath:[self routesDirectory] isDirectory:&isDirectory];
					   
	if(doesDirExist==YES && isDirectory==YES){
		
		NSError *error=nil;
		
		NSArray *oldroutes=[fileManager contentsOfDirectoryAtPath:[self routesDirectory] error:&error];
		
		if(error==nil && [oldroutes count]>0){
			
			for(NSString *filename in oldroutes){
				
				NSString *filepath = [[self routesDirectory] stringByAppendingPathComponent:filename];
				NSData *routedata=[[NSData alloc ] initWithContentsOfFile:filepath];
				
				RouteVO *newroute=(RouteVO*)[[Model sharedInstance].xmlparser parseXML:routedata forType:CALCULATEROUTE];
				
				[self saveRoute:newroute forID:[newroute.routeid intValue]];
				
				[newroute release];
				
			}
			
		}
		
	}
	
	self.activeRouteDir=ROUTEARCHIVEPATH;
	
	
}


//
/***********************************************
 * @description			OLD NETWORK EVENTS
 ***********************************************/
//
// this functionality can be entirely repalced by standard request/response logic as it is aonly called from
// one place
- (void) runQuery:(Query *)query {
	[query runWithTarget:self onSuccess:@selector(querySuccess:results:) onFailure:@selector(queryFailure:message:)];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Obtaining route from CycleStreets.net" andMessage:nil];

}

- (void) runRouteIdQuery:(Query *)query {
	
	[query runWithTarget:self onSuccess:@selector(queryRouteSuccess:results:) onFailure:@selector(queryRouteFailure:message:)];
	
	
	
	
}


- (void) querySuccess:(XMLRequest *)request results:(NSDictionary *)elements {
	
	//update the table.
	self.selectedRoute = [[Route alloc] initWithElements:elements];
	
	if ([selectedRoute routeid] == nil) {
		[self queryFailure:nil message:@"Could not plan valid route for selected endpoints."];
	} else {
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Found Route, added path to map" andMessage:nil];
		
		BetterLog(@"");
		//save the route data to file.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		[cycleStreets.files setRoute:[[selectedRoute routeid] intValue] data:selectedRoute];
		
		[self warnOnFirstRoute];
		[self selectRoute:selectedRoute];		
	}
}


- (void) queryRouteSuccess:(XMLRequest *)request results:(NSDictionary *)elements {
	
	BetterLog(@"");
	
	//update the table.
	self.selectedRoute = [[Route alloc] initWithElements:elements];
	
	if ([selectedRoute routeid] == nil) {
		[self queryFailure:nil message:@"Unable to find a route with this number."];
	} else {
		
		//save the route data to file.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
		[cycleStreets.files setRoute:[[selectedRoute routeid] intValue] data:selectedRoute];
		
		[self warnOnFirstRoute];
		[self selectRoute:selectedRoute];	
		
		[[NSNotificationCenter defaultCenter] postNotificationName:NEWROUTEBYIDRESPONSE object:nil];
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Found Route, this route is now selected." andMessage:nil];
	}
}

- (void) queryFailure:(XMLRequest *)request message:(NSString *)message {
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:message andMessage:nil];
}


//
/***********************************************
 * @description			RESEPONSE EVENTS
 ***********************************************/
//

- (void) selectRoute:(RouteVO *)route {
	
	BetterLog(@"");
	
	self.selectedRoute=route;
	
	// NEW
	// set SR in favs, will promote to top its dp
	//[[SavedRoutesManager sharedInstance] selectRoute:route];
	//Files *files=[CycleStreets sharedInstance].files;
	//[files setMiscValue:[route routeid] forKey:@"selectedroute"];
	//
	
	
	//OLD
	Files *files=[CycleStreets sharedInstance].files;
	NSArray *oldFavourites = [files favourites];
	NSMutableArray *newFavourites = [[[NSMutableArray alloc] initWithCapacity:[oldFavourites count]+1] autorelease];
	[newFavourites addObjectsFromArray:oldFavourites];
	if ([route routeid] != nil) {
		[newFavourites removeObject:[route routeid]];
		[newFavourites insertObject:[route routeid] atIndex:0];
		[files setMiscValue:[route routeid] forKey:@"selectedroute"];
	}
	[files setFavourites:newFavourites];
	[[FavouritesManager sharedInstance] update];	
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CSROUTESELECTED object:[route routeid]];
	
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





//
/***********************************************
 * @description			Pre Selects route as SR
 ***********************************************/
//
-(void)selectRouteWithIdentifier:(NSString*)identifier{
	
	if (identifier!=nil) {
		RouteVO *route = [routes objectForKey:identifier];
		if(route!=nil){
			[self selectRoute:route];
		}
	}
	
}

//
/***********************************************
 * @description			loads route from disk and stores
 ***********************************************/
//
-(void)loadRouteWithIdentifier:(NSString*)identifier{
	
	RouteVO *route=nil;
	
	if (identifier!=nil) {
		route = [self loadRouteForID:[identifier intValue]];
	}
	if(route!=nil){
		[routes setObject:route forKey:identifier];
	}
	
}

//


// loads the currently saved selectedRoute by identifier
-(void)loadSavedSelectedRoute{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSString *selectedRouteID = [cycleStreets.files miscValueForKey:@"selectedroute"];
	if(selectedRouteID!=nil)
		[self loadRouteForID:[selectedRouteID intValue]];
	
	
}



-(void)removeRoute:(NSString*)routeid{
	
	[routes removeObjectForKey:routeid];
	[self removeRouteForID:[routeid intValue]];
	
}


//
/***********************************************
 * @description			File I/O
 ***********************************************/
//


- (RouteVO *)loadRouteForID:(NSInteger) routeIdentifier {
	
	NSString *routeFile = [[self routesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"route_%d", routeIdentifier]];
	
	NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:routeFile];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	RouteVO *route = [unarchiver decodeObjectForKey:kROUTEARCHIVEKEY];
	[unarchiver finishDecoding];
	[unarchiver release];
	[data release];
	
	return route;
}


- (void)saveRoute:(RouteVO *)route forID:(NSInteger) routeIdentifier  {
	
	NSString *routeFile = [[self routesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"route_%d", routeIdentifier]];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:route forKey:kROUTEARCHIVEKEY];
	[archiver finishEncoding];
	[data writeToFile:routeFile atomically:YES];
	
	[data release];
	[archiver release];
	
}


- (void)removeRouteForID:(NSInteger) routeIdentifier{
	
	
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString *routeFile = [[self routesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"route_%d", routeIdentifier]];
	
	BOOL fileexists = [fileManager fileExistsAtPath:routeFile];
	
	if(fileexists==YES){
		
		NSError *error=nil;
		[fileManager removeItemAtPath:routeFile error:&error];
	}
	
}

- (NSString *) routesDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [[paths objectAtIndex:0] copy];
	return [documentsDirectory stringByAppendingPathComponent:ROUTEARCHIVEPATH];
}



@end
