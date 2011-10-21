//
//  POICategoryViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 21/10/2011.
//  Copyright (c) 2011 CycleStreets Ltd. All rights reserved.
//

#import "POICategoryViewController.h"
#import "GlobalUtilities.h"
#import "POICatLocationCellView.h"
#import "POILocationVO.h"

@implementation POICategoryViewController
@synthesize tableview;
@synthesize dataProvider;
@synthesize requestdataProvider;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [tableview release], tableview = nil;
    [dataProvider release], dataProvider = nil;
    [requestdataProvider release], requestdataProvider = nil;
	
    [super dealloc];
}







/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	
	[self initialise];
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	BetterLog(@"");
	
	
	
}


//
/***********************************************
 * @description			View Methods
 ***********************************************/
//

- (void)viewDidLoad{
	[self createPersistentUI];
    [super viewDidLoad];
}

-(void)createPersistentUI{
	
	
	[self createNavigationBarUI];
	
}

-(void)viewDidAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewDidAppear:animated];
}

-(void)createNonPersistentUI{
	
	
	
}


//
/***********************************************
 * @description			Tableview delagate
 ***********************************************/
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataProvider count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    POICatLocationCellView *cell = (POICatLocationCellView *)[POICatLocationCellView cellForTableView:tv fromNib:[POICatLocationCellView nib]];
	
	POILocationVO *location = [dataProvider objectAtIndex:[indexPath row]];
	cell.dataProvider=location;
	[cell populate];
	
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//POILocationVO *location = [dataProvider objectAtIndex:[indexPath row]];
	
	// send location data to map view for current marker>close modal window
	
	
}

//
/***********************************************
 * @description			User Events
 ***********************************************/
//



//
/***********************************************
 * @description			generic methods
 ***********************************************/
//
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}



@end
