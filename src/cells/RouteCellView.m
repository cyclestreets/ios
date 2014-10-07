//
//  RouteCellView.m
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteCellView.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "ViewUtilities.h"
#import "GenericConstants.h"
#import "RouteVO.h"
#import "LayoutBox.h"
#import "ExpandedUILabel.h"
#import "MultiLabelLine.h"

@interface RouteCellView()

@property (nonatomic, weak)	IBOutlet LayoutBox          * viewContainer;
@property (nonatomic, weak)	IBOutlet ExpandedUILabel    * nameLabel;
@property (nonatomic, weak)	IBOutlet MultiLabelLine     * readoutLabel;
@property (nonatomic, weak)	IBOutlet UIImageView        * icon;
@property (nonatomic, weak)	IBOutlet UIImageView        * selectedRouteIcon;


@end

@implementation RouteCellView



-(void)initialise{
	
    _isSelectedRoute=NO;
	
	
	UIView *sview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
	sview.backgroundColor=UIColorFromRGB(0xcccccc);
	self.selectedBackgroundView=sview;
	
	
	
	_viewContainer.layoutMode=BUVerticalLayoutMode;
	_viewContainer.paddingLeft=10;
	_viewContainer.paddingTop=7;
	_viewContainer.paddingBottom=7;
	_viewContainer.itemPadding=0;
	[_viewContainer initFromNIB];
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),UIColorFromRGB(0x804000),nil];
	
	_readoutLabel.fonts=fonts;
	_readoutLabel.colors=colors;
	
}


-(void)populate{
	
	[self updateCellUILabels];
	
	
}



-(void)updateCellUILabels{
	
	self.nameLabel.text=_dataProvider.nameString;
	
	NSMutableArray *labelarr=[[NSMutableArray alloc] init];
	
	[labelarr addObject:[_dataProvider timeString]];
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[labelarr addObject:[NSString stringWithFormat:@"%3.1f miles", [[_dataProvider length] floatValue]/1600]];
	}else {
		[labelarr addObject:[NSString stringWithFormat:@"%3.1f km", [[_dataProvider length] floatValue]/1000]];
	}
    
	NSNumber *kmSpeed = [NSNumber numberWithInteger:[_dataProvider speed]];
	NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[labelarr addObject:[NSString stringWithFormat:@"%2ld mph", (long)mileSpeed]];
	}else {
		[labelarr addObject:[NSString stringWithFormat:@"%2ld kmh", (long)[_dataProvider speed]]];
	}
    
    
	[labelarr addObject:[_dataProvider planString]];
    
	_readoutLabel.labels=labelarr;
	[_readoutLabel drawUI];
    
	[_viewContainer refresh];
	
	_selectedRouteIcon.hidden=!_isSelectedRoute;
	
}


+(NSNumber*)heightForCellWithDataProvider:(RouteVO*)route{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[route nameString] :[UIFont systemFontOfSize:18]   :255 :NSLineBreakByWordWrapping];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[NSString stringWithFormat:@"%li",(long)[route time]] :[UIFont systemFontOfSize:13] :270 :NSLineBreakByClipping];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}

+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}



@end
