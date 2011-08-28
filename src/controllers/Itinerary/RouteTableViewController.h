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

//  RouteTable.h
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import <UIKit/UIKit.h>
#import "MultiLabelLine.h"
@class Route;

@interface RouteTableViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
	Route *route;
	NSInteger routeId;
	UITextView *headerText;
	
	
	IBOutlet	UILabel				*routeidLabel;
	IBOutlet	MultiLabelLine		*readoutLineOne;
	IBOutlet	MultiLabelLine		*readoutLineTwo;
	
	IBOutlet	UITableView			*tableView;
	
	
}
@property (nonatomic, retain)	Route	*route;
@property (nonatomic, assign)	NSInteger	routeId;
@property (nonatomic, retain)	IBOutlet UITextView	*headerText;
@property (nonatomic, retain)	IBOutlet UILabel	*routeidLabel;
@property (nonatomic, retain)	IBOutlet MultiLabelLine	*readoutLineOne;
@property (nonatomic, retain)	IBOutlet MultiLabelLine	*readoutLineTwo;
@property (nonatomic, retain)	IBOutlet UITableView	*tableView;


@end
