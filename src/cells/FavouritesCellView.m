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

//  FavouritesCell.m
//  CycleStreets
//
//  Created by Alan Paxton on 17/03/2010.
//	Revised by Neil Edwards 1/4/11

#import "FavouritesCellView.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "ViewUtilities.h"

@implementation FavouritesCellView
@synthesize dataProvider;
@synthesize viewContainer;
@synthesize nameLabel;
@synthesize readoutLabel;
@synthesize icon;
@synthesize isSelectedRoute;
@synthesize selectedRouteIcon;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [viewContainer release], viewContainer = nil;
    [nameLabel release], nameLabel = nil;
    [readoutLabel release], readoutLabel = nil;
    [icon release], icon = nil;
    [selectedRouteIcon release], selectedRouteIcon = nil;
	
    [super dealloc];
}




-(void)initialise{
	
	isSelectedRoute=NO;
	
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.paddingLeft=10;
	viewContainer.paddingTop=7;
	viewContainer.paddingBottom=7;
	viewContainer.itemPadding=0;
	[viewContainer initFromNIB];
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),UIColorFromRGB(0x804000),nil];
	
	readoutLabel.fonts=fonts;
	readoutLabel.colors=colors;
	
}


-(void)populate{
	
	self.nameLabel.text=[dataProvider name];
	
	NSMutableArray *arr=[[NSMutableArray alloc] init];
	
	[arr addObject:[dataProvider timeString]];
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[arr addObject:[NSString stringWithFormat:@"%3.1f miles", [[dataProvider length] floatValue]/1600]];
	}else {
		[arr addObject:[NSString stringWithFormat:@"%3.1f km", [[dataProvider length] floatValue]/1000]];
	}

	NSNumber *kmSpeed = [NSNumber numberWithInteger:[dataProvider speed]];
	NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[arr addObject:[NSString stringWithFormat:@"%2d mph", mileSpeed]];
	}else {
		[arr addObject:[NSString stringWithFormat:@"%2d kmh", [dataProvider speed]]];
	}

	 
	[arr addObject:[dataProvider planString]];
	 
	readoutLabel.labels=arr;
	[arr release];
	[readoutLabel drawUI];
	 
	[viewContainer refresh];
	
	selectedRouteIcon.hidden=!isSelectedRoute;
	[ViewUtilities alignView:selectedRouteIcon withView:viewContainer :BUNoneLayoutMode :BUCenterAlignMode];
	 
}




+(NSNumber*)heightForCellWithDataProvider:(Route*)route{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[route name] :[UIFont boldSystemFontOfSize:16]   :UIWIDTH :UILineBreakModeWordWrap];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[NSString stringWithFormat:@"%i",[route time]] :[UIFont systemFontOfSize:13] :UIWIDTH :UILineBreakModeClip];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}


+(int)rowHeight{
	return 70;
}



@end
