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

//  PhotoInfo.m
//  CycleStreets
//
//  Created by Alan Paxton on 21/06/2010.
//

#import "PhotoInfo.h"
#import "XMLRequest.h"

#import "Categories.h"
#import "CycleStreets.h"
#import "Files.h"
#import "CategoryLoader.h"
#import "GlobalUtilities.h"

@interface PhotoInfo ()

@end

@implementation PhotoInfo
@synthesize categoryPicker;
@synthesize doneButton;
@synthesize cancelButton;
@synthesize typeLabel;
@synthesize descLabel;
@synthesize categoryLoader;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [categoryPicker release], categoryPicker = nil;
    [doneButton release], doneButton = nil;
    [cancelButton release], cancelButton = nil;
    [typeLabel release], typeLabel = nil;
    [descLabel release], descLabel = nil;
	
    [super dealloc];
}




- (void)viewDidLoad {
    [super viewDidLoad];
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	self.categoryLoader = cycleStreets.categoryLoader;
	
	metacategoryIndex=0;
	categoryIndex=0;
	[self updateSelectionLabels];
}


#pragma mark picker delegate and data source

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0) {
		return [self.categoryLoader.metaCategoryLabels objectAtIndex:row];
	} else {
		return [self.categoryLoader.categoryLabels objectAtIndex:row];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 0) {
		return [self.categoryLoader.metaCategoryLabels count];
	} else {
		return [self.categoryLoader.categoryLabels count];
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == 0) {
		metacategoryIndex = row;
	} else {
		categoryIndex = row;
	}
	[self updateSelectionLabels];
}


-(void)updateSelectionLabels{
	
	typeLabel.text=[self.categoryLoader.metaCategoryLabels objectAtIndex:metacategoryIndex];
	descLabel.text=[self.categoryLoader.categoryLabels objectAtIndex:categoryIndex];
}

-(IBAction)didDone {
	[self dismissModalViewControllerAnimated:YES];
}
-(IBAction)didCancel {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark category interface

-(NSString *)category {
	return [self.categoryLoader.categories objectAtIndex:categoryIndex];
}

-(NSString *)metaCategory {
	return [self.categoryLoader.metaCategories objectAtIndex:metacategoryIndex];
}

#pragma mark view cleanup

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)nullify {
	self.categoryPicker = nil;
	self.doneButton = nil;
	self.categoryLoader = nil;	
}

- (void)viewDidUnload {
	[self nullify];
    [super viewDidUnload];
}



@end
