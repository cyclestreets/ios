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

//  Settings.h
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import <UIKit/UIKit.h>


@interface Settings : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSString *plan;
	NSString *speed;
	NSString *mapStyle;
	NSArray *mapStyles;
	NSString *imageSize;
	
	UISegmentedControl *planControl;
	UISegmentedControl *speedControl;
	UITableView *mapStyleTable;
	UISegmentedControl *imageSizeControl;
	UIButton *clearAccountButton;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *planControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *speedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *imageSizeControl;
@property (nonatomic, retain) IBOutlet UITableView *mapStyleTable;
@property (nonatomic, retain) IBOutlet UIButton *clearAccountButton;
@property (nonatomic, copy) NSString *plan;
@property (nonatomic, copy) NSString *speed;
@property (nonatomic, copy) NSString *mapStyle;
@property (nonatomic, retain) NSArray *mapStyles;
@property (nonatomic, copy) NSString *imageSize;

- (IBAction) changed;

- (IBAction) didClearAccount;

- (void) save;

@end
