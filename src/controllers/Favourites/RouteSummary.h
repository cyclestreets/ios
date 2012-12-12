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
#import "RouteVO.h"
#import "LayoutBox.h"
#import "SuperViewController.h"
#import "ExpandedUILabel.h"
#import "SavedRoutesManager.h"
#import "BUActionSheet.h"

@interface RouteSummary : SuperViewController <BUActionSheetDelegate>{
	
	RouteVO								*route;
	
	SavedRoutesDataType					dataType;
	
	UIScrollView						*scrollView;
	
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
	IBOutlet		UILabel				*calorieLabel;
	IBOutlet		UILabel				*coLabel;
	
	
	
}

@property (nonatomic, strong) RouteVO		* route;
@property (nonatomic, assign) SavedRoutesDataType		 dataType;
@property (nonatomic, strong) UIScrollView		* scrollView;
@property (nonatomic, strong) LayoutBox		* viewContainer;
@property (nonatomic, strong) IBOutlet LayoutBox		* headerContainer;
@property (nonatomic, strong) IBOutlet ExpandedUILabel		* routeNameLabel;
@property (nonatomic, strong) IBOutlet UILabel		* dateLabel;
@property (nonatomic, strong) IBOutlet UILabel		* routeidLabel;
@property (nonatomic, strong) IBOutlet LayoutBox		* readoutContainer;
@property (nonatomic, strong) IBOutlet UILabel		* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel		* lengthLabel;
@property (nonatomic, strong) IBOutlet UILabel		* planLabel;
@property (nonatomic, strong) IBOutlet UILabel		* speedLabel;
@property (nonatomic, strong) IBOutlet UILabel		* calorieLabel;
@property (nonatomic, strong) IBOutlet UILabel		* coLabel;



@end
