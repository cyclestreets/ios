    //
//  ItineraryViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryViewController.h"
#import "Route.h"
#import "CSExceptions.h"
#import "ItineraryCellView.h"
#import "SegmentVO.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Stage.h"
#import "Common.h"
#import "FavouritesViewController.h"
#import "AppConstants.h"
#import "ExpandedUILabel.h"
#import "RouteManager.h"

@implementation ItineraryViewController
@synthesize route;
@synthesize routeId;
@synthesize headerText;
@synthesize routeidLabel;
@synthesize readoutLineOne;
@synthesize readoutLineTwo;
@synthesize readoutContainer;
@synthesize tableView;
@synthesize rowHeightsArray;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [route release], route = nil;
    [headerText release], headerText = nil;
    [routeidLabel release], routeidLabel = nil;
    [readoutLineOne release], readoutLineOne = nil;
    [readoutLineTwo release], readoutLineTwo = nil;
    [readoutContainer release], readoutContainer = nil;
    [tableView release], tableView = nil;
    [rowHeightsArray release], rowHeightsArray = nil;
	
    [super dealloc];
}



#pragma mark setters

- (void)setRoute:(Route *)newRoute {
	
	BetterLog(@"");
	
	Route *oldRoute = route;
	route = newRoute;
	[newRoute retain];
	[oldRoute release];
	self.routeId = [[newRoute itinerary] integerValue];
	
	[self createRowHeightsArray];
	[tableView reloadData];
}

- (Route *)route {
	return route;
}



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
		self.routeId=[notification.object integerValue];
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
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	tableView.rowHeight=[ItineraryCellView rowHeight];
	
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
	[readoutlabel release];
	
	[self createNavigationBarUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	BetterLog(@"");
	
	if(route==nil){
		
		
		[self showNoResultsView:YES];
		
		self.navigationItem.rightBarButtonItem.enabled=NO;
		
		
	}else {
		
		[self showNoResultsView:NO];
		
		routeidLabel.text=[route itinerary];
		
		readoutLineOne.labels=[NSArray arrayWithObjects:@"Length:",route.lengthString,
							   @"Estimated time:",route.timeString,nil];
		[readoutLineOne drawUI];
		
		readoutLineTwo.labels=[NSArray arrayWithObjects:@"Planned speed:",route.speedString,
							   @"Strategy:",[route plan],nil];
		[readoutLineTwo drawUI];
		
		self.navigationItem.rightBarButtonItem.enabled=YES;
		
		
	}
	
}


-(void)createNavigationBarUI{
	
	UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveItineraryButtonSelected:)];
	[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
	[rightBarButton release];
	
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
    
    ItineraryCellView *cell = (ItineraryCellView *)[tv dequeueReusableCellWithIdentifier:[ItineraryCellView cellIdentifier]];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ItineraryCell" owner:self options:nil];
		cell = (ItineraryCellView *)[nib objectAtIndex:0];
		[cell initialise];
		
    }
	
	// Configure the cell...
	SegmentVO *segment = [route segmentAtIndex:indexPath.row];
	cell.dataProvider=segment;
	[cell populate];
	
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create and push stage details view controller.
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	Stage *stage = [cycleStreets.appDelegate stage];
	[stage setRoute:route];
	[self presentModalViewController:stage animated:YES];
	[stage setSegmentIndex:indexPath.row];
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
