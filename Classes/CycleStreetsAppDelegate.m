/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  CycleStreetsAppDelegate.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "CycleStreetsAppDelegate.h"
#import "CycleStreets.h"
#import "Settings.h"
#import "RouteTable.h"
#import "Map.h"
#import "PhotoMap.h"
#import "Favourites.h"
#import "Photos.h"
#import "Credits.h"
#import "Singleton.h"
#import "Query.h"
#import "Route.h"
#import "Stage.h"
#import "BusyAlert.h"
#import <UIKit/UIKit.h>
#import "XMLRequest.h"
#import "Files.h"
#import "Reachability.h"
#import "Common.h"
#import "CategoryLoader.h"
#import "Donate.h"

@implementation CycleStreetsAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize routeTabBarItem;
@synthesize settings;
@synthesize settingsNavigation;
@synthesize routeTable;
@synthesize map;
@synthesize photoMap;
@synthesize favourites;
@synthesize favouritesNavigation;
@synthesize photos;
@synthesize credits;
@synthesize donate;
@synthesize busyAlert;
@synthesize errorAlert;
@synthesize firstAlert;
@synthesize secondAlert;
@synthesize optionsAlert;
@synthesize networkAlert;
@synthesize stage;

- (void)loadContext {
	DLog(@">>>");
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	Files *files = cycleStreets.files;
	NSString *saveIndex = [files miscValueForKey:@"selectedTabIndex"];
	if (saveIndex != nil && [saveIndex length] > 0) {
		self.tabBarController.selectedIndex = [saveIndex intValue];
	}
}

- (void)saveContext {
	DLog(@">>>");
	if (self.tabBarController != nil && self.tabBarController.selectedIndex != NSNotFound) {
		CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
		Files *files = cycleStreets.files;
		NSString *saveIndex = [[NSNumber numberWithInt:self.tabBarController.selectedIndex] stringValue];
		[files setMiscValue:saveIndex forKey:@"selectedTabIndex"];
	}
}

- (UINavigationController *)setupNavigationTab:(UIViewController *)controller withTitle:(NSString *)title imageNamed:(NSString *)imageName tag:(int)tag {

	UINavigationController *navigation = [[[UINavigationController alloc] init] autorelease];
	UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:tag];
	[navigation setTabBarItem:tabBarItem];
	[navigation pushViewController:controller animated:YES];
	controller.navigationItem.title = title;
	[tabBarItem release];
	
	return navigation;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
	
	DLog(@"application didFinishLaunchingWithOptions");

	// Override point for customization after application launch
	
	
	DLog(@"reachability checked.");
	
	// navigation controller
	tabBarController = [[UITabBarController alloc] init];
	
	// The map
	map = [[Map alloc] init];
	UITabBarItem *mapTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Plan route" image:[UIImage imageNamed:@"icon_window_globe.png"] tag:1];
	[map setTabBarItem:mapTabBarItem];
	[mapTabBarItem release];
	
	DLog(@"map view up.");
	
	// The photo map
	photoMap = [[PhotoMap alloc] init];
	// UINavigationController *photoMapNavigation = [self setupNavigationTab:photoMap withTitle:@"Photomap" imageNamed:@"icon_film.png" tag:8];
	UITabBarItem *photoMapTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Photomap" image:[UIImage imageNamed:@"icon_film.png"] tag:8];
	[photoMap setTabBarItem:photoMapTabBarItem];
	[photoMapTabBarItem release];
	
	DLog(@"photomap up.");
	
	// The route table
	routeTable = [[RouteTable alloc] init];
	UITabBarItem *resultsTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Itinerary" image:[UIImage imageNamed:@"icon_list_bullets.png"] tag:2];
	[routeTable setTabBarItem:resultsTabBarItem];
	routeTabBarItem = resultsTabBarItem;
	routeTabBarItem.enabled = NO;
	
	DLog(@"itinerary view up.");
	
	// The settings tab
	settings = [[Settings alloc] initWithNibName:@"Settings" bundle:nil];
	settingsNavigation = [self setupNavigationTab:settings withTitle:@"Settings" imageNamed:@"icon_magnify_glass.png" tag:3];
	
	DLog(@"settings tab up.");
	
	// Favourites
	favourites = [[Favourites alloc] init];
	favouritesNavigation = [self setupNavigationTab:favourites withTitle:@"My saved routes" imageNamed:@"icon_favorities.png" tag:4];
	
	DLog(@"favourites up.");
	
	// Photos
	photos = [[Photos alloc] init];
	UITabBarItem *photosTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Add photo" image:[UIImage imageNamed:@"icon_photo.png"] tag:5];
	[photos setTabBarItem:photosTabBarItem];
	[photosTabBarItem release];
	
	DLog(@"photos up.");
	
	// Credits
	credits = [self setupNavigationTab:[[Credits alloc] init] withTitle:@"Credits" imageNamed:@"icon_information.png" tag:6];
	
	DLog(@"credits up.");
	
	// Donate
	//commented out because Apple doesn't allow in-app donations.
	/*
	donate = [[Donate alloc] init];
	UITabBarItem *donateTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Donate" image:[UIImage imageNamed:@"icon_dollar.png"] tag:9];
	[donate setTabBarItem:donateTabBarItem];
	[donateTabBarItem release];
	
	DLog(@"donate up.");
	 */
	
	// put the tabbed views into the controller
	NSArray *tabbedViews = [NSArray arrayWithObjects: map, routeTable, photoMap, photos, favouritesNavigation, settingsNavigation, credits, donate, nil];
	[tabBarController setViewControllers: tabbedViews animated:YES];
	
	DLog(@"tabs added to controller.");
	
	// Stage popover
	stage = [[Stage alloc] initWithNibName:@"Stage" bundle:nil];
	
	//have a busy alert ready to use
	busyAlert = [[BusyAlert alloc] initWithTitle:@"Obtaining route" message:nil];
	
	// error alert too
	errorAlert = [[UIAlertView alloc]
				  initWithTitle:@"Error"
				  message:nil
				  delegate:self
				  cancelButtonTitle:@"OK"
				  otherButtonTitles:nil];
	
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	cycleStreets.appDelegate = self;
	
	DLog(@"app core loaded.");
	
	// view magic
	UIView *view = [self.tabBarController view];
	[window addSubview: view];	
	[window makeKeyAndVisible];	
	
	[self performSelector:@selector(backgroundSetup) withObject:nil afterDelay:0.0];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self saveContext];
}

