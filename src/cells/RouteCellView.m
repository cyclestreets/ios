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


@implementation RouteCellView
@synthesize dataProvider;
@synthesize viewContainer;
@synthesize nameLabel;
@synthesize readoutLabel;
@synthesize icon;
@synthesize isSelectedRoute;
@synthesize selectedRouteIcon;


-(void)initialise{
	
    isSelectedRoute=NO;
	
	
	UIView *sview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
	sview.backgroundColor=UIColorFromRGB(0xcccccc);
	self.selectedBackgroundView=sview;
	
	
	
	viewContainer.layoutMode=BUVerticalLayoutMode;
	viewContainer.paddingLeft=10;
	viewContainer.paddingTop=7;
	viewContainer.paddingBottom=7;
	viewContainer.itemPadding=0;
	[viewContainer initFromNIB];
	
	NSMutableArray *fonts=[NSMutableArray arrayWithObjects:[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	NSMutableArray *colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),UIColorFromRGB(0x804000),nil];
	
	readoutLabel.fonts=fonts;
	readoutLabel.colors=colors;
	
}


-(void)populate{
	
	[self updateCellUILabels];
	
	
}



-(void)updateCellUILabels{
	
	self.nameLabel.text=dataProvider.nameString;
	
	NSMutableArray *labelarr=[[NSMutableArray alloc] init];
	
	[labelarr addObject:[dataProvider timeString]];
	
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[labelarr addObject:[NSString stringWithFormat:@"%3.1f miles", [[dataProvider length] floatValue]/1600]];
	}else {
		[labelarr addObject:[NSString stringWithFormat:@"%3.1f km", [[dataProvider length] floatValue]/1000]];
	}
    
	NSNumber *kmSpeed = [NSNumber numberWithInteger:[dataProvider speed]];
	NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[labelarr addObject:[NSString stringWithFormat:@"%2d mph", mileSpeed]];
	}else {
		[labelarr addObject:[NSString stringWithFormat:@"%2d kmh", [dataProvider speed]]];
	}
    
    
	[labelarr addObject:[dataProvider planString]];
    
	readoutLabel.labels=labelarr;
	[readoutLabel drawUI];
    
	[viewContainer refresh];
	
	selectedRouteIcon.hidden=!isSelectedRoute;
	
}


+(NSNumber*)heightForCellWithDataProvider:(RouteVO*)route{
	
	int height=7;
	
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[route nameString] :[UIFont systemFontOfSize:16]   :255 :NSLineBreakByWordWrapping];
	height+=5;
	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[NSString stringWithFormat:@"%i",[route time]] :[UIFont systemFontOfSize:13] :270 :NSLineBreakByClipping];
	height+=7;
	
	return [NSNumber numberWithInt:height];
}

+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}



@end
