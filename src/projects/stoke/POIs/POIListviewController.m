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

@property (weak, nonatomic) IBOutlet UILabel								*headerLabel;
@property (nonatomic, strong)	IBOutlet UITableView						*tableview;
@property (nonatomic, strong)	NSMutableArray								*dataProvider;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@property (nonatomic,assign)  int											initialHeight;

@property (nonatomic,strong)  POITypeCellView								*currentSelectedCell;

@end

@implementation POIListviewController
@dynamic delegate;


#pragma mark - Notifications
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

#pragma mark - Data Requests

//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	if (_viewMode==POIListViewMode_Map) {
		self.dataProvider=[POIManager sharedInstance].dataProvider;
		
	}else{
		self.dataProvider=[[POIManager sharedInstance] newLeisurePOIArray];
	}
	
	
	if([_dataProvider count]>0){
		
		
		if(_selectedPOIArray==nil || _selectedPOIArray.count==0){
			
			self.selectedPOIArray=[NSMutableArray array];
			
			for(POICategoryVO *poi in _dataProvider){
				if(poi.selected)
					[_selectedPOIArray addObject:poi];
			}
			
			if(_selectedPOIArray.count==0){
				POICategoryVO *firstCategory=(POICategoryVO*)[_dataProvider firstObject];
				firstCategory.selected=YES;
			}else{
				if(_shouldRefreshSelectedData){
					[self refreshAllPOILocations];
				}
			}
			
		}else{
			
			NSArray *keys=[_selectedPOIArray valueForKey:@"key"];
			for(POICategoryVO *poi in _dataProvider){
				if([keys containsObject:poi.key]){
					poi.selected=YES;
				}
			}
			
		}
		
		
		[self.tableview reloadData];
		[self showViewOverlayForType:kViewOverlayTypeRequestIndicator show:NO withMessage:nil];
		
		
	}else{
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:nil];
	}
	
}

-(void)dataProviderRequestRefresh:(NSString *)source{
	
	[[POIManager sharedInstance] requestPOIListingData];
	
}


#pragma mark - UIView
//
/***********************************************
 * @description			View Methods
 ***********************************************/
//

- (void)viewDidLoad{
	
    [super viewDidLoad];
	
	[self createPersistentUI];
}

-(void)createPersistentUI{
	
	if(_dataProvider==nil)
		[self dataProviderRequestRefresh:SYSTEM];
	
}

-(void)viewWillAppear:(BOOL)animated{
	
	
	[super viewWillAppear:animated];
	
}

-(void)viewDidAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewDidAppear:animated];
}

-(void)createNonPersistentUI{
	
	switch (_viewMode) {
		case POIListViewMode_Leisure:
		{
			_headerLabel.text=@"Select the Points of interest to plan this route via.";
		}
		break;
			
		case POIListViewMode_Map:
		{
			_headerLabel.text=@"Select the Points of interest you'd like to use for adding locations.";
		}
		break;
	}
	
}



-(void)refreshAllPOILocations{
	
	if(_shouldRefreshSelectedData){
		
		[[POIManager sharedInstance] requestPOICategoryMapPointsForList:_selectedPOIArray withNWBounds:_nwCoordinate andSEBounds:_seCoordinate];
	}
	
	_shouldRefreshSelectedData=NO;
}


//
/***********************************************
 * @description			Tableview delagate
 ***********************************************/
//

#pragma mark -UITableview

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
	poi.selected=!poi.selected;
	
	POITypeCellView *selectedCell=(POITypeCellView*)[_tableview cellForRowAtIndexPath:[_tableview indexPathForSelectedRow]];
	
	[self didSelectTableCell:selectedCell withPOI:poi];
	
	[_tableview deselectRowAtIndexPath:indexPath animated:YES];
	
}


-(void)didSelectTableCell:(POITypeCellView*)selectedCell withPOI:(POICategoryVO*)poi{
	
	
	switch (_viewMode) {
		case POIListViewMode_Map:
		{
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
		}
		break;
			
		case POIListViewMode_Leisure:
		{
			if(poi.selected){
				
				if([poi.key isEqualToString:NONE]){
					
					for(POICategoryVO *poi in _dataProvider){
						poi.selected=NO;
					}
					poi.selected=YES;
					
					[_selectedPOIArray removeAllObjects];
					
					[self.tableview reloadData];
					
				}else{
					
					POICategoryVO *selectCellpoi=_currentSelectedCell.dataProvider;
					
					if([selectCellpoi.key isEqualToString:NONE]){
						_currentSelectedCell.accessoryType=UITableViewCellAccessoryNone;
						selectCellpoi.selected=NO;
					}
					
					
					if(![poi.key isEqualToString:NONE]){
						[_selectedPOIArray addObject:poi];
					}
					
				}
				
				selectedCell.accessoryType=UITableViewCellAccessoryCheckmark;
				
			}else{
				if(![poi.key isEqualToString:NONE]){
					selectedCell.accessoryType=UITableViewCellAccessoryNone;
					
					NSUInteger index=NSNotFound;
					index=[_selectedPOIArray indexOfObjectPassingTest:^BOOL(POICategoryVO *obj, NSUInteger idx, BOOL *stop) {
						
						if([obj.key isEqualToString:poi.key]){
							*stop=YES;
							return YES;
						}
						return NO;
					}];
					
					if(index!=NSNotFound)
						[_selectedPOIArray removeObjectAtIndex:index];
				}
				
			}
			
			if([self.delegate respondsToSelector:@selector(didUpdateSelectedPOIs:)]){
				[self.delegate didUpdateSelectedPOIs:_selectedPOIArray];
			}
			
		}
		break;
			
	}
	
}



#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	[self dismissViewControllerAnimated:YES completion:nil];

}


-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,350);
}

-(CGRect)presentationContentFrame{
	return self.frame;
}


#pragma mark - UI Events


-(IBAction)didSelectDoneButton:(id)sender{
	
	[self didDismissWithTouch:nil];
	
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