- (void) backgroundSetup {
	
	//load the default categories
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	[cycleStreets.categoryLoader setupCategories];
	
	[self loadContext];
	
	// Check we have network
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [internetReach currentReachabilityStatus];	
	
	// Warn that we can't download new maps
	if (internetStatus == NotReachable) {
		self.networkAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
													   message:@"No network. You may be able to follow a previously planned route, if you have already viewed the maps."
													  delegate:self
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[networkAlert show];				
	}	
}

//It would make sense to turn this into an NSNotificationQueue based thing, so anything that wanted
//could listen for the route changing.
- (void) selectRoute:(Route *)route {
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];

	//load favourites, and add the new route to the favourites, as the first one.
	//do this even if we have it already, so last-selected favourite is "top"
	NSArray *oldFavourites = [cycleStreets.files favourites];
	NSMutableArray *newFavourites = [[[NSMutableArray alloc] initWithCapacity:[oldFavourites count]+1] autorelease];
	[newFavourites addObjectsFromArray:oldFavourites];
	if ([route itinerary] != nil) {
		[newFavourites removeObject:[route itinerary]];
		[newFavourites insertObject:[route itinerary] atIndex:0];
		[cycleStreets.files setMiscValue:[route itinerary] forKey:@"selectedroute"];
	}
	[cycleStreets.files setFavourites:newFavourites];
	
	//tell the favourites table it is reset.
	[cycleStreets.appDelegate.favourites clear];
	
	//and fill in the table data
	[routeTable setRoute:route];
	
	//make this the plotted route
	[map showRoute:route];
	
	//enable the route view.
	routeTabBarItem.enabled = YES;
}

- (void)warnOnFirstRoute {
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	NSMutableDictionary *misc = [NSMutableDictionary dictionaryWithDictionary:[cycleStreets.files misc]];
	NSString *experienceLevel = [misc objectForKey:@"experienced"];
	if (experienceLevel == nil) {
		[misc setObject:@"1" forKey:@"experienced"];
		[cycleStreets.files setMisc:misc];
		
		self.firstAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
													 message:@"Route quality cannot be guaranteed. Please proceed at your own risk. Do not use a mobile while cycling."
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
		[firstAlert show];				
	} else if ([experienceLevel isEqualToString:@"1"]) {
		[misc setObject:@"2" forKey:@"experienced"];
		[cycleStreets.files setMisc:misc];
		
		self.optionsAlert = [[UIAlertView alloc] initWithTitle:@"Routing modes"
													   message:@"You can change between fastest / quietest / balanced routing type on the Settings page under 'More', before you plan a route."
													  delegate:self
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[optionsAlert show];						
	}	
}

- (void) querySuccess:(XMLRequest *)request results:(NSDictionary *)elements {
	[busyAlert hide];
	
	//update the table.
	Route *route = [[Route alloc] initWithElements:elements];
	
	if ([route itinerary] == nil) {
		//alert no valid route.
		errorAlert.message = @"Could not plan valid route for selected endpoints.";
		[errorAlert show];
	} else {
		//save the route data to file.
		CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
		[cycleStreets.files setRoute:[[route itinerary] intValue] data:request.data];
		
		[self warnOnFirstRoute];
		[self selectRoute:route];		
	}
	[route release];
}

- (void) queryFailure:(XMLRequest *)request message:(NSString *)message {
	[busyAlert hide];
	
	errorAlert.message = @"Could not fetch route for selected endpoints.";
	[errorAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DLog(@">>>");
	if (alertView == firstAlert) {
		self.firstAlert = nil;
		self.secondAlert = [[[UIAlertView alloc] initWithTitle:@"CycleStreets"
													   message:@"Click on 'Itinerary' to view full details. The route has also been saved to the 'More' section."
													  delegate:self
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil]
							autorelease];
		//[self.secondAlert show];
		[self.secondAlert performSelector:@selector(show) withObject:nil afterDelay:0.1];
	}
	if (alertView == secondAlert) {
		self.secondAlert = nil;
	}
	if (alertView == optionsAlert) {
		self.optionsAlert = nil;
	}
	if (alertView == networkAlert) {
		self.networkAlert = nil;
	}
}

- (void) runQuery:(Query *)query {
	[busyAlert show:@"Obtaining route from CycleStreets.net"];
	[query runWithTarget:self onSuccess:@selector(querySuccess:results:) onFailure:@selector(queryFailure:message:)];
	
}

- (void)dealloc {
    [window release];
	[tabBarController release];
	[routeTabBarItem release];
	[settings release];
	[routeTable release];
	[map release];
	[photoMap release];
	[favourites release];
	[favouritesNavigation release];
	[photos release];
	[credits release];
	[stage release];
	[busyAlert release];
	[errorAlert release];
	[firstAlert release];
	[secondAlert release];
	[optionsAlert release];
	[networkAlert release];
	
    [super dealloc];
}


@end
