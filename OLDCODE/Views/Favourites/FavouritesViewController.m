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
#import "FavouritesViewController.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Files.h"
#import "RouteParser.h"
#import "Route.h"
#import "CSExceptions.h"
#import "FavouritesCell.h"
#import "RouteSummary.h"

@implementation FavouritesViewController
@synthesize favourites;
@synthesize routes;
@synthesize routeSummary;
@synthesize rowHeightsArray;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [favourites release], favourites = nil;
    [routes release], routes = nil;
    [routeSummary release], routeSummary = nil;
    [rowHeightsArray release], rowHeightsArray = nil;
	
    [super dealloc];
}



#pragma mark -
#pragma mark init

#pragma mark -
#pragma mark helpers

- (void) reload {
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	self.favourites = [cycleStreets.files favourites];
	
	[self createRowHeightsArray];
	[self.tableView reloadData];
}

- (void) clear {
	//empty out the favourites list, tell the view it needs reloaded.
	self.favourites = nil;
	[(UITableView *)self.view reloadData];
}

- (Route *) routeWithIdentifier:(NSInteger)identifier {
	Route *route = [routes objectForKey:[NSNumber numberWithInt:identifier]];
	if (!route) {
		CycleStreets *cycleStreets = [CycleStreets sharedInstance];	
		NSData *data = [cycleStreets.files route:identifier];
		if(data!=nil){
			RouteParser *parsed = [RouteParser parse:data forElements:[Route routeXMLElementNames]];
			route = [[[Route alloc] initWithElements:parsed.elementLists] autorelease];
			[routes setObject:route forKey:[NSNumber numberWithInt:identifier]];
		}
	}
	return route;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight=[FavouritesCell rowHeight];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self reload];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [self.favourites count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	 static NSString *CellIdentifier = @"FavouritesCell";
	 
	 FavouritesCell *cell = (FavouritesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	 if (cell == nil) {
		 NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FavouritesCell" owner:self options:nil];
		 cell = (FavouritesCell *)[nib objectAtIndex:0];
		 [cell initialise];
	 }
	
    
    NSInteger routeIdentifier = [[favourites objectAtIndex:indexPath.row] intValue];
	Route *route = [self routeWithIdentifier:routeIdentifier];
	cell.dataProvider=route;
	[cell populate];
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger routeIdentifier = [[favourites objectAtIndex:indexPath.row] intValue];
	Route *route = [self routeWithIdentifier:routeIdentifier];
	if (self.routeSummary == nil) {
		self.routeSummary = [[RouteSummary alloc]init];
	}
	self.routeSummary.route = route;
	[self.navigationController pushViewController:self.routeSummary animated:YES];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)deleteRow:(int)row{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	NSMutableArray *favs=[cycleStreets.files favourites];
	[favs removeObjectAtIndex:row];
	[cycleStreets.files setFavourites:favs];
	self.favourites = favs;
	[rowHeightsArray removeObjectAtIndex:row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

	[self deleteRow:indexPath.row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return [[rowHeightsArray objectAtIndex:[indexPath row]] floatValue];
}


-(void)createRowHeightsArray{

	self.rowHeightsArray=[[NSMutableArray alloc]init];

	for (int i=0; i<[favourites count]; i++) {
		
		NSInteger routeIdentifier = [[favourites objectAtIndex:i] intValue];
		Route *route = [self routeWithIdentifier:routeIdentifier];
		
		[rowHeightsArray addObject:[FavouritesCell heightForCellWithDataProvider:route]];
		
		
	}
	
	
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)nullify {
	self.favourites = nil;
	self.routes = nil;
	self.routeSummary = nil;
}

- (void)viewDidUnload {
    [self nullify];
	[super viewDidUnload];
	DLog(@">>>");
}


@end

