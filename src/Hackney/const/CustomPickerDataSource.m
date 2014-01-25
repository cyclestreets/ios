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
//  CustomPickerDataSource.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import "CustomPickerDataSource.h"
#import "CustomView.h"
#import "TripPurposeDelegate.h"

@implementation CustomPickerDataSource

@synthesize customPickerArray, parent;

- (id)init
{
	// use predetermined frame size
	self = [super init];
	if (self)
	{
		// create the data source for this custom picker
		NSMutableArray *viewArray = [[NSMutableArray alloc] init];

		/* Trip Purpose
		 * Commute
		 * School
		 * Work-related
		 * Exercise
		 * Social
		 * Shopping
		 * Errand
		 * Other
		 */
        
        /* Issue
         * Pavement issue
         * Traffic signal
         * Enforcement
         * Bike parking
         * Bike lane issue
         * Note this issue
         */
        
        /* Asset
         * Bike parking
         * Bike shops
         * Public restrooms
         * Secret passage
         * Water fountains
         * Note this asset
         */
		
        CustomView *view;
        pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        
        if (pickerCategory == 0) {
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Commute";
            view.image = [UIImage imageNamed:kTripPurposeCommuteIcon];
            [viewArray addObject:view];
          
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"School";
            view.image = [UIImage imageNamed:kTripPurposeSchoolIcon];
            [viewArray addObject:view];
          
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Work-Related";
            view.image = [UIImage imageNamed:kTripPurposeWorkIcon];
            [viewArray addObject:view];
           
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Exercise";
            view.image = [UIImage imageNamed:kTripPurposeExerciseIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Social";
            view.image = [UIImage imageNamed:kTripPurposeSocialIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Shopping";
            view.image = [UIImage imageNamed:kTripPurposeShoppingIcon];
            [viewArray addObject:view];
           
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Errand";
            view.image = [UIImage imageNamed:kTripPurposeErrandIcon];
            [viewArray addObject:view];
           
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Other";
            view.image = [UIImage imageNamed:kTripPurposeOtherIcon];
            [viewArray addObject:view];
            
        }
        else if (pickerCategory == 1){
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Pavement issue";
            //view.image = [UIImage imageNamed:kIssuePavementIssueIcon];
            [viewArray addObject:view];
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Traffic signal";
            //view.image = [UIImage imageNamed:kIssueTrafficSignalIcon];
            [viewArray addObject:view];
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Enforcement";
            //view.image = [UIImage imageNamed:kIssueEnforcementIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike parking";
            //view.image = [UIImage imageNamed:kIssueNeedParkingIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike lane issue";
            //view.image = [UIImage imageNamed:kIssueBikeLaneIssueIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Note this spot";
            //view.image = [UIImage imageNamed:kIssueNoteThisSpotIcon];
            [viewArray addObject:view];
           
        }
        else if (pickerCategory == 2){
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike parking";
            //view.image = [UIImage imageNamed:kAssetBikeParkingIcon];
            [viewArray addObject:view];
           
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike shops";
            //view.image = [UIImage imageNamed:kAssetBikeShopsIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Public restrooms";
            //view.image = [UIImage imageNamed:kAssetPublicRestroomsIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Secret passage";
            //view.image = [UIImage imageNamed:kAssetSecretPassageIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Water fountains";
            //view.image = [UIImage imageNamed:kAssetWaterFountainsIcon];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Note this spot";
            //view.image = [UIImage imageNamed:kAssetNoteThisSpotIcon];
            [viewArray addObject:view];
            
        }
        else if (pickerCategory == 3){
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Note this asset";
            view.image = [UIImage imageNamed:kNoteThisAsset];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Water fountains";
            view.image = [UIImage imageNamed:kNoteThisAsset];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Secret passage";
            view.image = [UIImage imageNamed:kNoteThisAsset];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Public restrooms";
            view.image = [UIImage imageNamed:kNoteThisAsset];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike shops";
            view.image = [UIImage imageNamed:kNoteThisAsset];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike parking";
            view.image = [UIImage imageNamed:kNoteThisAsset];
            [viewArray addObject:view];
            
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @" ";
            view.image = [UIImage imageNamed:kNoteBlank];
            [viewArray addObject:view];
            
            
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Pavement issue";
            view.image = [UIImage imageNamed:kNoteThisIssue];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Traffic signal";
            view.image = [UIImage imageNamed:kNoteThisIssue];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Enforcement";
            view.image = [UIImage imageNamed:kNoteThisIssue];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike parking";
            view.image = [UIImage imageNamed:kNoteThisIssue];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Bike lane issue";
            view.image = [UIImage imageNamed:kNoteThisIssue];
            [viewArray addObject:view];
            
            
            view = [[CustomView alloc] initWithFrame:CGRectZero];
            view.title = @"Note this issue";
            view.image = [UIImage imageNamed:kNoteThisIssue];
            [viewArray addObject:view];
            

        }

		self.customPickerArray = viewArray;
		
	}
	return self;
}



#pragma mark UIPickerViewDataSource


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return [CustomView viewWidth];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return [CustomView viewHeight];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [customPickerArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


#pragma mark UIPickerViewDelegate


// tell the picker which view to use for a given component and row, we have an array of views to show
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UIView * myView=[customPickerArray objectAtIndex:row];
	
	UIGraphicsBeginImageContextWithOptions(myView.bounds.size, NO, 0);
	
    [myView.layer renderInContext:UIGraphicsGetCurrentContext()];
	
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
    // then convert back to a UIImageView and return it
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	
    return imageView;
}





- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	//NSLog(@"child didSelectRow: %d inComponent:%d", row, component);
	[parent pickerView:pickerView didSelectRow:row inComponent:component];
}



@end
