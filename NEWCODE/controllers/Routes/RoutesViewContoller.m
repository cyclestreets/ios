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
	
	
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	activeIndex=-1;
	
	// create arrays to store sub views & class references
	classArray=[[NSMutableArray alloc]initWithObjects:@"RouteListViewController",@"RouteListViewController",nil];
	nibArray=[[NSMutableArray alloc]initWithObjects:@"RouteListView",@"RouteListView",nil];
	dataTypeArray=[[NSMutableArray alloc]initWithObjects:@"Favourites",@"All",nil];
	subViewsArray=[[NSMutableArray alloc]init];
	for (unsigned i = 0; i < [classArray count]; i++) {
        [subViewsArray addObject:[NSNull null]];
    }
	
    [super viewDidLoad];
	
	[self createPersistentUI];
	[self selectedIndexDidChange:0];
}


-(void)createPersistentUI{
	
	[self createNavigationBarUI];
	
	controlView.backgroundColor=[[StyleManager sharedInstance] colorForType:@"controlbar"];
	[controlView drawBorderwithColor:UIColorFromRGB(0x333333) andStroke:1 left:NO right:NO top:YES bottom:NO];
	
	NSMutableArray *sdp = [[NSMutableArray alloc] initWithObjects:@"Favourites", @"All",  nil];
	routeTypeControl=[[BUSegmentedControl alloc]init];
	routeTypeControl.dataProvider=sdp;
	routeTypeControl.delegate=self;
	routeTypeControl.itemWidth=75;
	[routeTypeControl buildInterface];
	[controlView addSubview:routeTypeControl];
	
	[ViewUtilities alignView:routeTypeControl withView:controlView :BUCenterAlignMode :BUCenterAlignMode];
	
	contentView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADERCONTROLHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI)];
	[self.view addSubview:contentView];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	
}


-(void)createNavigationBarUI{
	
	
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
	
	SuperViewController *vc = [subViewsArray objectAtIndex:index];
	
	if ((NSNull *)vc == [NSNull null]){
		
		if(activeIndex!=-1){
			UIView *activeitemView=[[subViewsArray objectAtIndex:activeIndex] view];
			activeitemView.hidden=YES;
		}
		
		activeIndex=index;
		
		NSString *nibName=[nibArray objectAtIndex:index];
		SuperViewController *newViewController;
		if((NSNull*)nibName==[NSNull null]){
			newViewController= (SuperViewController*)[[NSClassFromString([classArray objectAtIndex:index]) alloc] init];
			newViewController.frame=CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI);
		}else {
			newViewController = (SuperViewController*)[[NSClassFromString([classArray objectAtIndex:index]) alloc] initWithNibName:[nibArray objectAtIndex:index] bundle:nil];
			newViewController.frame=CGRectMake(0, CONTROLUIHEIGHT, SCREENWIDTH, SCREENHEIGHTWITHCONTROLUI);
		}
		[newViewController setValue:[dataTypeArray objectAtIndex:activeIndex] forKey:@"dataType"];
		[contentView addSubview:newViewController.view];
		newViewController.delegate=self;
		[subViewsArray replaceObjectAtIndex:index withObject:newViewController];
		[newViewController viewWillAppear:NO];
		
		//[[GoogleAnalyticsManager sharedGoogleAnalyticsManager] trackPageViewWithNavigation:self.navigationController.viewControllers andFragment:newViewController.GATag];
		
		[newViewController release];
		
	}else {
		
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
