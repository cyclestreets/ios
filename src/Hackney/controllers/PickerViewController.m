/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//	PickerViewController.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "CustomView.h"
#import "PickerViewController.h"
#import "DetailViewController.h"
#import "TripDetailViewController.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "HCSTrackConfigViewController.h"


@implementation PickerViewController

@synthesize customPickerView, customPickerDataSource, delegate, description;
@synthesize descriptionText;


// return the picker frame based on its size
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	
	// layout at bottom of page
	/*
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
									screenRect.size.height - 84.0 - size.height,
									size.width,
									size.height);
	 */
	
	// layout at top of page
	//CGRect pickerRect = CGRectMake(	0.0, 0.0, size.width, size.height );	
	
	// layout at top of page, leaving room for translucent nav bar
	//CGRect pickerRect = CGRectMake(	0.0, 43.0, size.width, size.height );
	
	CGRect pickerRect = CGRectMake(	0.0, 78.0, size.width, size.height );	
	return pickerRect;
}


- (void)createCustomPicker
{
//	self.customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
//	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	
//	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerDataSource.parent = self;
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
//	
//	// note we are using CGRectZero for the dimensions of our picker view,
//	// this is because picker views have a built in optimum size,
//	// you just need to set the correct origin in your view.
//	//
//	// position the picker at the bottom
//	CGSize pickerSize = [customPickerView sizeThatFits:CGSizeZero];
//	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
//	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	//customPickerView.hidden = YES;
	//[self.view addSubview:customPickerView];
}


- (IBAction)cancel:(id)sender
//add value to be sent in
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[delegate didCancelSaveJourneyController];
}


