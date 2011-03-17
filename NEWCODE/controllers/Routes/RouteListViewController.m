    //
//  RouteListViewController.m
//  CycleStreets
//
//  Created by neil on 12/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteListViewController.h"
#import "RouteCellView.h"

@implementation RouteListViewController
@synthesize isSectioned;
@synthesize keys;
@synthesize dataProvider;
@synthesize tableDataProvider;
@synthesize tableEditMode;
@synthesize selectedCellDictionary;
@synthesize selectedCount;
@synthesize deleteButton;
@synthesize tableView;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [keys release], keys = nil;
    [dataProvider release], dataProvider = nil;
    [tableDataProvider release], tableDataProvider = nil;
    [selectedCellDictionary release], selectedCellDictionary = nil;
    [deleteButton release], deleteButton = nil;
    [tableView release], tableView = nil;
	
    [super dealloc];
}


//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	
}


-(void)createPersistentUI{
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	
}


//
/***********************************************
 * @description		TABLEVIEW DELEGATE METHODS
 ***********************************************/
//

#pragma mark UITableView delegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(isSectioned==YES){
		return [keys count];
	}else {
		return 1;
	}

}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(isSectioned==YES){
		NSString *key=[keys objectAtIndex:section];
		NSArray *dataProviderKeyArray=[tableDataProvider objectForKey:key];
	
		return [dataProviderKeyArray count];
	}else {
		return [dataProvider count];
	}

}



- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	static NSString *CellIdentifier = @"RouteCellIdentifier";
    
    RouteCellView *cell = (RouteCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RouteCellView" owner:self options:nil];
		cell = (RouteCellView *)[nib objectAtIndex:0];
		[cell initialise];
    }
	
	if(isSectioned==YES){
	
		NSString *key=[keys objectAtIndex:[indexPath section]];
		NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
	
		cell.dataProvider=[sectionDataProvider objectAtIndex:[indexPath row]];
		
	}else {
		cell.dataProvider=[dataProvider objectAtIndex:[indexPath row]];
	}

	[cell populate];
	
    return cell;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	
	NSString *key=[keys objectAtIndex:section];
	return [sectionHeaderViews objectForKey:key];
}
*/


// NE: will we support multi cell deletion or just the standard one at a time
- (void)tableView:(UITableView *)tbv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (tableEditMode==YES){
		return;
	}else {
		
		// load route into map
		
	}

}



//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//
//
/***********************************************
 * @description			Multi edit Cell support
 ***********************************************/
//


-(void)toggleTableEditing{
	
	BOOL newstate = !tableEditMode;
	[self setTableEditingState:newstate];
}


-(void)setTableEditingState:(BOOL)state{
	
	tableEditMode=state;
	
	[tableView reloadData];
	
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)deleteRow:(int)row{
	
	// delete row dataProvider from appropriate model
	
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[self deleteRow:indexPath.row];
	[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}



- (void)updateDeleteButtonState{
	deleteButton.enabled=selectedCount>0;
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
