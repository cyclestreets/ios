    //
//  RoutesViewContoller.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RoutesViewContoller.h"
#import "AppConstants.h"
#import "ViewUtilities.h"
#import "StyleManager.h"
#import "RouteListViewController.h"

@implementation RoutesViewContoller
@synthesize titleHeaderView;
@synthesize controlView;
@synthesize routeTypeControl;
@synthesize subViewsArray;
@synthesize classArray;
@synthesize nibArray;
@synthesize dataTypeArray;
@synthesize contentView;
@synthesize activeIndex;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [titleHeaderView release], titleHeaderView = nil;
    [controlView release], controlView = nil;
    [routeTypeControl release], routeTypeControl = nil;
    [subViewsArray release], subViewsArray = nil;
    [classArray release], classArray = nil;
    [nibArray release], nibArray = nil;
    [dataTypeArray release], dataTypeArray = nil;
    [contentView release], contentView = nil;
	
    [super dealloc];
}



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	
	// points to SavedRoutesManager
	//*favouritesdataProvider; 
	//*recentsdataProvider;
	
	
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
	[self selectedIndexDidChange:0];
}


-(void)createPersistentUI{
	
	[self createNavigationBarUI];
	
	controlView.backgroundColor=[[StyleManager sharedInstance] colorForType:@"controlbar"];
	[controlView drawBorderwithColor:UIColorFromRGB(0x333333) andStroke:1 left:NO right:NO top:YES bottom:YES];
	
	NSMutableArray *sdp = [[NSMutableArray alloc] initWithObjects:@"Favourites", @"Recent",  nil];
	routeTypeControl=[[BUSegmentedControl alloc]init];
	routeTypeControl.dataProvider=sdp;
	routeTypeControl.delegate=self;
	routeTypeControl.itemWidth=100;
	[routeTypeControl buildInterface];
	[controlView addSubview:routeTypeControl];
	
	[ViewUtilities alignView:routeTypeControl withView:controlView :BUCenterAlignMode :BUCenterAlignMode];
	
	contentView=[[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATIONHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
	[self.view addSubview:contentView];
	
	// create arrays to store sub views & class references
	classArray=[[NSMutableArray alloc]initWithObjects:@"RouteListViewController",@"RouteListViewController",nil];
	nibArray=[[NSMutableArray alloc]initWithObjects:@"RouteListView",@"RouteListView",nil];
	dataTypeArray=[[NSMutableArray alloc]initWithObjects:@"Favourites",@"Recent",nil];
	subViewsArray=[[NSMutableArray alloc]init];
	for (int i = 0; i < [classArray count]; i++) {
		
		RouteListViewController *vc = (RouteListViewController*)[[NSClassFromString([classArray objectAtIndex:i]) alloc] initWithNibName:[nibArray objectAtIndex:i] bundle:nil];
		vc.frame=CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI);
		[contentView addSubview:vc.view];
		vc.delegate=self;
		[subViewsArray addObject:vc];
		
		if (i==1) {
			vc.isSectioned=YES;
		}
		[vc viewWillAppear:NO];
		[vc release];
    }
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	
}


-(void)createNavigationBarUI{
	
	CustomNavigtionBar *nav=[[CustomNavigtionBar alloc]init];
	self.navigation=nav;
    [nav release];
	navigation.delegate=self;
	navigation.leftItemType=BUNavNoneType;
    navigation.rightItemType=BUNavNoneType;
	navigation.titleType=BUNavTitleDefaultType;
	navigation.titleString=@"Saved Routes";
    navigation.titleFontColor=[UIColor whiteColor];
	navigation.navigationItem=self.navigationItem;
	[navigation createNavigationUI];
	
}



//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//


//
/***********************************************
 * @description		RKCustomSegmentedControl  delegate method	
 ***********************************************/
//
-(void)selectedIndexDidChange:(int)index{
	
	
	if(activeIndex!=-1){
			UIView *activeitemView=[[subViewsArray objectAtIndex:activeIndex] view];
			activeitemView.hidden=YES;
		}
		
		UIView *itemView=[[subViewsArray objectAtIndex:index] view];
		[contentView bringSubviewToFront:itemView];
		activeIndex=index;
		itemView.hidden=NO;
		
		//[[GoogleAnalyticsManager sharedGoogleAnalyticsManager] trackPageViewWithNavigation:self.navigationController.viewControllers andFragment:vc.GATag];
	
	
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
