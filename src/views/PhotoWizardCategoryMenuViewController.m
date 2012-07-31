//
//  PhotoWizardCategoryMenuViewController.m
//  CycleStreets
//
//  Created by neil on 03/07/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardCategoryMenuViewController.h"
#import "PhotoCategoryVO.h"
#import "PhotoWizardCategoryCellView.h"
#import "StyleManager.h"

@implementation PhotoWizardCategoryMenuViewController
@synthesize dataType;
@synthesize tableView;
@synthesize dataProvider;
@synthesize selectedIndexPath;
@synthesize selectedItem;
@synthesize uploadImage;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = self.view.frame.size;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	tableView.rowHeight=[PhotoWizardCategoryCellView rowHeight];
	
}

-(void)viewWillAppear:(BOOL)animated{
	
	PhotoCategoryVO *lookupitem=nil;
	
	// get correct vo to look for if set
	switch(dataType){
			
		case PhotoCategoryTypeCategory:
			lookupitem=uploadImage.category;
		break;
			
		case PhotoCategoryTypeFeature:
			lookupitem=uploadImage.feature;
		break;
	}
	
	if(lookupitem!=nil){
		
		// find index of this vo in dataProvider and set si if found
		int index=[dataProvider indexOfObject:lookupitem];
		
		if(index!=NSNotFound){
			self.selectedIndexPath=[NSIndexPath indexPathForRow:index inSection:0];
		}
	}
	
	
	[super viewWillAppear:animated];
}




//
/***********************************************
 * @description		UITABLEVIEW DELEGATE METHODS
 ***********************************************/
//

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataProvider count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoWizardCategoryCellView *cell=[PhotoWizardCategoryCellView cellForTableView:tv fromNib:[PhotoWizardCategoryCellView nib]];
	
	PhotoCategoryVO *dp = (PhotoCategoryVO*)[dataProvider objectAtIndex:[indexPath row]];
	cell.dataProvider=dp;
	[cell populate];
	
	if(selectedIndexPath!=nil){
		if([indexPath row]==[selectedIndexPath row]){
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
			cell.itemLabel.textColor=[[StyleManager sharedInstance] colorForType:@"darkgreen"];
		}else{
			cell.accessoryType=UITableViewCellAccessoryNone;
			cell.itemLabel.textColor=[[StyleManager sharedInstance] colorForType:@"darkgrey"];
		}
	}else{
		cell.accessoryType=UITableViewCellAccessoryNone;
		cell.itemLabel.textColor=[[StyleManager sharedInstance] colorForType:@"verydarkgrey"];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tbv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	PhotoCategoryVO *dp = (PhotoCategoryVO*)[dataProvider objectAtIndex:[indexPath row]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PHOTOWIZARDCATEGORYUPDATE object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:dp,@"dataProvider",[NSNumber numberWithInt:dataType],@"dataType", nil]];
	
	
}

@end
