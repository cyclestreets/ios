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
@class LoginView;
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
}

@property (nonatomic, retain)	IBOutlet UIWindow	*window;
@property (nonatomic, retain)	IBOutlet UITabBarController	*tabBarController;
@property (nonatomic, retain)	IBOutlet UIAlertView	*firstAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*secondAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*optionsAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*networkAlert;
@property (nonatomic, retain)	Stage	*stage;
@property (nonatomic, retain)	BusyAlert	*busyAlert;
@property (nonatomic, retain)	IBOutlet UIAlertView	*errorAlert;
@property (nonatomic, retain)	StartupManager	*startupmanager;



- (void) runQuery:(Query *)query;

- (void) selectRoute:(Route *)route;
- (void)buildTabbarController:(NSArray*)viewcontrollers;

@end

