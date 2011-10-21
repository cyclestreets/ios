//
//  POICategoryViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICategoryViewController.h"
#import "GlobalUtilities.h"
#import "POICatLocationCellView.h"
#import "POILocationVO.h"
#import "POIManager.h"
#import "NetResponse.h"

static NSString *const DATAID = @"PoiCategoryLocation";

@implementation POICategoryViewController
@synthesize tableview;
@synthesize dataProvider;
@synthesize requestdataProvider;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [tableview release], tableview = nil;
    [dataProvider release], dataProvider = nil;
    [requestdataProvider release], requestdataProvider = nil;
	
    [super dealloc];
}







/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	
	[self initialise];
	[notifications addObject:POICATEGORYLOCATIONRESPONSE];
	[notifications	addObject:REMOTEDATAREQUESTED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	if([notification.name isEqualToString:POICATEGORYLOCATIONRESPONSE]){
		[self refreshUIFromDataProvider];
	}
	
	if([notification.name isEqualToString:REMOTEDATAREQUESTED]){
		NSDictionary	*dict=[notification userInfo];
		NetResponse		*response=[dict objectForKey:RESPONSE];
		if([response.dataid isEqualToString:DATAID]){
			//[navigation createRightNavItemWithType:BUNavActivityType];
            //[self showViewOverlayForType:kViewOverlayTypeRequestIndicator show:YES withMessage:nil];
		}
	}
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	self.dataProvider=[POIManager sharedInstance].categoryDataProvider;
	
	if([dataProvider count]>0){
		[self.tableview reloadData];
	}else{
		
		
	}
	
}

-(void)dataProviderRequestRefresh:(NSString *)source{
	
	CLLocationCoordinate2D location;
	location.longitude=0.012345;
	location.latitude=52.12345;
	
	
	[[POIManager sharedInstance] requestPOICategoryDataForCategory:requestdataProvider atLocation:location];
	
	// call overlay
	
}


//
/***********************************************
 * @description			View Methods
 ***********************************************/
//

- (void)viewDidLoad{
	[self createPersistentUI];
    [super viewDidLoad];
}

-(void)createNavigationBarUI{
	
	
	CustomNavigtionBar *nav=[[CustomNavigtionBar alloc]init];
	self.navigation=nav;
    [nav release];
	navigation.delegate=self;
	navigation.leftItemType=BUNavNoneType;
    navigation.rightItemType=UIKitButtonType;
	navigation.rightButtonTitle=@"Done";
	navigation.titleType=BUNavTitleDefaultType;
	navigation.titleString=requestdataProvider.name;
    navigation.titleFontColor=[UIColor whiteColor];
	navigation.navigationItem=self.navigationItem;
	[navigation createNavigationUI];
	
}

-(void)viewDidAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewDidAppear:animated];
}

-(void)createNonPersistentUI{
	
	[self dataProviderRequestRefresh:SYSTEM];
	
}


//
/***********************************************
 * @description			Tableview delagate
 ***********************************************/
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataProvider count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    POICatLocationCellView *cell = (POICatLocationCellView *)[POICatLocationCellView cellForTableView:tv fromNib:[POICatLocationCellView nib]];
	
	POILocationVO *location = [dataProvider objectAtIndex:[indexPath row]];
	cell.dataProvider=location;
	[cell populate];
	
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//POILocationVO *location = [dataProvider objectAtIndex:[indexPath row]];
	
	// send location data to map view for current marker>close modal window
	
	
}

//
/***********************************************
 * @description			User Events
 ***********************************************/
//



//
/***********************************************
 * @description			generic methods
 ***********************************************/
//
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}



@end
