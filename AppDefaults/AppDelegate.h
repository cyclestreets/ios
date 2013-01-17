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
#import "StartupManager.h"
#import "ExpandedUILabel.h"

#define ISDEVELOPMENT 1

@interface AppDelegate : NSObject <UIApplicationDelegate,StartupManagerDelegate,UITabBarControllerDelegate> {
	
    UIWindow										*window;
	
	UIImageView										*splashView;
	
	UITabBarController								*tabBarController;
	
	StartupManager									*startupmanager;
	ExpandedUILabel									*debugLabel;
	
	
	
}

@property (nonatomic, strong)	IBOutlet UIWindow		*window;
@property (nonatomic, strong)	UIImageView		*splashView;
@property (nonatomic, strong)	UITabBarController		*tabBarController;
@property (nonatomic, strong)	StartupManager		*startupmanager;
@property (nonatomic, strong)	ExpandedUILabel		*debugLabel;


- (UINavigationController *)setupNavigationTab:(UIViewController *)controller withTitle:(NSString *)title imageNamed:(NSString *)imageName tag:(int)tag;
-(void)showTabBarViewControllerByName:(NSString*)viewname;

@end

