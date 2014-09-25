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


#pragma mark - Daat Requests

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
	
	
	
	[_tableView reloadData];
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	_activeSearchFilter=LocationSearchFilterLocal;
	
	[_searchBar setBackgroundImage:[UIImage new]];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSString *lastSearch = [cycleStreets.files miscValueForKey:@"lastSearch"];
	if (lastSearch != nil) {
		self.searchString = lastSearch;
		_searchBar.text = self.searchString;
		[self dataProviderRequestRefresh:nil];
	}
	
	[self activeLookupOff];
	
}

-(void)createNonPersistentUI{
	
	
	
}

#pragma mark - Search UI methods


- (void)activeLookupOff {
	[[HudManager sharedInstance] removeHUD];
}

- (void)activeLookupOn {
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Searching..." andMessage:nil];
}


-(void)cancelCurrentSearchRequest{
	
	
	
}

-(void)cancelCurrentSearchUI{
	
	
	
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
	[self dismissModalViewControllerAnimated:YES];
	
}



//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	BetterLog(@"textDidChange");
	self.searchString = searchText;
	if (self.searchString != nil && [self.searchString length] > 3) {
		[self dataProviderRequestRefresh:nil];
	}
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	BetterLog(@"searchBarSearchButtonClicked");
	[self dataProviderRequestRefresh:nil];
}


- (IBAction)searchScopeChanged:(id)sender {
	
	UISegmentedControl *control=(UISegmentedControl*)sender;
	
	_activeSearchFilter=(LocationSearchFilterType)control.selectedSegmentIndex;
	
	[self dataProviderRequestRefresh:nil];
	
}

- (IBAction)didSelectCancelButton:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
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
