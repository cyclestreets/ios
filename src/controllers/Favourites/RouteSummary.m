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

//  RouteSummary.m
//  CycleStreets
//
//  Created by Alan Paxton on 05/09/2010.
//

#import "RouteSummary.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "RouteSegmentViewController.h"
#import "Route.h"
#import "RouteManager.h"
#import "BUDividerView.h"
#import "ButtonUtilities.h"
#import "ViewUtilities.h"
#import "RouteManager.h"
#import "SavedRoutesManager.h"
#import "HudManager.h"

@interface RouteSummary(Private)

-(void)selectedRouteUpdated;

@end

@implementation RouteSummary
@synthesize route;
@synthesize dataType;
@synthesize scrollView;
@synthesize viewContainer;
@synthesize headerContainer;
@synthesize routeNameLabel;
@synthesize dateLabel;
@synthesize routeidLabel;
@synthesize readoutContainer;
@synthesize timeLabel;
@synthesize lengthLabel;
@synthesize planLabel;
@synthesize speedLabel;
@synthesize calorieLabel;
@synthesize coLabel;
@synthesize routeButton;
@synthesize renameButton;
@synthesize favouriteButton;



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:CSROUTESELECTED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:CSROUTESELECTED]){
        [self selectedRouteUpdated];
    }
	
}

//
/***********************************************
 * @description			DATA>UI UPDATES
 ***********************************************/
//

-(void)selectedRouteUpdated{
    
    BOOL selectedRouteExists=[RouteManager sharedInstance].selectedRoute!=nil;
    
    if(selectedRouteExists==YES){
        self.route=[RouteManager sharedInstance].selectedRoute;
        [self createNonPersistentUI];
    }
}


//
/***********************************************
 * @description			VIEW CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	[self createPersistentUI];

}


-(void)createPersistentUI{
	
	// TODO: SHOULD BE SCROLL VIEW 
	
	self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHNAVANDTAB)];
	[self.view addSubview:scrollView];
	
	viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	viewContainer.fixedWidth=YES;
	viewContainer.itemPadding=7;
	viewContainer.paddingTop=10;
	viewContainer.paddingBottom=20;
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.alignMode=BUCenterAlignMode;
	[scrollView addSubview:viewContainer];
	
	headerContainer.layoutMode=BUVerticalLayoutMode;
	[headerContainer initFromNIB];
	readoutContainer.layoutMode=BUVerticalLayoutMode;
	[readoutContainer initFromNIB];
	
	
	BUDividerView *d1=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	d1.backgroundColor=[UIColor clearColor];
	BUDividerView *d2=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	d2.backgroundColor=[UIColor clearColor];
	
	
	[ButtonUtilities styleIBButton:routeButton type:@"orange" text:@"Select this route"];
	[ButtonUtilities styleIBButton:renameButton type:@"green" text:@"Rename this route"];
	[ButtonUtilities styleIBButton:favouriteButton type:@"red" text:@"Add to favourites"];
	
	routeNameLabel.multiline=YES;
	
	[viewContainer addSubViewsFromArray:[NSArray arrayWithObjects:headerContainer,d1,readoutContainer,d2,routeButton,renameButton,favouriteButton,nil]];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}



-(void)createNonPersistentUI{
	
	self.routeNameLabel.text = route.nameString;
	self.dateLabel.text=route.dateString;
	self.routeidLabel.text=[NSString stringWithFormat:@"#%@", [route routeid]];
	[headerContainer refresh];
	
	timeLabel.text=route.timeString;
	lengthLabel.text=route.lengthString;
	planLabel.text=[[route plan] capitalizedString];
	speedLabel.text=route.speedString;
	calorieLabel.text=route.calorieString;
	coLabel.text=route.coString;
	
	favouriteButton.hidden=dataType==SavedRoutesDataTypeFavourite;
	
	[viewContainer refresh];
	
	[scrollView setContentSize:CGSizeMake(SCREENWIDTH, viewContainer.height)];
}



//
/***********************************************
 * @description			User events
 ***********************************************/
//

// route selection
- (void)selectRoute {
	[self.navigationController popViewControllerAnimated:YES];
	
	[[RouteManager sharedInstance] selectRoute:self.route];
	
	[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"Plan route"];
}	

- (IBAction) routeButtonSelected {
	[self selectRoute];
	
}



// route naming
-(IBAction)renameButtonSelected:(id)sender{
	
	[ViewUtilities createTextEntryAlertView:@"Enter Route name" fieldText:route.nameString delegate:self];
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex > 0) {
        
		switch(alertView.tag){
			case kTextEntryAlertTag:
			{
				UITextField *alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				if (alertInputField!=nil) {
					route.userRouteName=alertInputField.text;
					[[SavedRoutesManager sharedInstance] saveRouteChangesForRoute:route];
					[self createNonPersistentUI];
				}
			}
                break;
                
			default:
				
			break;
                
		}
		
		
	}
	
}



// favouriting

-(IBAction)favouriteButtonSelected:(id)sender{
	
	[[SavedRoutesManager sharedInstance] moveRoute:route toDataProvider:SAVEDROUTE_FAVS];
	
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Added to favourites" andMessage:nil];
	
	favouriteButton.hidden=YES;

}



//
/***********************************************
 * @description			generic methods
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}



@end
