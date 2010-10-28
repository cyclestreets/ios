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
@class Settings;
@class RouteTable;
@class Route;
@class Map;
@class PhotoMap;
@class Favourites;
@class Photos;
@class Query;
@class BusyAlert;
@class Stage;
@class Donate;

@interface CycleStreetsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	//Tab bar, and the members of it.
	UITabBarController *tabBarController;
	UITabBarItem *routeTabBarItem;
	Settings *settings;
	UINavigationController *settingsNavigation;
	RouteTable *routeTable;
	Map *map;
	PhotoMap *photoMap;
	Favourites *favourites;
	UINavigationController *favouritesNavigation;
	Photos *photos;
	UINavigationController *credits;
	Donate *donate;
	UIAlertView *firstAlert;
	UIAlertView *secondAlert;
	UIAlertView *optionsAlert;
	UIAlertView *networkAlert;
	
	//Pop over
	Stage *stage;
	
	//Utilities
	BusyAlert *busyAlert;
	UIAlertView *errorAlert;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) Settings *settings;
@property (nonatomic, readonly) UINavigationController *settingsNavigation;
@property (nonatomic, readonly) RouteTable *routeTable;
@property (nonatomic, readonly) UITabBarController *tabBarController;
@property (nonatomic, readonly) UITabBarItem *routeTabBarItem;
@property (nonatomic, readonly) Map *map;
@property (nonatomic, readonly) PhotoMap *photoMap;
@property (nonatomic, readonly) Favourites *favourites;
@property (nonatomic, readonly) UINavigationController *favouritesNavigation;
@property (nonatomic, readonly) Photos *photos;
@property (nonatomic, readonly) UINavigationController *credits;
@property (nonatomic, readonly) Donate *donate;
@property (nonatomic, readonly) BusyAlert *busyAlert;
@property (nonatomic, readonly) UIAlertView *errorAlert;
@property (nonatomic, retain) UIAlertView *firstAlert;
@property (nonatomic, retain) UIAlertView *secondAlert;
@property (nonatomic, retain) UIAlertView *optionsAlert;
@property (nonatomic, retain) UIAlertView *networkAlert;
@property (nonatomic, readonly) Stage *stage;

- (void) runQuery:(Query *)query;

- (void) selectRoute:(Route *)route;

@end

