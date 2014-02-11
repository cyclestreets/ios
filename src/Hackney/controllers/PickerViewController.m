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
#import "HCSTrackConfigViewController.h"
#import "CustomPickerDataSource.h"
#import "UserSettingsManager.h"


@interface PickerViewController()<UIPickerViewDelegate>


@property (nonatomic, retain) IBOutlet UIPickerView							*customPickerView;
@property (nonatomic, retain) CustomPickerDataSource						*customPickerDataSource;

@property (nonatomic, retain) IBOutlet UITextView							*descriptionText;

@property (nonatomic,assign)  NSInteger										pickerCategory;


@end


@implementation PickerViewController



- (void)viewDidLoad{
	
	[super viewDidLoad];
	
	self.navigationController.navigationBarHidden=YES;
	self.modalPresentationCapturesStatusBarAppearance=NO;
	self.navigationController.view.backgroundColor=[UINavigationBar appearance].barTintColor;
	
	[self createCustomPicker];
	
	_pickerCategory=[[[UserSettingsManager sharedInstance] fetchObjectforKey:@"pickerCategory" forType:kSTATEUSERCONTROLLEDSETTINGSKEY] integerValue];
	[self pickerView:_customPickerView didSelectRow:_pickerCategory inComponent:0];
	[_customPickerView selectRow:_pickerCategory inComponent:0 animated:NO];
    
    
}




- (void)createCustomPicker{
	
	self.customPickerDataSource = [[CustomPickerDataSource alloc] init];
	_customPickerDataSource.parent = self;
	_customPickerView.dataSource = _customPickerDataSource;
	_customPickerView.delegate = _customPickerDataSource;

	_customPickerView.showsSelectionIndicator = YES;
	
}


- (IBAction)cancel:(id)sender{
	
	[_delegate didCancelSaveJourneyController];
}


- (IBAction)save:(id)sender{
	
    [[UserSettingsManager sharedInstance] saveObject:@(_pickerCategory) forType:kSTATEUSERCONTROLLEDSETTINGSKEY forKey:@"pickerCategory"];
    
	TripDetailViewController *tripDetailViewController = [[TripDetailViewController alloc] initWithNibName:@"TripDetailViewController" bundle:nil];
	tripDetailViewController.delegate = self.delegate;
	
	[[TripManager sharedInstance] setPurpose:_pickerCategory];
	
	[self.navigationController pushViewController:tripDetailViewController animated:YES];
		
    
}







#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
	
    _pickerCategory = row;
    
	switch (row) {
		case 0:
			_descriptionText.text = kDescCommute;
			break;
		case 1:
			_descriptionText.text = kDescSchool;
			break;
		case 2:
			_descriptionText.text = kDescWork;
			break;
		case 3:
			_descriptionText.text = kDescExercise;
			break;
		case 4:
			_descriptionText.text = kDescSocial;
			break;
		case 5:
			_descriptionText.text = kDescShopping;
			break;
		case 6:
			_descriptionText.text = kDescErrand;
			break;
		default:
			_descriptionText.text = kDescOther;
			break;
	}

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

