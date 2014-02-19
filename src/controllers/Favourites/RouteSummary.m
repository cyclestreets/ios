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
#import "GenericConstants.h"

@interface RouteSummary()

@property (nonatomic, strong) UIScrollView           * scrollView;
@property (nonatomic, strong) LayoutBox              * viewContainer;
@property (nonatomic, weak) IBOutlet LayoutBox       * headerContainer;
@property (nonatomic, weak) IBOutlet ExpandedUILabel * routeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel         * dateLabel;
@property (nonatomic, weak) IBOutlet UILabel         * routeidLabel;
@property (nonatomic, weak) IBOutlet LayoutBox       * readoutContainer;
@property (nonatomic, weak) IBOutlet UILabel         * timeLabel;
@property (nonatomic, weak) IBOutlet UILabel         * lengthLabel;
@property (nonatomic, weak) IBOutlet UILabel         * planLabel;
@property (nonatomic, weak) IBOutlet UILabel         * speedLabel;
@property (nonatomic, weak) IBOutlet UILabel         * calorieLabel;
@property (nonatomic, weak) IBOutlet UILabel         * coLabel;
@property (nonatomic, weak) IBOutlet UIButton        * routeButton;
@property (nonatomic, weak) IBOutlet UIButton        * renameButton;
@property (nonatomic, weak) IBOutlet UIButton        * favouriteButton;

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
	d1.topStrokeColor=[UIColor lightGrayColor];
	d1.bottomStrokeColor=[UIColor clearColor];
	BUDividerView *d2=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	d2.topStrokeColor=[UIColor lightGrayColor];
	d2.bottomStrokeColor=[UIColor clearColor];
	
	[routeButton setTitle:@"Select this route" forState:UIControlStateNormal];
	[renameButton setTitle:@"Rename this route" forState:UIControlStateNormal];
	[favouriteButton setTitle:@"Add to favourites" forState:UIControlStateNormal];
	
	routeNameLabel.multiline=YES;
	
	[viewContainer addSubViewsFromArray:[NSMutableArray arrayWithObjects:headerContainer,d1,readoutContainer,d2,routeButton,renameButton,favouriteButton,nil]];
	
	
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
	
	//[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"Plan route"];
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
				UITextField *alertInputField=nil;
				// os7 cant get view tag for field
				if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
					alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				}else{
					alertInputField=(UITextField*)[alertView textFieldAtIndex:0];
				}
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
	
	BOOL result=[[SavedRoutesManager sharedInstance] moveRoute:route toDataProvider:SAVEDROUTE_FAVS];
	
	if(result==YES){
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Added to favourites" andMessage:nil];
	
		favouriteButton.hidden=YES;
		
	}else{
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Unable to add to favourites" andMessage:nil];
	}

}



//
/***********************************************
 * @description			generic methods
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
	
	self.route=nil;
	self.scrollView=nil;
	self.viewContainer=nil;
    
}




@end
