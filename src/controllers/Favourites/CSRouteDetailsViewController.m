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

//  CSRouteDetailsViewController
//  CycleStreets
//
//

#import "CSRouteDetailsViewController.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "RouteSegmentViewController.h"
#import "RouteManager.h"
#import "BUDividerView.h"
#import "ButtonUtilities.h"
#import "ViewUtilities.h"
#import "RouteManager.h"
#import "UIView+Additions.h"
#import "HudManager.h"
#import "GenericConstants.h"
#import "RouteVO.h"
#import "LayoutBox.h"
#import "ExpandedUILabel.h"
#import "CSElevationGraphView.h"
#import <UIActionSheet+BlocksKit.h>

static NSString *const VIEWTITLE=@"Route details";


@interface CSRouteDetailsViewController()<UIActionSheetDelegate>

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

@property (nonatomic,strong)  CSElevationGraphView					*elevationView;

@property (nonatomic, weak)	IBOutlet UIImageView					*selectedRouteIcon;


-(void)selectedRouteUpdated;

@end

@implementation CSRouteDetailsViewController



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:CSROUTESELECTED];
	[notifications addObject:SAVEDROUTEUPDATE];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:CSROUTESELECTED]){
        [self selectedRouteUpdated];
    }
	
	if([notification.name isEqualToString:SAVEDROUTEUPDATE]){
        [self routeUpdatedWithRoute:notification.object];
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

-(void)routeUpdatedWithRoute:(RouteVO*)newroute{
    
    if([newroute.fileid isEqualToString:self.route.fileid]==YES){
        self.route=newroute;
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
	
	
	self.title=VIEWTITLE;
	
	self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHNAVANDTAB)];
	[self.view addSubview:_scrollView];
	
	_viewContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
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
	[_readoutContainer initFromNIB];
	
	self.elevationView=[[CSElevationGraphView alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 170)];
	
	__weak __typeof(&*self)weakSelf = self;
	_elevationView.touchedBlock=^(BOOL touched){
		weakSelf.scrollView.scrollEnabled=!touched;
	};
	
	
	//_elevationView.delegate=self;
	_elevationView.backgroundColor=[UIColor clearColor];

	
	
	BUDividerView *d1=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	d1.topStrokeColor=[UIColor lightGrayColor];
	d1.bottomStrokeColor=[UIColor clearColor];
	BUDividerView *d2=[[BUDividerView alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	d2.topStrokeColor=[UIColor lightGrayColor];
	d2.bottomStrokeColor=[UIColor clearColor];
	
	//[_routeButton setTitle:@"Select this route" forState:UIControlStateNormal];
	//[_renameButton setTitle:@"Rename this route" forState:UIControlStateNormal];
	//[_favouriteButton setTitle:@"Add to favourites" forState:UIControlStateNormal];
	
	_routeNameLabel.multiline=YES;
	
	[_viewContainer addSubViewsFromArray:[NSMutableArray arrayWithObjects:_headerContainer,d1,_readoutContainer,d2,_elevationView, nil]];
	
	
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didSelectRouteActions)];
	[self.navigationItem setRightBarButtonItem:actionButton];
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}



-(void)createNonPersistentUI{
	
	self.routeNameLabel.text = _route.nameString;
	self.dateLabel.text=_route.dateString;
	self.routeidLabel.text=[NSString stringWithFormat:@"#%@", [_route routeid]];
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
}



//------------------------------------------------------------------------------------
#pragma mark - UI Events
//------------------------------------------------------------------------------------

// route selection
- (void)selectRoute {
	[self.navigationController popViewControllerAnimated:YES];
	
	[[RouteManager sharedInstance] selectRoute:self.route];
	
	AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
	[appDelegate showTabBarViewControllerByName:TABBAR_MAP];
}	

- (IBAction) routeButtonSelected {
	[self selectRoute];
	
}



// route naming
-(IBAction)renameButtonSelected:(id)sender{
	
	[ViewUtilities createTextEntryAlertView:@"Enter Route name" fieldText:_route.nameString delegate:self];
	
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



// favouriting

-(void)favouriteRoute{
	
	BOOL result=[[SavedRoutesManager sharedInstance] moveRoute:_route toDataProvider:SAVEDROUTE_FAVS];
	
	if(result==YES){
		
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Added to favourites" andMessage:nil];
		
	}else{
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeError withTitle:@"Unable to add to favourites" andMessage:nil];
	}

}



-(IBAction)didSelectRouteActions{
	
	__weak __typeof(&*self)weakSelf = self;
	UIActionSheet *actionSheet=[UIActionSheet bk_actionSheetWithTitle:@"Route options"];
	actionSheet.delegate=self;
	[actionSheet bk_addButtonWithTitle:@"Select route" handler:^{
			[weakSelf selectRoute];
	}];
	[actionSheet bk_addButtonWithTitle:@"Rename route" handler:^{
		[ViewUtilities createTextEntryAlertView:@"Enter Route name" fieldText:_route.nameString delegate:weakSelf];
	}];
	
	if(_dataType!=SavedRoutesDataTypeFavourite)
	[actionSheet bk_addButtonWithTitle:@"Add to favourites" handler:^{
		[weakSelf favouriteRoute];
	}];
	
	
	[actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
		
	}];
	
	[actionSheet showInView:self.view];

	
	
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
