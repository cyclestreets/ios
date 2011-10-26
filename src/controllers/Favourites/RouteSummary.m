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
#import "CycleStreetsAppDelegate.h"
#import "Stage.h"
#import "Route.h"
#import "RouteManager.h"
#import "BUDividerView.h"
#import "ButtonUtilities.h"
#import "ViewUtilities.h"
#import "RouteManager.h"


@interface RouteSummary(Private)

-(void)selectedRouteUpdated;

@end

@implementation RouteSummary
@synthesize route;
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
@synthesize routeButton;
@synthesize renameButton;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [route release], route = nil;
    [viewContainer release], viewContainer = nil;
    [headerContainer release], headerContainer = nil;
    [routeNameLabel release], routeNameLabel = nil;
    [dateLabel release], dateLabel = nil;
    [routeidLabel release], routeidLabel = nil;
    [readoutContainer release], readoutContainer = nil;
    [timeLabel release], timeLabel = nil;
    [lengthLabel release], lengthLabel = nil;
    [planLabel release], planLabel = nil;
    [speedLabel release], speedLabel = nil;
    [routeButton release], routeButton = nil;
    [renameButton release], renameButton = nil;
	
    [super dealloc];
}



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
	
	viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	viewContainer.fixedWidth=YES;
	viewContainer.itemPadding=10;
	viewContainer.paddingTop=10;
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.alignMode=BUCenterAlignMode;
	[self.view addSubview:viewContainer];
	
	headerContainer.layoutMode=BUVerticalLayoutMode;
	[headerContainer initFromNIB];
	readoutContainer.layoutMode=BUVerticalLayoutMode;
	[readoutContainer initFromNIB];
	
	
	BUDividerView *d1=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	BUDividerView *d2=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	
	
	[ButtonUtilities styleIBButton:routeButton type:@"green" text:@"Select this route"];
	[ButtonUtilities styleIBButton:renameButton type:@"orange" text:@"Rename this route"];
	
	routeNameLabel.multiline=YES;
	
	[viewContainer addSubViewsFromArray:[NSArray arrayWithObjects:headerContainer,d1,readoutContainer,d2,routeButton,renameButton,nil]];
	
	[d1 release];
	[d2 release];
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}



-(void)createNonPersistentUI{
	
	self.routeNameLabel.text = [route name];
	self.dateLabel.text=route.dateString;
	self.routeidLabel.text=[NSString stringWithFormat:@"#%@", [route routeid]];
	[headerContainer refresh];
	
	timeLabel.text=route.timeString;
	lengthLabel.text=route.lengthString;
	planLabel.text=[[route plan] capitalizedString];
	speedLabel.text=route.speedString;
	
	
	[viewContainer refresh];
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

- (IBAction) didRouteButton {
	[self selectRoute];
	
}



// route naming
-(IBAction)renameButtonSelected:(id)sender{
	
	[ViewUtilities createTextEntryAlertView:@"Enter Route name" fieldText:route.name delegate:self];
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex > 0) {
        
		switch(alertView.tag){
			case kTextEntryAlertTag:
			{
				UITextField *alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				if (alertInputField!=nil) {
					route.userRouteName=alertInputField.text;
					[self createNonPersistentUI];
				}
			}
                break;
                
			default:
				
			break;
                
		}
		
		
	}
	
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
