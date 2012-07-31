    //
//  ItineraryViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryViewController.h"
#import "RouteVO.h"
#import "ItineraryCellView.h"
#import "SegmentVO.h"
#import "CycleStreets.h"
#import "AppDelegate.h"
#import "RouteSegmentViewController.h"
#import "ButtonUtilities.h"
#import "AppConstants.h"
#import "ExpandedUILabel.h"
#import "RouteManager.h"
#import "LayoutBox.h"
#import "ViewUtilities.h"
#import "GradientView.h"

@implementation ItineraryViewController
@synthesize route;
@synthesize routeId;
@synthesize headerText;
@synthesize routeSegmentViewcontroller;
@synthesize routeidLabel;
@synthesize readoutLineOne;
@synthesize readoutLineTwo;
@synthesize readoutContainer;
@synthesize tableView;
@synthesize rowHeightsArray;



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
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	if([notification.name isEqualToString:CSROUTESELECTED]){
		[self refreshUIFromDataProvider];
	}
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	self.route=[RouteManager sharedInstance].selectedRoute;
	self.routeId = [route.routeid integerValue];
	
	
	[self createRowHeightsArray];
	[tableView reloadData];
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	[self refreshUIFromDataProvider];
	
    [super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)createPersistentUI{
	
	readoutContainer.paddingTop=5;
	readoutContainer.itemPadding=5;
	readoutContainer.layoutMode=BUVerticalLayoutMode;
	readoutContainer.alignMode=BUCenterAlignMode;
	readoutContainer.fixedWidth=YES;
	readoutContainer.fixedHeight=YES;
	readoutContainer.backgroundColor=UIColorFromRGB(0xE5E5E5);
	
	routeidLabel.multiline=NO;
	
	
	readoutLineOne=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	readoutLineOne.showShadow=YES;
	readoutLineOne.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	readoutLineOne.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	readoutLineTwo=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	readoutLineTwo.showShadow=YES;
	readoutLineTwo.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	readoutLineTwo.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	ExpandedUILabel *readoutlabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	readoutlabel.font=[UIFont systemFontOfSize:13];
	readoutlabel.textColor=UIColorFromRGB(0x666666);
	readoutlabel.shadowColor=[UIColor whiteColor];
	readoutlabel.shadowOffset=CGSizeMake(0, 1);
	readoutlabel.text=@"Select any section to view the map and details for this segment.";
	
	[readoutContainer addSubViewsFromArray:[NSArray arrayWithObjects:readoutLineOne,readoutLineTwo,readoutlabel,nil]];
	
	[self createNavigationBarUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
	[super deSelectRowForTableView:tableView];
	
}

-(void)createNonPersistentUI{
	
	BetterLog(@"");
	
	
	
	
	if(route==nil){
		
		
		[self showNoActiveRouteView:YES];
		
		self.navigationItem.rightBarButtonItem.enabled=NO;
		
		
	}else {
		
		[self showNoActiveRouteView:NO];
		
		routeidLabel.text=[route routeid];
		
		readoutLineOne.labels=[NSArray arrayWithObjects:@"Length:",route.lengthString,
							   @"Estimated time:",route.timeString,nil];
		[readoutLineOne drawUI];
		
		readoutLineTwo.labels=[NSArray arrayWithObjects:@"Planned speed:",route.speedString,
							   @"Strategy:",route.planString,nil];
		[readoutLineTwo drawUI];
		
		self.navigationItem.rightBarButtonItem.enabled=YES;
		
		
	}
	
}


-(void)createNavigationBarUI{
	
	/*
	UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveItineraryButtonSelected:)];
	[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
	[rightBarButton release];
	*/
}


//
/***********************************************
 * @description		UITABLEVIEW DELEGATE METHODS
 ***********************************************/
//

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [route numSegments];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItineraryCellView *cell = (ItineraryCellView *)[ItineraryCellView cellForTableView:tv fromNib:[ItineraryCellView nib]];
	
	SegmentVO *segment = [route segmentAtIndex:indexPath.row];
	cell.dataProvider=segment;
	[cell populate];
	
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
	[cell addGestureRecognizer:recognizer];
	
    return cell;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {	
	
	BetterLog(@"");
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		
		BetterLog(@"");
		
		ItineraryCellView *cell = (ItineraryCellView *)recognizer.view;
        [cell becomeFirstResponder];
		
        UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"Flag" action:@selector(flag:)];
        UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"Approve" action:@selector(approve:)];
		UIMenuItem *deny = [[UIMenuItem alloc] initWithTitle:@"Deny" action:@selector(deny:)];
		
        UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuItems:[NSArray arrayWithObjects:flag, approve, deny, nil]];
		//[menu setTargetRect:cell.frame inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
	}
}


