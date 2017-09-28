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

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "StartupManager.h"
#import "UserSettingsManager.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "UserAccount.h"
#import "UIDevice+Machine.h"
#import "ExpandedUILabel.h"
#import <Crashlytics/Crashlytics.h>
#import "RouteManager.h"
#import "UIView+Additions.h"
#import "StartupManager.h"
#import "NSString-Utilities.h"
#import "GenericConstants.h"
#import "NSString-URLEncoding.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "CycleStreets-Swift.h"

@interface AppDelegate()<StartupManagerDelegate,UITabBarControllerDelegate>


@property (nonatomic, strong)	UIImageView		*splashView;

@property (nonatomic, strong)	StartupManager		*startupmanager;
@property (nonatomic, strong)	ExpandedUILabel		*debugLabel;


@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
	
	[Fabric with:@[CrashlyticsKit]];
	
	[AppStyling initialiseUIAppearance];
	
	_tabBarController = (UITabBarController *)_window.rootViewController;
	_tabBarController.delegate = self;
	_tabBarController.customizableViewControllers = @[];

	[self appendStartUpView];
	
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	
	
	_startupmanager=[[StartupManager alloc]init];
	_startupmanager.delegate=self;
	[_startupmanager doStartupSequence];
	
	
	return YES;
}


//
/***********************************************
 * @description			Called if user selects this app as a routing app
 ***********************************************/
//
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	
	if ([MKDirectionsRequest isDirectionsRequestURL:url]) {
		MKDirectionsRequest* directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
		
		[[RouteManager sharedInstance] loadRouteForRouting:directionsInfo];
		
		return YES;
		
	}else {
		
		NSString *str=url.scheme;
		if([str containsString:CYCLESTREETSURLSCHEME]){
			
			NSArray *actionArray=[url.resourceSpecifier componentsSeparatedByString:@"/"];
			
			NSString *actionType=actionArray[2];
			
			if([actionType isEqualToString:@"route"]){
				
				NSString *routeid=[actionArray lastObject];
				
				[[RouteManager sharedInstance] loadRouteForRouteId:routeid];
				
				
			}else if ([actionType isEqualToString:@"directions"]){
				
				NSString *coords=[url query];
				NSDictionary *queryDictionary=coords.queryDictionary;
				
				if (queryDictionary!=nil) {
					[[RouteManager sharedInstance] loadRouteForRoutingDict:queryDictionary];
				}else{
					return NO;
				}
				
			}
			
			return YES;
		}else{
			return NO;
		}
	}
    return NO;
}



# pragma Model Delegate methods

//
/***********************************************
 * @description			Callbacks from StartupManager when all startup sequences have completed
 ***********************************************/
//
-(void)startupComplete{
	
	BetterLog(@"");
	
	_startupmanager.delegate=nil;
	_startupmanager=nil;
	
	_tabBarController.selectedIndex=[[UserSettingsManager sharedInstance] getSavedSection];
	
	[_window makeKeyAndVisible];	
	
	[self removeStartupView];
	
	
	UINavigationController *mController=_tabBarController.moreNavigationController;
	[mController.view setTintColor:[UIColor grayColor]];
	
	
}



- (void)applicationWillTerminate:(UIApplication *)application {
	[[UserSettingsManager sharedInstance] saveApplicationState];
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[UserSettingsManager sharedInstance] saveApplicationState];
	[[UserAccount sharedInstance] logoutUser];
}
-(void)applicationWillEnterForeground:(UIApplication *)application{
	[[UserAccount sharedInstance] loginExistingUserSilent];
}





#pragma mark UI Startup overlay

//
/***********************************************
 * @description			Add active startup view to takeover from Default image while App is completing Startup
 ***********************************************/
//
-(void)appendStartUpView{
	
	BetterLog(@"");
	
	// animate defaultPNG off screen to smooth out transition to ui state
	BOOL ip=IS_IPHONE_5;
	self.splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, SCREENWIDTH, FULLSCREENHEIGHT)];
	_splashView.image = [UIImage imageNamed: ip ? @"Default-568h@2x.png"  : @"Default.png" ];
	
#if defined (CONFIGURATION_Adhoc)
	[self writeDebugStartupLabel:NO];
#endif
	
#if defined (CONFIGURATION_Debug)
	[self writeDebugStartupLabel:YES];
#endif
	
	
	[_window addSubview:_splashView];
	[_window bringSubviewToFront:_splashView];
	
}


-(void)writeDebugStartupLabel:(BOOL)appendLocation{
	
	BetterLog(@"");
	
	if(_debugLabel!=nil)
		[_debugLabel removeFromSuperview];
	
	self.debugLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(10, 30, 280, 12)];
	_debugLabel.font=[UIFont systemFontOfSize:11];
	_debugLabel.textColor=[UIColor redColor];
	_debugLabel.backgroundColor=[UIColor whiteColor];
	NSDictionary *infoDict=[[NSBundle mainBundle] infoDictionary];
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	NSString *currSysMdl = [[UIDevice currentDevice] model];
	NSString *currSysNam = [[UIDevice currentDevice] systemName];
	NSString *currSysMac = [[UIDevice currentDevice] machine];
	
	NSString  *debuglabelString;
	
	debuglabelString=[NSString stringWithFormat:@"Build: %@ \rDevice: %@\rLocation: %@\rBuild variant: %@\rServices Id: %@",
						  [infoDict objectForKey:@"CFBundleVersion"],
						  [NSString stringWithFormat:@"%@, %@, %@, %@",currSysMdl,currSysMac,currSysNam,currSysVer],
						  @"No Location",[infoDict objectForKey:@"CFBundleIdentifier"],[infoDict objectForKey:@"SERVER_DOMAIN_ID"]];
	
	
	_debugLabel.text=debuglabelString;
	
	[_splashView addSubview:_debugLabel];
	
	
	
}

-(void)removeStartupView{
	
	BetterLog(@"");
	
	// reset to front because tab controller will be in front now
	[_window bringSubviewToFront:_splashView];
	
	int removeDelay=1;
	
#if defined (CONFIGURATION_Debug)
	removeDelay=0;
#endif
	
#if defined (CONFIGURATION_Adhoc)
	removeDelay=3;
#endif
	
	[UIView animateWithDuration:0.5 delay:removeDelay options:UIViewAnimationOptionTransitionNone animations:^{
		_splashView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_splashView removeFromSuperview];
	}];
	
}



- (void)tabBarController:(UITabBarController *)tbc didSelectViewController:(UIViewController *)viewController {
	
	[[UserSettingsManager sharedInstance] setSavedSection:tbc.selectedViewController.title];
	
}



-(void)showTabBarViewControllerByName:(NSString*)viewname{
	
	NSInteger count=[_tabBarController.viewControllers count];
	int index=-1;
	for (int i=0;i<count;i++) {
		UIViewController *navcontroller=[_tabBarController.viewControllers objectAtIndex:i];
		if([navcontroller.tabBarItem.title isEqualToString:viewname]){
			index=i;
			break;
		}
	}
	
	if(index!=-1){
		[_tabBarController setSelectedIndex:index];
	}else {
		BetterLog(@"[ERROR] unable to find tabbarItem with name %@",viewname);
	}

	
}



@end
