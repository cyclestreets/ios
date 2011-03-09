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
#import "Segment.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Stage.h"
#import "Common.h"
#import "FavouritesViewController.h"

@implementation ItineraryViewController
@synthesize route;
@synthesize routeId;
@synthesize headerText;
@synthesize routeidLabel;
@synthesize readoutLineOne;
@synthesize readoutLineTwo;
@synthesize tableView;

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
    [tableView release], tableView = nil;
	
    [super dealloc];
}

#pragma mark setters

- (void)setRoute:(Route *)newRoute {
	
	Route *oldRoute = route;
	route = newRoute;
	[newRoute retain];
	[oldRoute release];
	self.routeId = [[newRoute itinerary] integerValue];
	
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
	
	tableView.rowHeight=[ItineraryCellView rowHeight];
	
    [super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)createPersistentUI{
	
	if (self.routeId > 0) {
		//reload the current route.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
        FavouritesViewController *favourites = cycleStreets.appDelegate.favourites;
		Route *newRoute = [favourites routeWithIdentifier:self.routeId];
		self.route = newRoute;
	}	
	
	[self createNavigationBarUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	
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
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ItineraryCellView" owner:self options:nil];
		cell = (ItineraryCellView *)[nib objectAtIndex:0];
		[cell initialise];
		
    }
	
	// Configure the cell...
	Segment *segment = [route segmentAtIndex:indexPath.row];
	cell.dataProvider=segment;
	[cell populate];
	
	[segment setUIElements:cell];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end
