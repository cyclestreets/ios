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
//	Revised by Neil Edwards 1/4/11

#import "FavouritesCellView.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "ViewUtilities.h"
#import "RouteVO.h"
#import "LayoutBox.h"
#import "ExpandedUILabel.h"
#import "MultiLabelLine.h"

@interface FavouritesCellView()

@property (nonatomic, strong)	RouteVO		*dataProvider;
@property (nonatomic, weak)	IBOutlet LayoutBox		*viewContainer;
@property (nonatomic, weak)	IBOutlet ExpandedUILabel		*nameLabel;
@property (nonatomic, weak)	IBOutlet MultiLabelLine		*readoutLabel;
@property (nonatomic, weak)	IBOutlet UIImageView		*icon;
@property (nonatomic)	BOOL		isSelectedRoute;
@property (nonatomic, weak)	IBOutlet UIImageView		*selectedRouteIcon;


@end


@implementation FavouritesCellView



-(void)initialise{
	
	_isSelectedRoute=NO;
	
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.paddingLeft=10;
	_viewContainer.paddingTop=7;
	_viewContainer.paddingBottom=7;
	_viewContainer.itemPadding=0;
	[_viewContainer initFromNIB];
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont boldSystemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),UIColorFromRGB(0x804000),nil];
	
	_readoutLabel.fonts=fonts;
	_readoutLabel.colors=colors;
	
}


-(void)populate{
	
	self.nameLabel.text=[_dataProvider name];
	
	NSMutableArray *arr=[[NSMutableArray alloc] init];
	
	[arr addObject:[_dataProvider timeString]];
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[arr addObject:[NSString stringWithFormat:@"%3.1f miles", [[_dataProvider length] floatValue]/1600]];
	}else {
		[arr addObject:[NSString stringWithFormat:@"%3.1f km", [[_dataProvider length] floatValue]/1000]];
	}

	NSNumber *kmSpeed = [NSNumber numberWithInteger:[_dataProvider speed]];
	NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[arr addObject:[NSString stringWithFormat:@"%2d mph", mileSpeed]];
	}else {
		[arr addObject:[NSString stringWithFormat:@"%2d kmh", [_dataProvider speed]]];
	}

	 
	[arr addObject:[_dataProvider planString]];
	 
	_readoutLabel.labels=arr;
	[_readoutLabel drawUI];
	 
	[_viewContainer refresh];
	
	_selectedRouteIcon.hidden=!_isSelectedRoute;
	[ViewUtilities alignView:_selectedRouteIcon withView:_viewContainer :BUNoneLayoutMode :BUCenterAlignMode];
	 
}




+(NSNumber*)heightForCellWithDataProvider:(RouteVO*)route{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[route name] :[UIFont boldSystemFontOfSize:16]   :UIWIDTH :NSLineBreakByWordWrapping];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[NSString stringWithFormat:@"%i",[route time]] :[UIFont systemFontOfSize:13] :UIWIDTH :NSLineBreakByClipping];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}


+(int)rowHeight{
	return 70;
}



@end
