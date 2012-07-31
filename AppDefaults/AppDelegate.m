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
#import "CycleStreets.h"
#import "Files.h"
#import "Reachability.h"
#import "AppConfigManager.h"
#import "CategoryLoader.h"
#import "StartupManager.h"
#import "UserSettingsManager.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "UserAccount.h"
#import "TestFlight.h"
#import "GoogleAnalyticsManager.h"
#import "UIDevice+Machine.h"
#import "ExpandedUILabel.h"


@interface AppDelegate(Private)

- (void)buildTabbarController:(NSArray*)viewcontrollers;
-(void)appendStartUpView;
-(void)removeStartupView;
- (void)setBarStyle:(UIBarStyle)style andTintColor:(UIColor *)color forNavigationBar:(UINavigationBar *)bar;

-(void)writeDebugStartupLabel:(BOOL)appendLocation;

@end

@implementation AppDelegate
@synthesize window;
@synthesize splashView;
@synthesize tabBarController;
@synthesize startupmanager;
@synthesize debugLabel;




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
	
	
	[TestFlight takeOff:@"8abc4e71d1301ccd90b6465bb0af3716_NDQyMQ"];

	[self appendStartUpView];
	
	startupmanager=[[StartupManager alloc]init];
	startupmanager.delegate=self;
	[startupmanager doStartupSequence];
	
	
	return YES;
}



# pragma Model Delegate methods

//
/***********************************************
 * @description			Callbacks from StartupManager when all startup sequences have completed
 ***********************************************/
//
-(void)startupComplete{
	
	BetterLog(@"");
	
	startupmanager.delegate=nil;
	startupmanager=nil;
	
	tabBarController = [[UITabBarController alloc] init];
	[self buildTabbarController:[[AppConfigManager sharedInstance].configDict objectForKey:@"navigation"]];
	
	
	[window addSubview:tabBarController.view];
	tabBarController.selectedIndex=[[UserSettingsManager sharedInstance] getSavedSection];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	cycleStreets.appDelegate = self;
	
		
	[window makeKeyAndVisible];	
	
	[self performSelector:@selector(backgroundSetup) withObject:nil afterDelay:0.0];
	[self removeStartupView];
	
	
}



- (void)applicationWillTerminate:(UIApplication *)application {
	[[UserSettingsManager sharedInstance] saveApplicationState];
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[UserSettingsManager sharedInstance] saveApplicationState];
	[[UserAccount sharedInstance] logoutUser];
}
-(void)applicationWillEnterForeground:(UIApplication *)application{
	[[UserAccount sharedInstance] loginExistingUser];
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
	self.splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
	splashView.image = [UIImage imageNamed:@"Default.png"];
	
	#if ISDEVELOPMENT
	[self writeDebugStartupLabel:NO];
	#endif
	
	
	[window addSubview:splashView];
	[window bringSubviewToFront:splashView];
	
}


-(void)writeDebugStartupLabel:(BOOL)appendLocation{
	
	BetterLog(@"");
	
	if(debugLabel!=nil)
		[debugLabel removeFromSuperview];
	
	self.debugLabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(10, 30, 280, 12)];
	debugLabel.font=[UIFont systemFontOfSize:11];
	debugLabel.textColor=[UIColor redColor];
	debugLabel.backgroundColor=[UIColor whiteColor];
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
	
	
	debugLabel.text=debuglabelString;
	
	[splashView addSubview:debugLabel];
	
	
	
}

-(void)removeStartupView{
	
	BetterLog(@"");
	
	// reset to front because tab controller will be in front now
	[window bringSubviewToFront:splashView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView	setAnimationDelay:3];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
	[UIView setAnimationDelegate:self]; 
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[splashView removeFromSuperview];
}


//
/***********************************************
 * @description			create Tabbar order based on saved user context, handles More Tabbar reording
 ***********************************************/
