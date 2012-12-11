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

@interface ItineraryViewController()

@property (nonatomic, strong) RouteVO		* route;
@property (nonatomic, assign) NSInteger		 routeId;
@property (nonatomic, strong) UITextView		* headerText;
@property (nonatomic, strong) RouteSegmentViewController		* routeSegmentViewcontroller;
@property (nonatomic, weak) IBOutlet CopyLabel		* routeidLabel;
@property (nonatomic, strong) MultiLabelLine		* readoutLineOne;
@property (nonatomic, strong) MultiLabelLine		* readoutLineTwo;
@property (nonatomic, strong) MultiLabelLine		* readoutLineThree;
@property (nonatomic, weak) IBOutlet LayoutBox		* readoutContainer;
@property (nonatomic, weak) IBOutlet UITableView		* tableView;
@property (nonatomic, strong) NSMutableArray		* rowHeightsArray;

@end


@implementation ItineraryViewController



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
	self.routeId = [_route.routeid integerValue];
	
	
	[self createRowHeightsArray];
	[_tableView reloadData];
	
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
	
	_readoutContainer.paddingTop=5;
	_readoutContainer.itemPadding=4;
	_readoutContainer.layoutMode=BUVerticalLayoutMode;
	_readoutContainer.alignMode=BUCenterAlignMode;
	_readoutContainer.fixedWidth=YES;
	_readoutContainer.fixedHeight=YES;
	_readoutContainer.backgroundColor=UIColorFromRGB(0xE5E5E5);
	
	_routeidLabel.multiline=NO;
	
	
	self.readoutLineOne=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	_readoutLineOne.showShadow=YES;
	_readoutLineOne.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	_readoutLineOne.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	self.readoutLineTwo=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	_readoutLineTwo.showShadow=YES;
	_readoutLineTwo.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	_readoutLineTwo.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	self.readoutLineThree=[[MultiLabelLine alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 15)];
	_readoutLineThree.showShadow=YES;
	_readoutLineThree.colors=[NSArray arrayWithObjects:UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),UIColorFromRGB(0x804000),UIColorFromRGB(0x000000),nil];
	_readoutLineThree.fonts=[NSArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	
	
	ExpandedUILabel *readoutlabel=[[ExpandedUILabel alloc] initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
	readoutlabel.font=[UIFont systemFontOfSize:12];
	readoutlabel.textColor=UIColorFromRGB(0x666666);
	readoutlabel.shadowColor=[UIColor whiteColor];
	readoutlabel.shadowOffset=CGSizeMake(0, 1);
	readoutlabel.text=@"Select any segment to view the map & details for it.";
	 
	
	[_readoutContainer addSubViewsFromArray:[NSArray arrayWithObjects:_readoutLineOne,_readoutLineTwo,_readoutLineThree,readoutlabel, nil]];
	
	[self createNavigationBarUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
	[super deSelectRowForTableView:_tableView];
	
}

-(void)createNonPersistentUI{
	
	BetterLog(@"");
	
	
	if(_route==nil){
		
		
		[self showNoActiveRouteView:YES];
		
		self.navigationItem.rightBarButtonItem.enabled=NO;
		
		
	}else {
		
		[self showNoActiveRouteView:NO];
		
		_routeidLabel.text=[_route routeid];
		
		_readoutLineOne.labels=[NSArray arrayWithObjects:@"Length:",_route.lengthString,
							   @"Estimated time:",_route.timeString,nil];
		[_readoutLineOne drawUI];
		
		_readoutLineTwo.labels=[NSArray arrayWithObjects:@"Planned speed:",_route.speedString,
							   @"Strategy:",_route.planString,nil];
		[_readoutLineTwo drawUI];
		
		_readoutLineThree.labels=[NSArray arrayWithObjects:@"Calories:",_route.calorieString,
							   @"CO2 saved:",_route.coString,nil];
		[_readoutLineThree drawUI];
		
		self.navigationItem.rightBarButtonItem.enabled=YES;
		
		
	}
	
}


-(void)createNavigationBarUI{
	
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
   return [_route numSegments];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItineraryCellView *cell = (ItineraryCellView *)[ItineraryCellView cellForTableView:tv fromNib:[ItineraryCellView nib]];
	
	SegmentVO *segment = [_route segmentAtIndex:indexPath.row];
	cell.dataProvider=segment;
	[cell populate];
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(_routeSegmentViewcontroller==nil){
		self.routeSegmentViewcontroller=[[RouteSegmentViewController alloc] initWithNibName:@"RouteSegmentView" bundle:nil];
		_routeSegmentViewcontroller.hidesBottomBarWhenPushed=YES;
	}
	
	[_routeSegmentViewcontroller setRoute:_route];
	_routeSegmentViewcontroller.index=[indexPath row];
	
	[self.navigationController pushViewController:_routeSegmentViewcontroller animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return [[_rowHeightsArray objectAtIndex:[indexPath row]] floatValue];
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
	
	for (int i=0; i<[_route numSegments]; i++) {
		
		SegmentVO *segment = [_route segmentAtIndex:i];
		
		[_rowHeightsArray addObject:[ItineraryCellView heightForCellWithDataProvider:segment]];
		
		
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
	
	self.route=nil;
	self.headerText=nil;
	self.routeSegmentViewcontroller=nil;
	self.readoutLineOne=nil;
	self.readoutLineTwo=nil;
	self.readoutLineThree=nil;
	self.rowHeightsArray=nil;
}




@end
