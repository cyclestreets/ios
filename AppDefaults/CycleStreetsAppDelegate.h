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

//  CycleStreetsAppDelegate.h
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import <UIKit/UIKit.h>
@class SettingsViewController;
@class RouteTableViewController;
@class Route;
@class MapViewController;
@class PhotoMapViewController;
@class FavouritesViewController;
@class PhotosViewContoller;
@class Query;
@class BusyAlert;
@class Stage;
@class AccountViewController;
#import "StartupManager.h"

@interface CycleStreetsAppDelegate : NSObject <UIApplicationDelegate,StartupManagerDelegate,UITabBarControllerDelegate> {
    UIWindow *window;
	
	//Tab bar, and the members of it.
	UITabBarController *tabBarController;
	UIAlertView *firstAlert;
	UIAlertView *secondAlert;
	UIAlertView *optionsAlert;
	UIAlertView *networkAlert;
	
	//Pop over
	Stage *stage;
	
	//Utilities
	BusyAlert *busyAlert;
	UIAlertView *errorAlert;
	
	StartupManager				*startupmanager;
	
	
	//TO BE DEPRECATED, these shouldnt be hard wired via the delegate, use notifications or kvo
	FavouritesViewController		*favourites;
	RouteTableViewController		*routeTable;
	MapViewController				*map;
	
}

@property (nonatomic, retain)		IBOutlet UIWindow		* window;
@property (nonatomic, retain)		IBOutlet UITabBarController		* tabBarController;
@property (nonatomic, retain)		IBOutlet UIAlertView		* firstAlert;
@property (nonatomic, retain)		IBOutlet UIAlertView		* secondAlert;
@property (nonatomic, retain)		IBOutlet UIAlertView		* optionsAlert;
@property (nonatomic, retain)		IBOutlet UIAlertView		* networkAlert;
@property (nonatomic, retain)		Stage		* stage;
@property (nonatomic, retain)		BusyAlert		* busyAlert;
@property (nonatomic, retain)		IBOutlet UIAlertView		* errorAlert;
@property (nonatomic, retain)		StartupManager		* startupmanager;
@property (nonatomic, retain)		FavouritesViewController		* favourites;
@property (nonatomic, retain)		RouteTableViewController		* routeTable;
@property (nonatomic, retain)		MapViewController		* map;



- (void)buildTabbarController:(NSArray*)viewcontrollers;
- (void)setBarStyle:(UIBarStyle)style andTintColor:(UIColor *)color forNavigationBar:(UINavigationBar *)bar;
-(void)showTabBarViewControllerByName:(NSString*)viewname;

@end

