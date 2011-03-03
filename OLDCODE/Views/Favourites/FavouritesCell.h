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

//  FavouritesCell.h
//  CycleStreets
//
//  Created by Alan Paxton on 17/03/2010.
//

#import <UIKit/UIKit.h>


@interface FavouritesCell : UITableViewCell {
	UILabel *name;
	UILabel *time;
	UILabel *length;
	UILabel *plan;
	UILabel *speed;
	
	UIImageView *icon;
}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UILabel *length;
@property (nonatomic, retain) IBOutlet UILabel *plan;
@property (nonatomic, retain) IBOutlet UILabel *speed;

@property (nonatomic, retain) IBOutlet UIImageView *icon;

@end
