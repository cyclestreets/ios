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
#import <Twitter/Twitter.h>
#import "GenericConstants.h"
#import "MultiLabelLine.h"
#import "LayoutBox.h"
#import "RouteSegmentViewController.h"
#import "CopyLabel.h"
#import "BUIconActionSheet.h"
#import <MessageUI/MessageUI.h>
#import <A2StoryboardSegueContext.h>
#import "CSRouteDetailsViewController.h"


@interface ItineraryViewController()<UITableViewDelegate,UITableViewDataSource,BUIconActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) RouteVO                      * route;
@property (nonatomic, assign) NSInteger                    routeId;
@property (nonatomic, strong) UITextView                   * headerText;
@property (nonatomic, strong) RouteSegmentViewController * routeSegmentViewcontroller;
@property (nonatomic, weak) IBOutlet CopyLabel             * routeidLabel;
@property (nonatomic, strong) MultiLabelLine               * readoutLineOne;
@property (nonatomic, strong) MultiLabelLine               * readoutLineTwo;
@property (nonatomic, strong) MultiLabelLine               * readoutLineThree;
@property (nonatomic, weak) IBOutlet LayoutBox             * readoutContainer;
@property (nonatomic, weak) IBOutlet UITableView           * tableView;
@property (nonatomic, strong) NSMutableArray               * rowHeightsArray;
@property (nonatomic,strong) CSRouteDetailsViewController   *routeSummary;
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
		
		_readoutLineOne.labels=[NSMutableArray arrayWithObjects:@"Length:",_route.lengthString,
							   @"Estimated time:",_route.timeString,nil];
		[_readoutLineOne drawUI];
		
		_readoutLineTwo.labels=[NSMutableArray arrayWithObjects:@"Planned speed:",_route.speedString,
							   @"Strategy:",_route.planString,nil];
		[_readoutLineTwo drawUI];
		
		_readoutLineThree.labels=[NSMutableArray arrayWithObjects:@"Calories:",_route.calorieString,
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
	
	
	[self performSegueWithIdentifier:@"RouteSegmentSegue" sender:self context:@{DATAPROVIDER: _route,INDEX:@([indexPath row])}];
	 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return [[_rowHeightsArray objectAtIndex:[indexPath row]] floatValue];
}




//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//

-(IBAction)didSelectRouteDetailsButton:(id)sender{
	
	if (self.routeSummary == nil) {
		self.routeSummary = [[CSRouteDetailsViewController alloc]init];
	}
	self.routeSummary.route = _route;
	_routeSummary.dataType=SavedRoutesDataTypeItinerary;
	[self showUniqueViewController:_routeSummary];
	
	
}



#define kItineraryPlanView 9001
-(void)showNoActiveRouteView:(BOOL)show{
	
	if(show==YES){
		
		GradientView *errorView;
		LayoutBox *contentContainer;
		
		errorView = (GradientView*)[self.view viewWithTag:kItineraryPlanView];
		
		if(errorView!=nil)
			[errorView removeFromSuperview];
		
		contentContainer=[[LayoutBox alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHMODALNAV)];
		errorView=[[GradientView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHTWITHMODALNAV)];
		
		[errorView setColoursWithCGColors:UIColorFromRGB(0xFFFFFF).CGColor :UIColorFromRGB(0xDDDDDD).CGColor];
		errorView.tag=kItineraryPlanView;
		contentContainer.layoutMode=BUVerticalLayoutMode;
        contentContainer.itemPadding=20;
        contentContainer.fixedWidth=YES;
        contentContainer.alignMode=BUCenterAlignMode;
		
		ExpandedUILabel *titlelabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		titlelabel.styleClass=@"UISubtitleLabel";
		titlelabel.text=@"You have no route active currently.";
		[contentContainer addSubview:titlelabel];					
		
		ExpandedUILabel *infolabel=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, UIWIDTH, 10)];
		infolabel.styleClass=@"UIMessageLabel";
		infolabel.text=@"Once you have loaded a route, the itinerary will be shown here.";
		[contentContainer addSubview:infolabel];					
		
		UIButton *routeButton=[ButtonUtilities UIPixateButtonWithWidth:120 height:32 styleId:@"GreenButton" text:@"Plan route"];
		[routeButton addTarget:self action:@selector(swapToMapView) forControlEvents:UIControlEventTouchUpInside];
		[contentContainer addSubview:routeButton];
		
		UIButton *savedButton=[ButtonUtilities UIPixateButtonWithWidth:120 height:32 styleId:@"GreenButton" text:@"Saved routes"];
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
	
	AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
	[appDelegate showTabBarViewControllerByName:TABBAR_MAP];
}

-(IBAction)swapToSavedRoutesView{
	AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
	[appDelegate showTabBarViewControllerByName:TABBAR_ROUTES];
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	if([segue.identifier isEqualToString:@"RouteSegmentSegue"]){
		
		RouteSegmentViewController *controller=segue.destinationViewController;
		NSDictionary *context=segue.context;
		controller.route=context[DATAPROVIDER];
		controller.index=[context[INDEX] integerValue];
		
	}
	
	
}



-(void)createRowHeightsArray{
	
	self.rowHeightsArray=[[NSMutableArray alloc]init];
	
	for (int i=0; i<[_route numSegments]; i++) {
		
		SegmentVO *segment = [_route segmentAtIndex:i];
		
		[_rowHeightsArray addObject:[ItineraryCellView heightForCellWithDataProvider:segment]];
		
		
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}




@end
