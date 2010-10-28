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

#import "RouteTable.h"
#import "Route.h"
#import "CSExceptions.h"
#import "RouteTableCell.h"
#import "Segment.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Stage.h"
#import "Common.h"
#import "Favourites.h"

@implementation RouteTable

@synthesize headerText;
@synthesize routeId;

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
		CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
		Favourites *favourites = cycleStreets.appDelegate.favourites;
		Route *newRoute = [favourites routeWithIdentifier:self.routeId];
		self.route = newRoute;
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark setters

- (void)setRoute:(Route *)newRoute {
	
	UITableView *tableView = (UITableView *)[self view];

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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RouteTableCell";
    
    RouteTableCell *cell = (RouteTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:tableView options:nil];
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
	Segment *segment = [route segmentAtIndex:indexPath.row];
	[segment setUIElements:cell];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;//as per the nib. Hardcoded yuck!
}

#pragma mark section header

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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create and push stage details view controller.
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	Stage *stage = [cycleStreets.appDelegate stage];
	[stage setRoute:route];
	[self presentModalViewController:stage animated:YES];
	[stage setSegmentIndex:indexPath.row];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)nullify {
	[route release];
	route = nil;
	self.headerText = nil;	
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end

