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

//  RouteSummary.h
//  CycleStreets
//
//  Created by Alan Paxton on 05/09/2010.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "LayoutBox.h"
#import "SuperViewController.h"
#import "ExpandedUILabel.h"

@interface RouteSummary : SuperViewController {
	
	Route								*route;
	
	LayoutBox							*viewContainer;
	
	IBOutlet		LayoutBox			*headerContainer;
	IBOutlet		ExpandedUILabel		*routeNameLabel;
	IBOutlet		UILabel				*dateLabel;
	IBOutlet		UILabel				*routeidLabel;
	
	IBOutlet		LayoutBox			*readoutContainer;
	IBOutlet		UILabel				*timeLabel;
	IBOutlet		UILabel				*lengthLabel;
	IBOutlet		UILabel				*planLabel;
	IBOutlet		UILabel				*speedLabel;	
	
	
	IBOutlet		UIButton			*routeButton;
	
}

@property (nonatomic, retain)	Route	*route;
@property (nonatomic, retain)	LayoutBox	*viewContainer;
@property (nonatomic, retain)	IBOutlet LayoutBox	*headerContainer;
@property (nonatomic, retain)	IBOutlet ExpandedUILabel	*routeNameLabel;
@property (nonatomic, retain)	IBOutlet UILabel	*dateLabel;
@property (nonatomic, retain)	IBOutlet UILabel	*routeidLabel;
@property (nonatomic, retain)	IBOutlet LayoutBox	*readoutContainer;
@property (nonatomic, retain)	IBOutlet UILabel	*timeLabel;
@property (nonatomic, retain)	IBOutlet UILabel	*lengthLabel;
@property (nonatomic, retain)	IBOutlet UILabel	*planLabel;
@property (nonatomic, retain)	IBOutlet UILabel	*speedLabel;
@property (nonatomic, retain)	IBOutlet UIButton	*routeButton;


- (IBAction) didRouteButton;

@end
