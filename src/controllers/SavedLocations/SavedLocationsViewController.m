//
//  SavedLocationsViewController.m
//  CycleStreets
//
//  Created by Neil Edwards on 14/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "SavedLocationsViewController.h"

#import "GenericConstants.h"

#import "SavedLocationVO.h"
#import "SavedLocationsManager.h"
#import "SavedLocationTableCellView.h"

#import <UIAlertView+BlocksKit.h>

@interface SavedLocationsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IBOutlet  UITableView									*tableView;

@property (nonatomic,strong)  NSMutableArray								*dataProvider;

@end

@implementation SavedLocationsViewController



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
	
	if(_viewMode==SavedLocationsViewModeModal)
		self.UIType=UITYPE_MODALTABLEVIEWUI;
	
	
	[self createPersistentUI];
}


-(void)viewWillAppear:(BOOL)animated{
	
	self.dataProvider=[SavedLocationsManager sharedInstance].dataProvider;
	[_tableView reloadData];
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}


-(void)createPersistentUI{
	
	self.tableView.rowHeight=[SavedLocationTableCellView rowHeight];
	[self.tableView registerNib:[SavedLocationTableCellView nib] forCellReuseIdentifier:[SavedLocationTableCellView cellIdentifier]];
	
}

-(void)createNonPersistentUI{
	
	
	if(_dataProvider.count==0){
		
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:@"noresults_SAVEDLOCATIONS" withIcon:@"SAVEDLOCATIONS"];
		
	}else{
		
		[self showViewOverlayForType:kViewOverlayTypeNone show:NO withMessage:nil];
		
	}
	
	
}


#pragma mark UITableView
//
/***********************************************
 * @description			UITABLEVIEW DELEGATES
 ***********************************************/
//

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [_dataProvider count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	SavedLocationTableCellView *cell=[_tableView dequeueReusableCellWithIdentifier:[SavedLocationTableCellView cellIdentifier] forIndexPath:indexPath];
	
	SavedLocationVO *data=[_dataProvider objectAtIndex:indexPath.row];
	
	cell.dataProvider=data;
	[cell populate];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	// depends on context
	
	SavedLocationVO *data=[_dataProvider objectAtIndex:indexPath.row];
	
	if(_viewMode==SavedLocationsViewModeDefault){
		
		[self displayLocationTitleEditingAlert:data];
		
	}else{
		
		if(_savedLocationdelegate!=nil){
			
			if([_savedLocationdelegate respondsToSelector:@selector(didSelectSaveLocation:)]){
				[_savedLocationdelegate didSelectSaveLocation:data];
				
				[self didDismissWithTouch:nil];
			}
			
		}
		
	}
	
}



#pragma mark - UITableview editing



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if(editingStyle==UITableViewCellEditingStyleDelete){
		
		SavedLocationVO *data=[_dataProvider objectAtIndex:indexPath.row];
		
		[[SavedLocationsManager sharedInstance] removeSavedLocation:data];
		[_tableView beginUpdates];
		[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		[_tableView endUpdates];
	}
	
}





//
/***********************************************
 * @description			UI EVENTS
 ***********************************************/
//

-(void)displayLocationTitleEditingAlert:(SavedLocationVO*)location{
	
	
	UIAlertView *alert=[UIAlertView bk_alertViewWithTitle:@"Rename location"];
	alert.alertViewStyle=UIAlertViewStylePlainTextInput;
	
	UITextField *namefield=[alert textFieldAtIndex:0];
	namefield.text=location.title;
	namefield.placeholder=@"Enter location name";
	namefield.clearButtonMode=UITextFieldViewModeWhileEditing;
	
	[alert bk_setCancelButtonWithTitle:CANCEL handler:^{
		[_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
	}];
	
	[alert bk_addButtonWithTitle:OK handler:^{
		
		UITextField *namefield=[alert textFieldAtIndex:0];
		if(namefield.text.length>0){
			
			location.title=namefield.text;
			[[SavedLocationsManager sharedInstance] saveLocations];
			
			[_tableView reloadRowsAtIndexPaths:@[[_tableView indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		
	}];
	
	[alert show];
	
}


#pragma mark - UI Events


-(IBAction)didSelectDoneButton:(id)sender{
	
	[self didDismissWithTouch:nil];
	
}




#pragma mark - CSOverlayTransitionProtocol

-(void)didDismissWithTouch:(UIGestureRecognizer*)gestureRecogniser{
	
	if(_savedLocationdelegate!=nil){
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	
}


-(CGSize)preferredContentSize{
	
	return CGSizeMake(280,340);
}


//
/***********************************************
 * @description			SEGUE METHODS
 ***********************************************/
//

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	
	
}


//
/***********************************************
 * @description			MEMORY
 ***********************************************/
//
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
}




@end