- (void)flag:(id)sender {
	NSLog(@"Cell was flagged");
}

- (void)approve:(id)sender {
	NSLog(@"Cell was approved");
}

- (void)deny:(id)sender {
	NSLog(@"Cell was denied");
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// TODO: this should be pushed not presented
	
	if(routeSegmentViewcontroller==nil){
		self.routeSegmentViewcontroller=[[RouteSegmentViewController alloc] init];
	}
	
	[routeSegmentViewcontroller setRoute:route];
	[self presentModalViewController:routeSegmentViewcontroller animated:YES];
	[routeSegmentViewcontroller setSegmentIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return [[rowHeightsArray objectAtIndex:[indexPath row]] floatValue];
}




//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)saveItineraryButtonSelected:(id)sender{
	
	
	// save this route to the favourites
	
	// show name route alert first
	
}

#define kItineraryPlanView 9001
-(void)showNoActiveRouteView:(BOOL)show{
	
	if(show==YES){
		
		GradientView *errorView;
		LayoutBox *contentContainer;
		
		contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
		errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, NAVTABVIEWHEIGHT)];
		
		[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
		errorView.tag=kItineraryPlanView;
		contentContainer.layoutMode=BUVerticalLayoutMode;
        contentContainer.itemPadding=20;
        contentContainer.fixedWidth=YES;
        contentContainer.alignMode=BUCenterAlignMode;
		
		ExpandedUILabel *titlelabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		titlelabel.font=[UIFont boldSystemFontOfSize:14];
		titlelabel.textAlignment=UITextAlignmentCenter;
		titlelabel.hasShadow=YES;
		titlelabel.textColor=[UIColor grayColor];
		titlelabel.text=@"You have no route active currently.";
		[contentContainer addSubview:titlelabel];					
		
		ExpandedUILabel *infolabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		infolabel.font=[UIFont systemFontOfSize:13];
		infolabel.textAlignment=UITextAlignmentCenter;
		infolabel.hasShadow=YES;
		infolabel.textColor=[UIColor grayColor];
		infolabel.text=@"Once you have loaded a route, the itinerary will be shown here.";
		[contentContainer addSubview:infolabel];					
		
		UIButton *routeButton=[ButtonUtilities UIButtonWithWidth:100 height:32 type:@"green" text:@"Plan route"];
		[routeButton addTarget:self action:@selector(swapToMapView) forControlEvents:UIControlEventTouchUpInside];
		[contentContainer addSubview:routeButton];
		
		UIButton *savedButton=[ButtonUtilities UIButtonWithWidth:100 height:32 type:@"green" text:@"Saved routes"];
		[savedButton addTarget:self action:@selector(swapToSavedRoutesView) forControlEvents:UIControlEventTouchUpInside];
		[contentContainer addSubview:savedButton];
		
		[errorView addSubview:contentContainer];
		[ViewUtilities alignView:contentContainer withView:errorView :BUNoneLayoutMode :BUCenterAlignMode];
		[self.view addSubview:errorView];
		
	}else {
		UIView	*errorView = [self.view viewWithTag:kItineraryPlanView];
		[errorView removeFromSuperview];
		errorView=nil;
		
	}
	
	
}

-(IBAction)swapToMapView{
	[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"Plan route"];
}

-(IBAction)swapToSavedRoutesView{
	[[CycleStreets sharedInstance].appDelegate showTabBarViewControllerByName:@"Saved routes"];
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

-(void)createRowHeightsArray{
	
	self.rowHeightsArray=[[NSMutableArray alloc]init];
	
	for (int i=0; i<[route numSegments]; i++) {
		
		SegmentVO *segment = [route segmentAtIndex:i];
		
		[rowHeightsArray addObject:[ItineraryCellView heightForCellWithDataProvider:segment]];
		
		
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end
