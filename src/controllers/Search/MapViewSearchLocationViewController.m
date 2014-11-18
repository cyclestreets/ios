//
//  MapLocationSearchViewContoller.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/09/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "MapViewSearchLocationViewController.h"

#import "AppConstants.h"
#import "LocationSearchVO.h"
#import "GlobalUtilities.h"
#import "MapLocationSearchCellView.h"
#import "HudManager.h"
#import "Files.h"
#import "CycleStreets.h"
#import "LocationSearchManager.h"
#import "StringUtilities.h"

@interface MapViewSearchLocationViewController()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic,strong)  NSMutableArray									*dataProvider;
@property (weak, nonatomic) IBOutlet UISearchBar								*searchBar;
@property (weak, nonatomic) IBOutlet UIButton									*cancelButton;
@property (weak, nonatomic) IBOutlet UITableView								*tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl							*searchScopeControl;

@property (nonatomic,assign)  LocationSearchFilterType							activeSearchFilter;

@property (nonatomic,strong)  NSString											*searchString; // string in search bar
@property (nonatomic,strong)  NSString											*currentRequestSearchString; // string currently being searched for


@end

@implementation MapViewSearchLocationViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[notifications addObject:LOCATIONSEARCHRESPONSE];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	NSString *name=notification.name;
	
	if([name isEqualToString:LOCATIONSEARCHRESPONSE]){
		
		[self didReceiveDataProviderUpdate:notification];
	}
	
	
}


#pragma mark - Data Requests

-(void)queueDataRequest{
	
	BOOL isValidString=[self validateSearchRequest:_searchString];
	if(isValidString){
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(dataProviderRequestRefresh:) withObject:nil afterDelay:0.4];
		
	}else{
		
		
		
	}

}

-(void)dataProviderRequestRefresh:(NSString *)source{
	
	if(_searchString==nil)
		return;
	
	[[LocationSearchManager sharedInstance] searchForLocation:_searchString withFilter:_activeSearchFilter forRequestType:LocationSearchRequestTypeMap atLocation:_centreLocation];
}


-(void)didReceiveDataProviderUpdate:(NSNotification*)notification{
	
	self.dataProvider=notification.object;
	
	[self refreshUIFromDataProvider];
	
}


-(void)refreshUIFromDataProvider{
	
	if(_dataProvider.count==0 || _dataProvider==nil){
		
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:@"noresults_LocationSearch" withIcon:@"Icon_nosearchresults"];
		
	}else{
		
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:NO withMessage:nil withIcon:nil];
		
		[_tableView reloadData];
	}
	
	
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.frame=_tableView.frame;
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	_activeSearchFilter=LocationSearchFilterLocal;
	
	[_searchBar setBackgroundImage:[UIImage new]];
	
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

-(void)createNonPersistentUI{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSString *lastSearch = [cycleStreets.files miscValueForKey:@"lastSearch"];
	if (lastSearch != nil) {
		self.searchString = lastSearch;
		_searchBar.text = self.searchString;
		[self queueDataRequest];
	}
	
}



#pragma mark UITableView
//
/***********************************************
 * @description			UITABLEVIEW DELEGATES
 ***********************************************/
//

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return [_dataProvider count];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	
	return 1;
	
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	MapLocationSearchCellView *cell=[MapLocationSearchCellView cellForTableView:tableView fromNib:[MapLocationSearchCellView nib]];
	
	if(indexPath.row<_dataProvider.count){
		cell.dataProvider=[_dataProvider objectAtIndex:indexPath.row];
		[cell populate];
	}
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	LocationSearchVO *where = [_dataProvider objectAtIndex:indexPath.row];
	if (where != nil) {
		[self.locationReceiver didMoveToLocation:where.locationCoords];
	}
	
	[self closeController];
	
}


#pragma mark - String validation




-(BOOL)validateSearchRequest:(NSString*)str{
	
	BOOL valid=YES;
	
	return [StringUtilities validateQueryString:str];
	
	return valid;
	
}




//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
	
	if (searchText != nil && [searchText length] > 3) {
		
			self.searchString = searchText;
			[self queueDataRequest];
	}
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	[self queueDataRequest];
}


- (IBAction)searchScopeChanged:(id)sender {
	
	UISegmentedControl *control=(UISegmentedControl*)sender;
	
	_activeSearchFilter=(LocationSearchFilterType)control.selectedSegmentIndex;
	
	[self queueDataRequest];
	
}

- (IBAction)didSelectCancelButton:(id)sender {
	
	[self closeController];
	
}


-(void)closeController{
	
	[_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
	
	[self dismissModalViewControllerAnimated:YES];
	
}


//
/***********************************************
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	
	
}


//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
}

@end
