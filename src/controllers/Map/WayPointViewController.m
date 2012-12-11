//
//  WayPointViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 31/10/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "WayPointViewController.h"
#import "WayPointCellView.h"
#import "IIViewDeckController.h"
#import "GlobalUtilities.h"
#import "FMMoveTableView.h"

@interface WayPointViewController ()

@property(nonatomic,weak) IBOutlet  FMMoveTableView         *tableView;


-(IBAction)closeButtonSelected:(id)sender;

@end

@implementation WayPointViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
    
	
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	
	
}


//
/***********************************************
 * @description			VIEW METHODS
 ***********************************************/
//

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.viewDeckController.delegate=self;
	
    [self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
    
    [super viewWillAppear:animated];
}

-(BOOL)viewDeckControllerWillOpenLeftView:(IIViewDeckController *)viewDeckController animated:(BOOL)animated{
	
	BetterLog(@"");
	
	[self.tableView reloadData];
	
	return YES;
	
}


-(void)createPersistentUI{
	
	
    
}

-(void)createNonPersistentUI{
    
    
    
}


#pragma mark UITableView
//
/***********************************************
 * @description			UITABLEVIEW DELEGATES
 ***********************************************/
//

-(NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	int numberOfRows=_dataProvider.count;
	
	if ([tableView movingIndexPath] && [[tableView movingIndexPath] section] != [[tableView initialIndexPathForMovingRow] section])
	{
		if (section == [[tableView movingIndexPath] section]) {
			numberOfRows++;
		}
		else if (section == [[tableView initialIndexPathForMovingRow] section]) {
			numberOfRows--;
		}
	}
	
    return numberOfRows;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(UITableViewCell*)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	
	WayPointCellView *cell=[WayPointCellView cellForTableView:tableView fromNib:[WayPointCellView nib]];
	
	if ([_tableView indexPathIsMovingIndexPath:indexPath])
	{
		[cell prepareForMove];
	}
	else
	{
			if ([tableView movingIndexPath]) {
			indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
		}
		
		cell.waypointIndex=[indexPath row];
		cell.dataProvider=[_dataProvider objectAtIndex:[indexPath row]];
		[cell populate];
		
		[cell setShouldIndentWhileEditing:NO];
		[cell setShowsReorderControl:NO];
	}

    
    return cell;
}


- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	
	NSUInteger fromRow=[fromIndexPath row];
	NSUInteger toRow=[toIndexPath row];
	
	// store the row to move
	id object =[_dataProvider objectAtIndex:fromRow];
	
	// remove the from row & set the to row with the stored object
	[_dataProvider removeObjectAtIndex:fromRow];
	[_dataProvider insertObject:object atIndex:toRow];
	
	
	[delegate performSelector:@selector(wayPointArraywasReordered)];
	[self.tableView reloadData];
	
	
	
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	
	return proposedDestinationIndexPath;
}


//
/***********************************************
 * @description			TableView move support
 ***********************************************/
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if(editingStyle==UITableViewCellEditingStyleDelete){
		[_dataProvider removeObjectAtIndex:indexPath.row];
		[delegate performSelector:@selector(wayPointwasDeleted)];
		[self.tableView reloadData];
	}
	
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//


-(IBAction)closeButtonSelected:(id)sender{
	[self.viewDeckController closeLeftViewAnimated:YES];
}



//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning{
	
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
    self.tableView=nil;
}



@end