- (IBAction)save:(id)sender
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        NSLog(@"Purpose Save button pressed");
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        TripDetailViewController *tripDetailViewController = [[TripDetailViewController alloc] initWithNibName:@"TripDetailViewController" bundle:nil];
        tripDetailViewController.delegate = self.delegate;
        
        [self.navigationController pushViewController:tripDetailViewController animated:YES];
        
        [delegate didPickPurpose:row];
    }
    else if (pickerCategory == 1){
        NSLog(@"Issue Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        //[self dismissModalViewControllerAnimated:YES];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentModalViewController:detailViewController animated:YES];
        //Note: get index of picker
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:row forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %d", pickedNotedType);
    }
    else if (pickerCategory == 2){
        NSLog(@"Asset Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentModalViewController:detailViewController animated:YES];
        //do something here: get index for later use.
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:row+6 forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %d", pickedNotedType);
        
    }
    else if (pickerCategory == 3){
        NSLog(@"Note This Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentModalViewController:detailViewController animated:YES];
        
        
        //Note: get index of type
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        NSNumber *tempType = 0;

        
        if(row>=7){
            tempType = [NSNumber numberWithInt:row-7];
        }
        else if (row<=5){
            tempType = [NSNumber numberWithInt:11-row];
        }
        
        NSLog(@"tempType: %d", [tempType intValue]);
        
        [delegate didPickNoteType:tempType];
    }	
}


//- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
//{
//	NSLog(@"initWithNibNamed");
//	if (self = [super initWithNibName:nibName bundle:nibBundle])
//	{
//		//NSLog(@"PickerViewController init");		
//		[self createCustomPicker];
//        
//		
//        
//		
//	}
//	return self;
//}


- (id)initWithPurpose:(NSInteger)index
{
	if (self = [self init])
	{
		//NSLog(@"PickerViewController initWithPurpose: %d", index);
		
		self.navigationController.hidesBottomBarWhenPushed=YES;
		
		// update the picker
		[customPickerView selectRow:index inComponent:0 animated:YES];
		
		pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        if (pickerCategory == 0) {
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        else if (pickerCategory == 3){
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:6 inComponent:0];
        }
	}
	return self;
}


- (void)viewDidLoad
{
	self.navigationController.navigationBarHidden=YES;
	self.modalPresentationCapturesStatusBarAppearance=NO;
	
	[self createCustomPicker];
	pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
	if (pickerCategory == 0) {
		// picker defaults to top-most item => update the description
		[self pickerView:customPickerView didSelectRow:0 inComponent:0];
	}
	else if (pickerCategory == 3){
		// picker defaults to top-most item => update the description
		[self pickerView:customPickerView didSelectRow:6 inComponent:0];
	}
	
	
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        navBarItself.topItem.title = @"Trip Purpose";
        self.descriptionText.text = @"Please select your trip purpose & tap Save";
    }
    else if (pickerCategory == 1){
        navBarItself.topItem.title = @"Boo this...";
        self.descriptionText.text = @"Please select the issue type & tap Save";
    }
    else if (pickerCategory == 2){
        navBarItself.topItem.title = @"This is rad!";
        self.descriptionText.text = @"Please select the asset type & tap Save";
    }
    else if (pickerCategory == 3){
        navBarItself.topItem.title = @"Note This";
        self.descriptionText.text = @"Please select the type & tap Save";
        [self.customPickerView selectRow:6 inComponent:0 animated:NO];
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }

	[super viewDidLoad];
    
	
}


// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerCategory == 3){
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }
	//NSLog(@"parent didSelectRow: %d inComponent:%d", row, component);
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        switch (row) {
            case 0:
                description.text = kDescCommute;
                break;
            case 1:
                description.text = kDescSchool;
                break;
            case 2:
                description.text = kDescWork;
                break;
            case 3:
                description.text = kDescExercise;
                break;
            case 4:
                description.text = kDescSocial;
                break;
            case 5:
                description.text = kDescShopping;
                break;
            case 6:
                description.text = kDescErrand;
                break;
            default:
                description.text = kDescOther;
                break;
        }
    }

    else if (pickerCategory == 1){
        switch (row) {
            case 0:
                description.text = kIssueDescPavementIssue;
                break;
            case 1:
                description.text = kIssueDescTrafficSignal;
                break;
            case 2:
                description.text = kIssueDescEnforcement;
                break;
            case 3:
                description.text = kIssueDescNeedParking;
                break;
            case 4:
                description.text = kIssueDescBikeLaneIssue;
                break;
            default:
                description.text = kIssueDescNoteThisSpot;
                break;
        }
    }
    else if (pickerCategory == 2){
        switch (row) {
            case 0:
                description.text = kAssetDescBikeParking;
                break;
            case 1:
                description.text = kAssetDescBikeShops;
                break;
            case 2:
                description.text = kAssetDescPublicRestrooms;
                break;
            case 3:
                description.text = kAssetDescSecretPassage;
                break;
            case 4:
                description.text = kAssetDescWaterFountains;
                break;
            default:
                description.text = kAssetDescNoteThisSpot;
                break;
        }
    }
    else if (pickerCategory == 3){
        switch (row) {
            case 6:
                description.text = kDescNoteThis;
                break;
                
            case 0:
                description.text = kAssetDescNoteThisSpot;
                break;
            case 1:
                description.text = kAssetDescWaterFountains;
                break;
            case 2:
                description.text = kAssetDescSecretPassage;
                break;
            case 3:
                description.text = kAssetDescPublicRestrooms;
                break;
            case 4:
                description.text = kAssetDescBikeShops;
                break;
            case 5:
                description.text = kAssetDescBikeParking;
                break;
        
            
            
            case 7:
                description.text = kIssueDescPavementIssue;
                break;
            case 8:
                description.text = kIssueDescTrafficSignal;
                break;
            case 9:
                description.text = kIssueDescEnforcement;
                break;
            case 10:
                description.text = kIssueDescNeedParking;
                break;
            case 11:
                description.text = kIssueDescBikeLaneIssue;
                break;
            case 12:
                description.text = kIssueDescNoteThisSpot;
                break;

        }
    }
}



- (void)dealloc
{
    self.delegate = nil;
    self.customPickerView = nil;
	self.customPickerDataSource = nil;
    self.description = nil;
    self.descriptionText = nil;
    
}

@end

