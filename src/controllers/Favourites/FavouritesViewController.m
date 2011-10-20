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


#import "FavouritesViewController.h"
#import "CycleStreets.h"
#import "CycleStreetsAppDelegate.h"
#import "Files.h"
#import "RouteParser.h"
#import "Route.h"
#import "FavouritesCellView.h"
#import "RouteSummary.h"
#import "FavouritesManager.h"
#import "ViewUtilities.h"
#import "RouteManager.h"

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
	
	BetterLog(@"");
	
	self.favourites = [FavouritesManager sharedInstance].dataProvider;
	
	if(routes==nil)
		self.routes=[[NSMutableDictionary alloc]init];
	
	[self createRowHeightsArray];
	[self.tableView reloadData];
}

- (void) clear {
	self.favourites = nil;
	[(UITableView *)self.view reloadData];
}


// TODO: note due to this method of loading the routes always from disk we cant persist the routename change
// short term We need to make Routes xml writable, this restriction will be removed when we move these VOs to NScoding
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


-(void)routeByIdResponse{
	
	[self reload];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
	
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight=[FavouritesCellView rowHeight];

	UIBarButtonItem *back = [[[UIBarButtonItem alloc] initWithTitle:@"New"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(retrieveRouteByNumberButtonSelected:)]
							 autorelease];
	
	[self.navigationItem setRightBarButtonItem:back];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(routeByIdResponse)
												 name:NEWROUTEBYIDRESPONSE
											   object:nil];	
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self reload];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [favourites count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	FavouritesCellView *cell = (FavouritesCellView *)[FavouritesCellView cellForTableView:tableView fromNib:[FavouritesCellView nib]];	
    
    NSInteger routeIdentifier = [[favourites objectAtIndex:indexPath.row] intValue];
	Route *route = [self routeWithIdentifier:routeIdentifier];
	cell.dataProvider=route;
	
	
	// This is useful but, SR is always sorted to top of Favs so no real use?
	Route *sroute=[RouteManager sharedInstance].selectedRoute;
	cell.isSelectedRoute=[sroute.itinerary isEqualToString:route.itinerary];
	
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
	
	[[FavouritesManager sharedInstance] removeObjectFromDataProviderAtIndex:row];
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
	
	if(rowHeightsArray==nil){
		self.rowHeightsArray=[[NSMutableArray alloc]init];
	}else{
		[rowHeightsArray	removeAllObjects];
	}

	for (int i=0; i<[favourites count]; i++) {
		
		NSInteger routeIdentifier = [[favourites objectAtIndex:i] intValue];
		Route *route = [self routeWithIdentifier:routeIdentifier];
		
		[rowHeightsArray addObject:[FavouritesCellView heightForCellWithDataProvider:route]];
		
		
	}
	
	
}


//
/***********************************************
 * @description			User events
 ***********************************************/
//


-(IBAction)retrieveRouteByNumberButtonSelected:(id)sender{
	
	[ViewUtilities createTextEntryAlertView:@"Enter Route id" fieldText:nil delegate:self];
	
}


// Note: use of didDismissWithButtonIndex, as otherwise the HUD gets removed by the screen clear up performed by Alert 
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex > 0) {
        
		switch(alertView.tag){
			case kTextEntryAlertTag:
			{
				UITextField *alertInputField=(UITextField*)[alertView viewWithTag:kTextEntryAlertFieldTag];
				if (alertInputField!=nil && ![alertInputField.text isEqualToString:EMPTYSTRING]) {
					Query *routequery=[[Query alloc]initRouteID:alertInputField.text];
					[[RouteManager sharedInstance] runRouteIdQuery:routequery];
				}
			}
                break;
                
			default:
				
			break;
                
		}
		
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
	BetterLog(@">>>");
}


@end

