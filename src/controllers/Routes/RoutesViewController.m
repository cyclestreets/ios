    //
//  RoutesViewContoller.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RoutesViewController.h"
#import "AppConstants.h"
#import "ViewUtilities.h"
#import "StyleManager.h"
#import "RouteListViewController.h"
#import "RouteManager.h"
#import "ButtonUtilities.h"
#import <Crashlytics/Crashlytics.h>
#import "FavouritesManager.h"

@interface RoutesViewController()

-(IBAction)selectedRouteButtonSelected:(id)sender;
-(void)selectedRouteUpdated;

@end


@implementation RoutesViewController
@synthesize titleHeaderView;
@synthesize controlView;
@synthesize routeTypeControl;
@synthesize selectedRouteButton;
@synthesize subViewsArray;
@synthesize classArray;
@synthesize nibArray;
@synthesize dataTypeArray;
@synthesize contentView;
@synthesize activeIndex;
@synthesize routeSummary;


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	displaysConnectionErrors=NO;
    
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
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
		
}

-(void)selectedRouteUpdated{
    
    BOOL selectedRouteExists=[RouteManager sharedInstance].selectedRoute!=nil;
    
    selectedRouteButton.enabled=selectedRouteExists;
    
    if(self.navigationController.topViewController==routeSummary){
        if(selectedRouteExists==NO){
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
	
    
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	activeIndex=-1;
	
    [super viewDidLoad];
	
	[self createPersistentUI];
	
	// sets the initial sub view
	int startIndex=1;
	if([SavedRoutesManager sharedInstance].favouritesdataProvider.count>0 )
		startIndex=0;
	
	[routeTypeControl setSelectedSegmentIndex:startIndex];
	[self selectedIndexDidChange:startIndex];
	
}


-(void)createPersistentUI{
	
	[self createNavigationBarUI];
	
	controlView.backgroundColor=[[StyleManager sharedInstance] colorForType:@"controlbar"];
	[controlView drawBorderwithColor:UIColorFromRGB(0x333333) andStroke:1 left:NO right:NO top:YES bottom:YES];
	
	LayoutBox *controlcontainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, CONTROLUIHEIGHT)];
	controlcontainer.fixedWidth=YES;
	controlcontainer.fixedHeight=YES;
	controlcontainer.itemPadding=15;
	controlcontainer.paddingLeft=15;
	controlcontainer.alignMode=BUCenterAlignMode;
	
	NSMutableArray *sdp = [[NSMutableArray alloc] initWithObjects:@"Favourites", @"Recent",  nil];
	routeTypeControl=[[BUSegmentedControl alloc]init];
	routeTypeControl.dataProvider=sdp;
	routeTypeControl.delegate=self;
	routeTypeControl.itemWidth=80;
	[routeTypeControl buildInterface];
	[controlcontainer addSubview:routeTypeControl];
	
	self.selectedRouteButton=[ButtonUtilities UIButtonWithWidth:120 height:28 type:@"orange" text:@"Current Route"];
    [selectedRouteButton addTarget:self action:@selector(selectedRouteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	
	[controlcontainer addSubview:selectedRouteButton];
	[controlView addSubview:controlcontainer];
	
	contentView=[[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATIONHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
	[self.view addSubview:contentView];
	
	// create arrays to store sub views & class references
	classArray=[[NSMutableArray alloc]initWithObjects:@"RouteListViewController",@"RouteListViewController",nil];
	nibArray=[[NSMutableArray alloc]initWithObjects:@"RouteListView",@"RouteListView",nil];
	dataTypeArray=[[NSMutableArray alloc]initWithObjects:SAVEDROUTE_FAVS,SAVEDROUTE_RECENTS,nil];
	subViewsArray=[[NSMutableArray alloc]init];
	for (int i = 0; i < [classArray count]; i++) {
		
		RouteListViewController *vc = (RouteListViewController*)[[NSClassFromString([classArray objectAtIndex:i]) alloc] initWithNibName:[nibArray objectAtIndex:i] bundle:nil];
		[contentView addSubview:vc.view];
		vc.delegate=self;
        vc.dataType=[dataTypeArray objectAtIndex:i];
		[subViewsArray addObject:vc];
		[self addChildViewController:vc];
		
		if (i==1) {
			vc.isSectioned=YES;
		}
		[vc viewWillAppear:NO];
    }
	
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
    selectedRouteButton.enabled=[[RouteManager sharedInstance] selectedRoute]!=nil;
	
}


-(void)createNavigationBarUI{
	
	CustomNavigtionBar *nav=[[CustomNavigtionBar alloc]init];
	self.navigation=nav;
	navigation.delegate=self;
	navigation.leftItemType=BUNavNoneType;
    navigation.rightItemType=UIKitButtonType;
	navigation.rightButtonTitle=@"Fetch Route";
	navigation.titleType=BUNavTitleDefaultType;
	navigation.titleString=@"Routes";
    navigation.titleFontColor=[UIColor whiteColor];
	navigation.navigationItem=self.navigationItem;
	[navigation createNavigationUI];
	
}




//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//


-(IBAction)selectedRouteButtonSelected:(id)sender{
    
    if([[RouteManager sharedInstance] selectedRoute]!=nil)
    [self doNavigationPush:@"RouteSummary" withDataProvider:[[RouteManager sharedInstance] selectedRoute] andIndex:-1];
    
}



-(void)doNavigationSelector:(NSString*)type{
	
	
    if([type isEqualToString:RIGHT]){
		[ViewUtilities createTextEntryAlertView:@"Enter route number" fieldText:nil withMessage:@"Find a CycleStreets route by number" delegate:self];
	}
    
}


// Note: use of didDismissWithButtonIndex, as otherwise the HUD gets removed by the screen clear up performed by Alert 
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex > 0) {
        
		switch(alertView.tag){
                
			case kTextEntryAlertTag:
			{
				UITextField *alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				if (alertInputField!=nil && ![alertInputField.text isEqualToString:EMPTYSTRING]) {
					
					[[RouteManager sharedInstance] loadRouteForRouteId:alertInputField.text];
					
					[routeTypeControl setSelectedSegmentIndex:1];
					[self selectedIndexDidChange:1];
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
 * @description		RKCustomSegmentedControl  delegate method	
 ***********************************************/
//
-(void)selectedIndexDidChange:(int)index{
	
    if(index!=-1){
	
	RouteListViewController *vc = [subViewsArray objectAtIndex:index];
	
    if(activeIndex!=-1){
        UIView *activeitemView=[vc view];
        activeitemView.hidden=YES;
    }
    
    UIView *itemView=[vc view];
    [contentView bringSubviewToFront:itemView];
    activeIndex=index;
    itemView.hidden=NO;
    
    //[[GoogleAnalyticsManager sharedGoogleAnalyticsManager] trackPageViewWithNavigation:self.navigationController.viewControllers andFragment:vc.GATag];
		
	}
	
}



//
/***********************************************
 * @description			ViewController delegate method
 ***********************************************/
//
-(void)doNavigationPush:(NSString*)className withDataProvider:(id)data andIndex:(int)index{
    
    if([className isEqualToString:@"RouteSummary"]){
        
        if (self.routeSummary == nil) {
            self.routeSummary = [[RouteSummary alloc]init];
        }
        self.routeSummary.route = (RouteVO*)data;
		routeSummary.dataType=index;
        [self showUniqueViewController:routeSummary];
        
    }
    
}



//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end
