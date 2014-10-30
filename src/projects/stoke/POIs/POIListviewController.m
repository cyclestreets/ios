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
#import "ViewUtilities.h"
#import "UIView+Additions.h"

static NSString *const DATAID = @"PoiListing";


@interface POIListviewController()

@property (nonatomic, strong)	IBOutlet UITableView						*tableview;
@property (nonatomic, strong)	NSMutableArray								*dataProvider;


@property (nonatomic,assign)  int											initialHeight;

@property (nonatomic,strong)  POITypeCellView								*currentSelectedCell;

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
		
		POICategoryVO *firstCategory=(POICategoryVO*)[_dataProvider firstObject];
		firstCategory.selected=YES;
		
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
	
	self.initialHeight=self.view.height;
	
	[self createPersistentUI];
    [super viewDidLoad];
}

-(void)createPersistentUI{
	
	
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

-(void)viewWillAppear:(BOOL)animated{
	
	_tableview.height=_initialHeight;
	
	[super viewWillAppear:animated];
	
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

//TBD: needs none cell added to dp

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_dataProvider count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    POITypeCellView *cell = (POITypeCellView *)[POITypeCellView cellForTableView:tv fromNib:[POITypeCellView nib]];
	
	POICategoryVO *poi = [_dataProvider objectAtIndex:[indexPath row]];
	cell.dataProvider=poi;
	[cell populate];
	
	if(poi.selected){
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
		self.currentSelectedCell=cell;
	}else{
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
    return cell;
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger rowIndex=[indexPath row];
	
	POICategoryVO *poi=_dataProvider[rowIndex];
	
	
	POITypeCellView *selectedCell=(POITypeCellView*)[_tableview cellForRowAtIndexPath:[_tableview indexPathForSelectedRow]];
	
	poi.selected=!poi.selected;
	
	if(poi.selected){
		
		if([poi.key isEqualToString:NONE]){
			
			[[POIManager sharedInstance] removeAllPOICategoryMapPoints];
			
			[self.tableview reloadData];
			
		}else{
			
			POICategoryVO *selectCellpoi=_currentSelectedCell.dataProvider;
			
			if([selectCellpoi.key isEqualToString:NONE]){
				_currentSelectedCell.accessoryType=UITableViewCellAccessoryNone;
				selectCellpoi.selected=NO;
			}
			
			
			if(![poi.key isEqualToString:NONE]){
				[[POIManager sharedInstance] requestPOICategoryMapPointsForCategory:poi withNWBounds:_nwCoordinate andSEBounds:_seCoordinate];
			}
		
		}
		
		selectedCell.accessoryType=UITableViewCellAccessoryCheckmark;
		
	}else{
		if(![poi.key isEqualToString:NONE]){
			selectedCell.accessoryType=UITableViewCellAccessoryNone;
			[[POIManager sharedInstance] removePOICategoryMapPointsForCategory:poi];
		}
		
	}
	
	[_tableview deselectRowAtIndexPath:indexPath animated:YES];
	
}




#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	[self dismissViewControllerAnimated:YES completion:nil];

}


-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,340);
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
