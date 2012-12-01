//
//  POIListviewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 20/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POIListviewController.h"
#import "POITypeCellView.h"
#import "GlobalUtilities.h"
#import "POIManager.h"
#import "NetResponse.h"
#import "ViewUtilities.h"

static NSString *const DATAID = @"PoiListing";


@interface POIListviewController()

@property (nonatomic, strong)	IBOutlet UITableView		*tableview;
@property (nonatomic, strong)	NSMutableArray								*dataProvider;



@end

@implementation POIListviewController




//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	
	[self initialise];
	
	
	[notifications addObject:POILISTINGRESPONSE];
	[notifications	addObject:REMOTEDATAREQUESTED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	if([notification.name isEqualToString:POILISTINGRESPONSE]){
		[self refreshUIFromDataProvider];
	}
	
	if([notification.name isEqualToString:REMOTEDATAREQUESTED]){
		NSDictionary	*dict=[notification userInfo];
		NetResponse		*response=[dict objectForKey:RESPONSE];
		if([response.dataid isEqualToString:DATAID]){
            [self showViewOverlayForType:kViewOverlayTypeRequestIndicator show:YES withMessage:nil];
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
	
	self.dataProvider=[POIManager sharedInstance].dataProvider;
	
	if([_dataProvider count]>0){
		[self.tableview reloadData];
		[self showViewOverlayForType:kViewOverlayTypeRequestIndicator show:NO withMessage:nil];
	}else{
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:nil];
	}
	
}

-(void)dataProviderRequestRefresh:(NSString *)source{
	
	[[POIManager sharedInstance] requestPOIListingData];
	
	// call overlay
	
}


//
/***********************************************
 * @description			View Methods
 ***********************************************/
//

- (void)viewDidLoad{
	
	UIType=UITYPE_MODALUI;
	
	[self createPersistentUI];
    [super viewDidLoad];
}

-(void)createPersistentUI{
	
	[[POIManager sharedInstance] requestPOIListingData];
	
	[self createNavigationBarUI];
	
}

-(void)createNavigationBarUI{
	
	
	CustomNavigtionBar *nav=[[CustomNavigtionBar alloc]init];
	self.navigation=nav;
	navigation.delegate=self;
	navigation.leftItemType=BUNavNoneType;
    navigation.rightItemType=UIKitButtonType;
	navigation.rightButtonTitle=@"Done";
	navigation.titleType=BUNavTitleDefaultType;
	navigation.titleString=@"Points of interest";
    navigation.titleFontColor=[UIColor whiteColor];
	navigation.navigationItem=self.navigationItem;
	[navigation createNavigationUI];
	
}

-(void)viewDidAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewDidAppear:animated];
}

-(void)createNonPersistentUI{
	
	if(_dataProvider==nil)
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
	return [_dataProvider count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    POITypeCellView *cell = (POITypeCellView *)[POITypeCellView cellForTableView:tv fromNib:[POITypeCellView nib]];
	
	POICategoryVO *poitype = [_dataProvider objectAtIndex:[indexPath row]];
	cell.dataProvider=poitype;
	[cell populate];
	
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int rowIndex=[indexPath row];
	
	POICategoryVO *vo=_dataProvider[rowIndex];
	
	[[POIManager sharedInstance] requestPOICategoryMapPointsForCategory:vo withNWBounds:_nwCoordinate andSEBounds:_seCoordinate];
	
	// map view will get the response as well as this list	
	
}

//
/***********************************************
 * @description			User Events
 ***********************************************/
//

-(void)doNavigationSelector:(NSString *)type{
	
	if([type isEqualToString:RIGHT]){
		
		[self dismissModalViewControllerAnimated:YES];
		
	}
	
	
}


//
/***********************************************
 * @description			generic methods
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


@end
