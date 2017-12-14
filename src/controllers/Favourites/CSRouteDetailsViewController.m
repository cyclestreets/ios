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
#import "UIActionSheet+BlocksKit.h"

@import PureLayout;

static NSString *const VIEWTITLE=@"Route details";


@interface CSRouteDetailsViewController()<UIActionSheetDelegate>

@property (nonatomic, strong) UIScrollView           * scrollView;
@property (nonatomic, strong) UIStackView              * viewContainer;
@property (nonatomic, weak) IBOutlet UIStackView       * headerContainer;
@property (nonatomic, weak) IBOutlet ExpandedUILabel * routeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel         * dateLabel;
@property (nonatomic, weak) IBOutlet UILabel         * routeidLabel;
@property (nonatomic, weak) IBOutlet UIStackView       * readoutContainer;
@property (nonatomic, weak) IBOutlet UILabel         * timeLabel;
@property (nonatomic, weak) IBOutlet UILabel         * lengthLabel;
@property (nonatomic, weak) IBOutlet UILabel         * planLabel;
@property (nonatomic, weak) IBOutlet UILabel         * speedLabel;
@property (nonatomic, weak) IBOutlet UILabel         * calorieLabel;
@property (nonatomic, weak) IBOutlet UILabel         * coLabel;
@property (strong, nonatomic) IBOutlet UIButton     *selectRouteButton;

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
	
	self.scrollView=[[UIScrollView alloc]initForAutoLayout];
	[self.view addSubview:_scrollView];
	[_scrollView autoPinEdgesToSuperviewEdges];
	
	self.viewContainer=[[UIStackView alloc] initForAutoLayout];
	_viewContainer.axis=UILayoutConstraintAxisVertical;
	_viewContainer.distribution=UIStackViewDistributionFill;
	_viewContainer.spacing=10;
	_viewContainer.layoutMargins=UIEdgeInsetsMake(10, 20, 0, 20);
	[_viewContainer setLayoutMarginsRelativeArrangement:YES];
	
	self.elevationView=[[CSElevationGraphView alloc] initForAutoLayout];
	
	
	__weak __typeof(&*self)weakSelf = self;
	_elevationView.touchedBlock=^(BOOL touched){
		weakSelf.scrollView.scrollEnabled=!touched;
	};
	
	_elevationView.backgroundColor=[UIColor clearColor];

	
	BUDividerView *d1=[[BUDividerView alloc]initForAutoLayout];
	d1.topStrokeColor=[UIColor lightGrayColor];
	d1.bottomStrokeColor=[UIColor clearColor];
	[d1 autoSetDimension:ALDimensionHeight toSize:4];
	
	BUDividerView *d2=[[BUDividerView alloc]initForAutoLayout];
	d2.topStrokeColor=[UIColor lightGrayColor];
	d2.bottomStrokeColor=[UIColor clearColor];
	[d2 autoSetDimension:ALDimensionHeight toSize:10];
	
	
	NSArray *views=@[_headerContainer,d1,_readoutContainer,d2,_elevationView,_selectRouteButton];
	for(UIView *view in views){
		
		[_viewContainer addArrangedSubview:view];
	}
	
	[_elevationView autoSetDimension:ALDimensionHeight toSize:170];
	
	[_scrollView addSubview:_viewContainer];
	[_viewContainer autoPinEdgesToSuperviewEdges];
	[_viewContainer autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
	[_viewContainer autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
	[_scrollView layoutIfNeeded];
	
	
	if(_dataType!=SavedRoutesDataTypeItinerary){
		UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didSelectRouteActions)];
		[self.navigationItem setRightBarButtonItem:actionButton];
	}
	
		
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}



-(void)createNonPersistentUI{
	
	self.routeNameLabel.text = _route.nameString;
	self.dateLabel.text=_route.dateString;
	self.routeidLabel.text=[NSString stringWithFormat:@"#%@", [_route routeid]];
	
	_timeLabel.text=_route.timeString;
	_lengthLabel.text=_route.lengthString;
	_planLabel.text=[[_route plan] capitalizedString];
	_speedLabel.text=_route.speedString;
	_calorieLabel.text=_route.calorieString;
	_coLabel.text=_route.coString;
	
	_elevationView.dataProvider=_route;
	
	
    BOOL isSelectedRoute=[[RouteManager sharedInstance] routeIsSelectedRoute:_route];
    _selectedRouteIcon.visible=isSelectedRoute;
	
    _selectRouteButton.enabled=!isSelectedRoute;
	_selectRouteButton.visible=_dataType!=SavedRoutesDataTypeItinerary;
	
	
	[_scrollView setContentSize:CGSizeMake(_viewContainer.width, _viewContainer.height)];
}

-(void)viewWillLayoutSubviews{
	[super viewWillLayoutSubviews];
	dispatch_async(dispatch_get_main_queue(), ^{
		[_elevationView update];
	});
	
}


//------------------------------------------------------------------------------------
#pragma mark - UI Events
//------------------------------------------------------------------------------------

// route selection
- (void)selectRoute {
	
	// Note: if both these methods are called on the same run loop, the tab bar will become unresponsive
	
	[self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@NO afterDelay:0.1];
	
	[[RouteManager sharedInstance] selectRoute:self.route];
	
	AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
	[appDelegate showTabBarViewControllerByName:TABBAR_MAP];
}

- (IBAction) routeButtonSelected {
	[self selectRoute];
	
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
	
	// OS8 only //
	[[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor darkGrayColor]];
	
	[actionSheet bk_addButtonWithTitle:@"Rename route" handler:^{
		[ViewUtilities createTextEntryAlertView:@"Enter Route name" fieldText:_route.nameString delegate:weakSelf];
	}];
	
	if(_dataType!=SavedRoutesDataTypeFavourite)
	[actionSheet bk_addButtonWithTitle:@"Add to favourites" handler:^{
		[weakSelf favouriteRoute];
	}];
	
	
	[actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:^{
		
	}];
	
	[actionSheet showInView:[[[UIApplication sharedApplication]delegate]window]];

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
