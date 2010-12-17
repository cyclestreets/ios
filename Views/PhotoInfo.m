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
#import "Common.h"
#import "Categories.h"
#import "CycleStreets.h"
#import "Files.h"
#import "CategoryLoader.h"
#import "UIButton+Blue.h"

@interface PhotoInfo ()

@end

@implementation PhotoInfo

@synthesize categoryPicker;
@synthesize doneButton;
@synthesize categoryLoader;

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	self.categoryLoader = cycleStreets.categoryLoader;
	[self.doneButton setupBlue];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	
}

-(IBAction)didDone {
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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)nullify {
	self.categoryPicker = nil;
	self.doneButton = nil;
	self.categoryLoader = nil;	
}

- (void)viewDidUnload {
	[self nullify];
    [super viewDidUnload];
	DLog(@">>>");
}


- (void)dealloc {
	[self nullify];
    [super dealloc];
}


@end
