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
#import "Common.h"
#import "CycleStreets.h"
#import "Files.h"
#import "XMLRequest.h"
#import "NamedPlace.h"
#import "GlobalUtilities.h"

static NSString *format = @"%@?key=%@&street=%@&%@&clientid=%@";
static NSString *urlPrefix = @"http://www.cyclestreets.net/api/geocoder.xml";

@implementation MapLocationSearchViewController

@synthesize locationReceiver;
@synthesize centreLocation;
@synthesize searchString;
@synthesize currentRequestSearchString;
@synthesize request;
@synthesize currentPlaces;
@synthesize activeLookup;
@synthesize activeBackground;

#pragma mark -
#pragma mark View lifecycle

- (void)activeLookupOff {
	DLog(@">>>");
	self.activeBackground.hidden = YES;
	[self.activeLookup stopAnimating];
	[self.activeBackground removeFromSuperview];
}

- (void)activeLookupOn {
	DLog(@">>>");
	self.activeBackground.hidden = NO;
	[self.activeLookup startAnimating];
	[self.view addSubview:self.activeBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor=[UIColor whiteColor];
	self.searchDisplayController.active = YES;
	self.searchDisplayController.searchBar.tintColor=UIColorFromRGB(0x008000);
	self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Local", @"National", nil];
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSString *lastSearch = [cycleStreets.files miscValueForKey:@"lastSearch"];
	if (lastSearch != nil) {
		self.searchString = lastSearch;
		self.searchDisplayController.searchBar.text = self.searchString;
		[self lookupNames];
	}
	
	
	self.activeLookup=[[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(20, 20, 40, 40)] autorelease];
	self.activeLookup.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
	
	self.activeBackground = [[[UIView alloc] initWithFrame:CGRectMake(120, 120, 80, 80)] autorelease];
	self.activeBackground.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
	[activeBackground addSubview:self.activeLookup];
	
	[self activeLookupOff];
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
    
    static NSString *CellIdentifier = @"Namefinder2Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
	cell.textLabel.text = [[self.currentPlaces objectAtIndex:indexPath.row] name];
    
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
						stringWithFormat:@"w=%f&n=%f&e=%f&s=%f&zoom=%d",
						centreLocation.longitude - range, //left
						centreLocation.latitude + range, //top
						centreLocation.longitude + range, //right
						centreLocation.latitude - range, //bottom
						zoom]; //zoom
	
	NSString *url = [NSString
					 stringWithFormat:format,
					 urlPrefix,
					 [cycleStreets APIKey],
					 query,
					 bounds,
					 cycleStreets.files.clientid];
	
	DLog(@"name lookup URL %@", url);
	
	self.request = [[[XMLRequest alloc] initWithURL:url
										   delegate:self
												tag:nil
										  onSuccess:@selector(didSucceedLookup:results:)
										  onFailure:@selector(didFailLookup:withMessage:)]
					autorelease];
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
	DLog(@"didSucceedLookup");
	self.request = nil;
	if (self.currentPlaces == nil) {
		self.currentPlaces = [[[NSMutableArray alloc] init] autorelease];
	}
	[self.currentPlaces removeAllObjects];
	for (NSDictionary *place in [elements objectForKey:@"result"])
	{
		NamedPlace *namedPlace = [[NamedPlace alloc] initWithDictionary:place];
		[self.currentPlaces addObject:namedPlace];
		[namedPlace release];
	}
	[self.searchDisplayController.searchResultsTableView reloadData];
	if (self.searchDisplayController.active && ![self.currentRequestSearchString isEqualToString:self.searchString]) {
		//there has been a change, so queue a subsequent search.
		[self performLookup];
	}
	[self clearRequest];
}

- (void)didFailLookup:(XMLRequest *)request withMessage:(NSString *)message {
	DLog(@"didFailLookup");
	[self clearRequest];
}

#pragma mark view

- (void)viewWillAppear:(BOOL)animated {
	DLog(@">>>");
	[self.searchDisplayController.searchBar becomeFirstResponder];
}

#pragma table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"tableView:didSelectRowAtIndexPath:");
	NamedPlace *where = [currentPlaces objectAtIndex:indexPath.row];
	if (where != nil) {
		[self.locationReceiver didMoveToLocation:where.locationCoords];
	}
	[tableView deselectRowAtIndexPath:indexPath	animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark search controller delegate / search bar delegate

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
	DLog(@"searchDisplayControllerDidBeginSearch clicked in the search bar");
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	DLog(@"searchDisplayControllerDidEndSearch");
	[self cancelLookup];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DLog(@"searchBarSearchButtonClicked");
	[self performLookup];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	DLog(@"searchBarCancelButtonClicked");
	[self cancelLookup];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	DLog(@"textDidChange");
	self.searchString = searchText;
	if (self.searchString != nil && [self.searchString length] > 3) {
		[self performLookup];
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	DLog(@"textDidChange");
	if (self.searchString != nil && [self.searchString length] > 3) {
		[self performLookup];
	}	
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	DLog(@"searchDisplayController:shouldReloadTableForSearchScope:");
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	DLog(@"searchDisplayController:shouldReloadTableForSearchString:");
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
	DLog(@">>>");
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end

