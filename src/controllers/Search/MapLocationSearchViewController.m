/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  Namefinder2.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/08/2010.
//

#import "MapLocationSearchViewController.h"

#import "CycleStreets.h"
#import "Files.h"
#import "XMLRequest.h"
#import "NamedPlace.h"
#import "GlobalUtilities.h"
#import "MapLocationSearchCellView.h"
#import "HudManager.h"

static NSString *format = @"%@?key=%@&street=%@&%@&clientid=%@";
static NSString *urlPrefix = @"http://www.cyclestreets.net/api/geocoder.xml";


@interface MapLocationSearchViewController()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@end


@implementation MapLocationSearchViewController


@synthesize centreLocation;
@synthesize currentRequestSearchString;
@synthesize searchString;
@synthesize request;
@synthesize currentPlaces;
@synthesize activeLookup;
@synthesize activeBackground;
@synthesize locationReceiver;


#pragma mark -
#pragma mark View lifecycle

- (void)activeLookupOff {
	[[HudManager sharedInstance] removeHUD];
}

- (void)activeLookupOn {
	[[HudManager sharedInstance] showHudWithType:HUDWindowTypeProgress withTitle:@"Searching..." andMessage:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	self.searchDisplayController.searchResultsTableView.rowHeight=[MapLocationSearchCellView rowHeight];
	
    self.view.backgroundColor                                  = UIColorFromRGB(0x509720);
    self.searchDisplayController.active                        = YES;
    self.searchDisplayController.searchBar.tintColor           = UIColorFromRGB(0xFFFFFF);
	self.searchDisplayController.searchBar.translucent=NO;
	self.searchDisplayController.searchBar.barTintColor			= UIColorFromRGB(0x509720);
    self.searchDisplayController.searchBar.scopeButtonTitles   = [NSArray arrayWithObjects:@"Local", @"National", nil];
    self.searchDisplayController.searchBar.showsScopeBar       = YES;
    self.searchDisplayController.searchBar.showsBookmarkButton = NO;
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSString *lastSearch = [cycleStreets.files miscValueForKey:@"lastSearch"];
	if (lastSearch != nil) {
		self.searchString = lastSearch;
		self.searchDisplayController.searchBar.text = self.searchString;
		[self lookupNames];
	}
	
	[self activeLookupOff];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self.searchDisplayController.searchBar becomeFirstResponder];
	
	if (self.searchString != nil) {
		self.searchDisplayController.searchBar.text = self.searchString;
		[self lookupNames];
	}
	
	[super viewWillAppear:animated];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.currentPlaces != nil) {
		return [self.currentPlaces count];
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	MapLocationSearchCellView *cell=[MapLocationSearchCellView cellForTableView:self.searchDisplayController.searchResultsTableView fromNib:[MapLocationSearchCellView nib]];
	
	if(indexPath.row<self.currentPlaces.count){
		cell.dataProvider=[self.currentPlaces objectAtIndex:indexPath.row];
		[cell populate];
	}
    
    return cell;
}

#pragma mark lookup code

- (void)lookupNames {
	if (self.searchString == nil || !self.searchDisplayController.active) {
		return;
	}
	self.currentRequestSearchString = self.searchString;
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.files setMiscValue:self.currentRequestSearchString forKey:@"lastSearch"];
	
	NSString *query = [self.searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	CLLocationDegrees range = 1.0;
	NSInteger zoom = 11;
	if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
		range = 0.25;
		zoom = 16;
	} else {
		range = 4.0;
		zoom = 6;
	}
	
	NSString *bounds = [NSString
						stringWithFormat:@"w=%f&n=%f&e=%f&s=%f&zoom=%ld",
						centreLocation.longitude - range, //left
						centreLocation.latitude + range, //top
						centreLocation.longitude + range, //right
						centreLocation.latitude - range, //bottom
						(long)zoom]; //zoom
	
	NSString *url = [NSString
					 stringWithFormat:format,
					 urlPrefix,
					 [cycleStreets APIKey],
					 query,
					 bounds,
					 cycleStreets.files.clientid];
	
	BetterLog(@"name lookup URL %@", url);
	
	self.request = [[XMLRequest alloc] initWithURL:url
										   delegate:self
												tag:nil
										  onSuccess:@selector(didSucceedLookup:results:)
										 onFailure:@selector(didFailLookupwithMessage:)];
	request.elementsToParse = [NSArray arrayWithObject:@"result"];
	[request start];
	[self activeLookupOn];
}

//queue a new lookup request after a short delay.
- (void)performLookup {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(lookupNames) withObject:nil afterDelay:0.2];
}

- (void)clearRequest {
	self.request = nil;
	self.currentRequestSearchString = nil;
	[self activeLookupOff];
}

//clean up any existing lookup requests.
- (void)cancelLookup {
	[self.request cancel];
	[self clearRequest];
}

- (void)didSucceedLookup:(XMLRequest *)request results:(NSDictionary *)elements {
	BetterLog(@"didSucceedLookup");
	self.request = nil;
	if (self.currentPlaces == nil) {
		self.currentPlaces = [[NSMutableArray alloc] init];
	}
	
	//# CR error 2.0.2 #25: Fixed.
	if([elements isKindOfClass:[NSDictionary class]]){
		
		[self.currentPlaces removeAllObjects];
		
		for (NSDictionary *place in [elements objectForKey:@"result"])
		{
			NamedPlace *namedPlace = [[NamedPlace alloc] initWithDictionary:place];
			[self.currentPlaces addObject:namedPlace];
		}
		
		[currentPlaces sortUsingComparator:(NSComparator)^(NamedPlace *a1, NamedPlace *a2) {
			return [a1.distanceInt compare:a2.distanceInt];
		}];
		
	}
	
	
	[self.searchDisplayController.searchResultsTableView reloadData];
	if (self.searchDisplayController.active && ![self.currentRequestSearchString isEqualToString:self.searchString]) {
		//there has been a change, so queue a subsequent search.
		[self performLookup];
	}
	[self clearRequest];
}

- (void)didFailLookupwithMessage:(NSString *)message {
	BetterLog(@"didFailLookup");
	[self clearRequest];
}



#pragma table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NamedPlace *where = [currentPlaces objectAtIndex:indexPath.row];
	if (where != nil) {
		[self.locationReceiver didMoveToLocation:where.locationCoords];
	}
	[self.searchDisplayController.searchResultsTableView  deselectRowAtIndexPath:indexPath	animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark search controller delegate / search bar delegate

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
	BetterLog(@"searchDisplayControllerDidBeginSearch clicked in the search bar");
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	BetterLog(@"searchDisplayControllerDidEndSearch");
	[self cancelLookup];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	BetterLog(@"searchBarSearchButtonClicked");
	[self performLookup];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	BetterLog(@"searchBarCancelButtonClicked");
	[self cancelLookup];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	BetterLog(@"textDidChange");
	self.searchString = searchText;
	if (self.searchString != nil && [self.searchString length] > 3) {
		[self performLookup];
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	BetterLog(@"textDidChange");
	if (self.searchString != nil && [self.searchString length] > 3) {
		[self performLookup];
	}	
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	BetterLog(@"searchDisplayController:shouldReloadTableForSearchScope:");
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	BetterLog(@"searchDisplayController:shouldReloadTableForSearchString:");
	return NO;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.locationReceiver = nil;
	self.searchString = nil;
	self.currentRequestSearchString = nil;
	self.request = nil;
	self.currentPlaces = nil;	
	self.activeLookup = nil;
	self.activeBackground = nil;
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
	BetterLog(@">>>");
}


@end

