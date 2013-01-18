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
#import "UIView+Additions.h"

@interface RouteSummary()


@property (nonatomic, strong) UIScrollView							* scrollView;
@property (nonatomic, strong) LayoutBox								* viewContainer;
@property (nonatomic, strong) IBOutlet LayoutBox					* headerContainer;
@property (nonatomic, strong) IBOutlet ExpandedUILabel				* routeNameLabel;
@property (nonatomic, strong) IBOutlet UILabel						* dateLabel;
@property (nonatomic, strong) IBOutlet UILabel						* routeidLabel;
@property (nonatomic, strong) IBOutlet LayoutBox					* readoutContainer;
@property (nonatomic, strong) IBOutlet UILabel						* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel						* lengthLabel;
@property (nonatomic, strong) IBOutlet UILabel						* planLabel;
@property (nonatomic, strong) IBOutlet UILabel						* speedLabel;
@property (nonatomic, strong) IBOutlet UILabel						* calorieLabel;
@property (nonatomic, strong) IBOutlet UILabel						* coLabel;

@property (nonatomic,strong)  CSElevationGraphView					*elevationView;

@property (nonatomic, weak)	IBOutlet UIImageView					*selectedRouteIcon;


-(void)selectedRouteUpdated;

@end

@implementation RouteSummary



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
	
	[self createNavigationBarUI];

}


-(void)createPersistentUI{
	
	
	self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHNAVANDTAB)];
	[self.view addSubview:_scrollView];
	
	self.viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	_viewContainer.fixedWidth=YES;
	_viewContainer.itemPadding=7;
	_viewContainer.paddingTop=10;
	_viewContainer.paddingBottom=20;
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.alignMode=BUCenterAlignMode;
	[_scrollView addSubview:_viewContainer];
	
	_headerContainer.layoutMode=BUVerticalLayoutMode;
	[_headerContainer initFromNIB];
	_readoutContainer.layoutMode=BUVerticalLayoutMode;
	_readoutContainer.paddingLeft=20;
	[_readoutContainer initFromNIB];
	
	
	self.elevationView=[[CSElevationGraphView alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 120)];
	_elevationView.delegate=self;
	_elevationView.backgroundColor=[UIColor clearColor];
	
	
	BUDividerView *d1=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 2)];
	d1.backgroundColor=[UIColor clearColor];
	BUDividerView *d2=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 2)];
	d2.backgroundColor=[UIColor clearColor];
	
	
	_routeNameLabel.multiline=YES;
	
	[_viewContainer addSubViewsFromArray:[NSArray arrayWithObjects:_headerContainer,d1,_readoutContainer,d2,_elevationView, nil]];
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}



-(void)createNonPersistentUI{
	
	self.routeNameLabel.text = _route.nameString;
	self.dateLabel.text=_route.dateString;
	[_headerContainer refresh];
	
	_timeLabel.text=_route.timeString;
	_lengthLabel.text=_route.lengthString;
	_planLabel.text=[[_route plan] capitalizedString];
	_speedLabel.text=_route.speedString;
	_calorieLabel.text=_route.calorieString;
	_coLabel.text=_route.coString;
	
	_elevationView.dataProvider=_route;
	[_elevationView update];
	
	_selectedRouteIcon.visible=[[RouteManager sharedInstance] routeIsSelectedRoute:_route];
	
	
	[_viewContainer refresh];
	
	[_scrollView setContentSize:CGSizeMake(SCREENWIDTH, _viewContainer.height)];
	
	[navigation updateTitleString:[NSString stringWithFormat:@"Route #%@", [_route routeid]]];
}



-(void)createNavigationBarUI{
	
	CustomNavigtionBar *nav=[[CustomNavigtionBar alloc]init];
	self.navigation=nav;
	navigation.delegate=self;
	navigation.leftItemType=BUNavBackStandardType;
    navigation.rightItemType=UIKitButtonType;
	navigation.rightButtonTitle=@"Action";
	navigation.titleType=BUNavTitleDefaultType;
	navigation.titleString=@"Route";
    navigation.titleFontColor=[UIColor whiteColor];
	navigation.navigationItem=self.navigationItem;
	[navigation createNavigationUI];
	
}


#define RenameIndex 999
#define SelectIndex 998
#define FavouriteIndex 997

-(void)doNavigationSelector:(NSString *)type{
	
	if ([type isEqualToString:RIGHT]) {
		
		// if for route state
		NSMutableArray *actionbuttons=[@[@{@"type":@"green",@"text":@"Rename route",@"index":@(RenameIndex)}] mutableCopy];
		
		if ([[RouteManager sharedInstance] routeIsSelectedRoute:_route]==NO) {
			[actionbuttons insertObject:@{@"type":@"orange",@"text":@"Select route",@"index":@(SelectIndex)} atIndex:0];
		}
		
		if(_dataType!=SavedRoutesDataTypeFavourite){
			[actionbuttons addObject:@{@"type":@"blue",@"text":@"Add to favourites",@"index":@(FavouriteIndex)}];
		}
		
		BUActionSheet *actionSheet=[[BUActionSheet alloc] initWithButtons:actionbuttons andTitle:@"Route actions"];
		actionSheet.showsCancelButton=YES;
		actionSheet.delegate=self;
		[actionSheet show:YES];
		
	}
	
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




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex > 0) {
        
		switch(alertView.tag){
			case kTextEntryAlertTag:
			{
				UITextField *alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				if (alertInputField!=nil) {
					_route.userRouteName=alertInputField.text;
					[[SavedRoutesManager sharedInstance] saveRouteChangesForRoute:_route];
					[self createNonPersistentUI];
				}
			}
                break;
                
			default:
				
			break;
                
		}
		
		
	}
	
}




-(void)favouriteRoute{
	
	BOOL result=[[SavedRoutesManager sharedInstance] moveRoute:_route toDataProvider:SAVEDROUTE_FAVS];
	
	if(result==YES){
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Added to favourites" andMessage:nil];
		
		
	}else{
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Unable to add to favourites" andMessage:nil];
	}
}


//
/***********************************************
 * @description			BUActionSheet delegate
 ***********************************************/
//

-(void)actionSheetClickedButtonAtIndex:(NSInteger)buttonIndex{
	
	switch (buttonIndex) {
		case RenameIndex:
			[ViewUtilities createTextEntryAlertView:@"Enter Route name" fieldText:_route.nameString delegate:self];
		break;
		case SelectIndex:
			[self selectRoute];
		break;
		case FavouriteIndex:
			[self favouriteRoute];
		break;
	}
	
}

//
/***********************************************
 * @description			CSElevationGraphViewDelegate
 ***********************************************/
//

-(void)touchInGraph:(BOOL)touched{
	
	BetterLog(@"touchInGraph=%i",touched);
	
	_scrollView.scrollEnabled=!touched;
	
}


//
/***********************************************
 * @description			generic methods
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	
    
}



@end
