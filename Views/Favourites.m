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

//  Favourites.m
//  CycleStreets
//
//  Created by Alan Paxton on 09/03/2010.
//

#import "Common.h"
#import "Favourites.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Files.h"
#import "RouteParser.h"
#import "Route.h"
#import "CSExceptions.h"
#import "FavouritesCell.h"
#import "RouteSummary.h"

@implementation Favourites

@synthesize favourites;
@synthesize routes;
@synthesize routeSummary;

#pragma mark -
#pragma mark init

#pragma mark -
#pragma mark helpers

- (void) reload {
	self.favourites = nil;
	if (self.routes == nil) {
		self.routes = [[[NSMutableDictionary alloc] init] autorelease];
	}
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	NSArray *oldFavourites = [cycleStreets.files favourites];
	self.favourites = [[[NSMutableArray alloc] initWithCapacity:[oldFavourites count] + 1] autorelease];
	[self.favourites addObjectsFromArray:oldFavourites];
}

- (void) clear {
	//empty out the favourites list, tell the view it needs reloaded.
	self.favourites = nil;
	[(UITableView *)self.view reloadData];
}

- (Route *) routeWithIdentifier:(NSInteger)identifier {
	Route *route = [routes objectForKey:[NSNumber numberWithInt:identifier]];
	if (!route) {
		CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];	
		NSData *data = [cycleStreets.files route:identifier];
		RouteParser *parsed = [RouteParser parse:data forElements:[Route routeXMLElementNames]];
		route = [[[Route alloc] initWithElements:parsed.elementLists] autorelease];
		[routes setObject:route forKey:[NSNumber numberWithInt:identifier]];
	}
	return route;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight=70;

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	[self reload];
	return [self.favourites count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FavouritesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:tableView options:nil];
		if (nib == nil) {
			[CSExceptions exception: [NSString stringWithFormat:@"Could not load nib %@. Does it exist ?", CellIdentifier]];
		}
		for (id obj in nib) {
			if ([obj isKindOfClass:[FavouritesCell class]]) {
				cell = obj;
			}
		}
    }
	
    
    // Configure the cell...
	NSInteger routeIdentifier = [[favourites objectAtIndex:indexPath.row] intValue];
	Route *route = [self routeWithIdentifier:routeIdentifier];
	[route setUIElements:cell];
    
    return cell;
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
	NSNumber *routeIdentifier = [NSNumber numberWithInt:[[favourites objectAtIndex:indexPath.row] intValue]];
	Route *route = [routes objectForKey:routeIdentifier];
	if (self.routeSummary == nil) {
		self.routeSummary = [[[RouteSummary alloc] initWithRoute:route] autorelease];
	}
	self.routeSummary.route = route;
	[self.navigationController pushViewController:self.routeSummary animated:YES];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)deleteRow:(int)row
{
	CycleStreets *cycleStreets = (CycleStreets *)[CycleStreets sharedInstance:[CycleStreets class]];
	
	//load favourites, and add the new route to the favourites, as the first one.
	//do this even if we have it already, so last-selected favourite is "top"
	NSMutableArray *favs = [NSMutableArray arrayWithArray:[cycleStreets.files favourites]];
	[favs removeObjectAtIndex:row];
	[cycleStreets.files setFavourites:favs];
	[self reload];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"commit");
	[self deleteRow:indexPath.row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.favourites = nil;
	self.routes = nil;
	self.routeSummary = nil;
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

