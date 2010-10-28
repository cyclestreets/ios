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

//  PhotoInfo.h
//  CycleStreets
//
//  Created by Alan Paxton on 21/06/2010.
//

#import <UIKit/UIKit.h>
@class CategoryLoader;

@interface PhotoInfo : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	UIPickerView *categoryPicker;
	@private NSInteger categoryIndex;
	@private NSInteger metacategoryIndex;
	
	UIButton *doneButton;
	
	@private CategoryLoader *categoryLoader;
}

@property (nonatomic, retain) IBOutlet UIPickerView *categoryPicker;
@property (readonly) NSString *category;
@property (readonly) NSString *metaCategory;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) CategoryLoader *categoryLoader;

-(IBAction)didDone;

@end
