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

//  RouteTable.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "RouteTableViewController.h"
#import "Route.h"
#import "CSExceptions.h"
#import "RouteTableCell.h"
#import "SegmentVO.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Stage.h"

#import "FavouritesViewController.h"

@implementation RouteTableViewController
@synthesize route;
@synthesize routeId;
@synthesize headerText;
@synthesize routeidLabel;
@synthesize readoutLineOne;
@synthesize readoutLineTwo;
@synthesize tableView;

//=========================================================== 
// dealloc
//=========================================================== 
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



#pragma mark -
#pragma mark View lifecycle

- (id)init {
	if (self = [super init]) {
		self.routeId = 0;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.routeId > 0) {
		//reload the current route.
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];
        FavouritesViewController *favourites = cycleStreets.appDelegate.favourites;
		Route *newRoute = [favourites routeWithIdentifier:self.routeId];
		self.route = newRoute;
	}
}

#pragma mark setters

- (void)setRoute:(Route *)newRoute {
	
	//UITableView *tableView = (UITableView *)[self view];

	Route *oldRoute = route;
	route = newRoute;
	[newRoute retain];
	[oldRoute release];
	self.routeId = [[newRoute itinerary] integerValue];
	
	//and fix the table data
	[tableView reloadData];
}

- (Route *)route {
	return route;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (route) {
		return 1;
	} else {
		return 0;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return [route numSegments];
	} else {
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RouteTableCell";
    
    RouteTableCell *cell = (RouteTableCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:tv options:nil];
		if (nib == nil) {
			[CSExceptions exception: [NSString stringWithFormat:@"Could not load nib %@. Does it exist ?", CellIdentifier]];
		}
		for (id obj in nib) {
			if ([obj isKindOfClass:[RouteTableCell class]]) {
				cell = obj;
			}
		}
    }
	
	// Configure the cell...
	SegmentVO *segment = [route segmentAtIndex:indexPath.row];
	[segment setUIElements:cell];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;//as per the nib. Hardcoded yuck!
}

#pragma mark section header

/*
- (UITextView *) headerView {
	
	static NSString *CellIdentifier = @"RouteTableHeader";
	
	UITextView *cell = nil;
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
	if (nib == nil) {
		[CSExceptions exception: [NSString stringWithFormat:@"Could not load nib %@. Does it exist ?", CellIdentifier]];
	}
	for (id obj in nib) {
		if ([obj isKindOfClass:[UITextView class]]) {
			cell = obj;
		}
	}
	return cell;
}

- (void)setupHeader {
	if (self.headerText == nil) {
		self.headerText = [self headerView];
	}
	self.headerText.text = [NSString stringWithFormat:@"%@%@%@", @"CycleStreets route #",
							[route itinerary], 
							@". Click on a section to view the map and details."];
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	[self setupHeader];
	return self.headerText;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	[self setupHeader];
	return self.headerText.bounds.size.height;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create and push stage details view controller.
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	Stage *stage = [cycleStreets.appDelegate stage];
	[stage setRoute:route];
	[self presentModalViewController:stage animated:YES];
	[stage setSegmentIndex:indexPath.row];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	[route release];
	route = nil;
	self.headerText = nil;	
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}



@end