//
- (void)buildTabbarController:(NSArray*)viewcontrollers {
	
	NSMutableArray	*navControllers=[[NSMutableArray alloc]init];
	
	
	if ([viewcontrollers count] > 0 ) {
		for (int i = 0; i < [viewcontrollers count]; i++){
			NSDictionary *navitem=[viewcontrollers objectAtIndex:i];
			NSString  *vcClass=[navitem objectForKey:@"class"];
			NSString  *nibName=[navitem objectForKey:@"nib"];
			NSString  *vcTitle=[navitem objectForKey:@"title"];
			
			//BetterLog(@"vcClass=%@  nibName=%@",vcClass,nibName);
			
			UIViewController *vccontroller= (UIViewController*)[[NSClassFromString(vcClass) alloc] initWithNibName:nibName bundle:nil];
			vccontroller.title=vcTitle;
			if(vccontroller!=nil){
				
				BOOL isVC=[[navitem objectForKey:@"isVC"] boolValue];
				if (isVC==YES) {
					UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:[navitem objectForKey:@"title"] image:[UIImage imageNamed:[navitem objectForKey:@"tabimage"]] tag:i];
					[vccontroller setTabBarItem:tabBarItem];
					[navControllers addObject:vccontroller];
				}else {
					UINavigationController *nav = [self setupNavigationTab:vccontroller withTitle:[navitem objectForKey:@"title"] imageNamed:[navitem objectForKey:@"tabimage"] tag:i];
					[navControllers addObject:nav];
				}

			}
			
		}
		tabBarController.viewControllers = navControllers;
	}
	
	
	// only add tabbar delegate if we can save the state
	if([[UserSettingsManager sharedInstance] userStateWritable]==YES){
		tabBarController.delegate = self;
	}
	
	[self setBarStyle:UIBarStyleDefault andTintColor:UIColorFromRGB(0x008000) forNavigationBar:tabBarController.moreNavigationController.navigationBar];
	
	// DEV: temp disable of edit 
	tabBarController.customizableViewControllers=nil;
}


- (UINavigationController *)setupNavigationTab:(UIViewController *)controller withTitle:(NSString *)title imageNamed:(NSString *)imageName tag:(int)tag {
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
	navigation.navigationBar.tintColor=UIColorFromRGB(0x008000);
	UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:tag];
	[navigation setTabBarItem:tabBarItem];
	controller.navigationItem.title = title;
	
	return navigation;
}

- (void)tabBarController:(UITabBarController *)tbc didSelectViewController:(UIViewController *)viewController {
	
	[[UserSettingsManager sharedInstance] setSavedSection:tbc.selectedViewController.title];
	
}



- (void) backgroundSetup {
	
	BetterLog(@"");
	
	// TODO: why is this loading stuff happenign here, it should be part of StartUpManger sequence
	
	
	// Check we have network
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [internetReach currentReachabilityStatus];	
	
	// Warn that we can't download new maps
	if (internetStatus == NotReachable) {
		UIAlertView *networkAlert = [[UIAlertView alloc] initWithTitle:@"Warning"
													   message:@"No network. You may be able to follow a previously planned route, if you have already viewed the maps."
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[networkAlert show];				
	}	
}



-(void)showTabBarViewControllerByName:(NSString*)viewname{
	
	int count=[tabBarController.viewControllers count];
	int index=-1;
	for (int i=0;i<count;i++) {
		UIViewController *navcontroller=[tabBarController.viewControllers objectAtIndex:i];
		if([navcontroller.tabBarItem.title isEqualToString:viewname]){
			index=i;
			break;
		}
	}
	
	if(index!=-1){
		[tabBarController setSelectedIndex:index];
	}else {
		BetterLog(@"[ERROR] unable to find tabbarItem with name %@",viewname);
	}

	
}


//
/***********************************************
 * Utility method to set the navigationBar colors
 ***********************************************/
//
- (void)setBarStyle:(UIBarStyle)style andTintColor:(UIColor *)color forNavigationBar:(UINavigationBar *)bar {
    bar.barStyle = style;
	bar.tintColor = color;	
}

//
/***********************************************
 * Slight hack to get access to the Customisation navigationBAr so we can set its color to same as the rest of the app
 ***********************************************/
//
- (void)tabBarController:(UITabBarController *)controller willBeginCustomizingViewControllers:(NSArray *)viewControllers {
	
	//tabBarControllers=[[NSMutableArray alloc] initWithArray:viewControllers];
	//[tabBarControllers removeObjectsInRange:NSMakeRange(TABBARMORELIMIT,[tabBarControllers count]-TABBARMORELIMIT)];
	
	// Warning: This is brittle, but it works on iPhone OS 3.0 (7A341)!
    UIView *editViews = [controller.view.subviews objectAtIndex:1];
    UINavigationBar *editModalNavBar = [editViews.subviews objectAtIndex:0]; // configure controller will be index 0
	
	[self setBarStyle:UIBarStyleDefault andTintColor:UIColorFromRGB(0x008000) forNavigationBar:editModalNavBar];
	
}


@end
