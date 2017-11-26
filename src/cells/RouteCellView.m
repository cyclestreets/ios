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
#import "CycleStreets.h"

@import PureLayout;

@interface RouteCellView()

@property (nonatomic, weak)	IBOutlet UILabel    		* nameLabel;
@property(nonatomic,weak) IBOutlet UIStackView	         *labelContainer;
@property (nonatomic, weak)	IBOutlet UIImageView        * selectedRouteIcon;


@property (nonatomic,strong)  NSMutableArray *fonts;
@property (nonatomic,strong)  NSMutableArray *colors;


@end

@implementation RouteCellView



-(void)initialise{
	
    _isSelectedRoute=NO;
	
	
	UIView *sview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
	sview.backgroundColor=UIColorFromRGB(0xcccccc);
	self.selectedBackgroundView=sview;
	
	
	self.fonts=[NSMutableArray arrayWithObjects:[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],[UIFont systemFontOfSize:13],nil];
	self.colors=[NSMutableArray arrayWithObjects:UIColorFromRGB(0xFF8000),UIColorFromRGB(0x007F00),UIColorFromRGB(0x404040),UIColorFromRGB(0x804000),nil];
	
	
}


-(void)populate{
	
	[self updateCellUILabels];
	
	
}



-(void)updateCellUILabels{
	
	self.nameLabel.text=_dataProvider.nameString;
	
	NSMutableArray *labelarr=[[NSMutableArray alloc] init];
	
	[labelarr addObject:[_dataProvider timeString]];
	
	[labelarr addObject:[CycleStreets formattedDistanceString:[[_dataProvider length] doubleValue]]];
	
	NSNumber *kmSpeed = [NSNumber numberWithInteger:[_dataProvider speed]];
	NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES){
		[labelarr addObject:[NSString stringWithFormat:@"%2ld mph", (long)mileSpeed]];
	}else {
		[labelarr addObject:[NSString stringWithFormat:@"%2ld kmh", (long)[_dataProvider speed]]];
	}
    
    
	[labelarr addObject:[_dataProvider planString]];
	
	for(int x=0;x<labelarr.count;x++){
		
		UILabel *label=[[UILabel alloc]initForAutoLayout];
		label.numberOfLines=0;
		label.font=_fonts[x];
		label.textColor=_colors[x];
		NSString *string=labelarr[x];
		label.text=string;
		if ([labelarr lastObject]==string) {
			[label setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		}else{
			[label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
		}
		
		
		
		[_labelContainer addArrangedSubview:label];
	}
    
	
	_selectedRouteIcon.hidden=!_isSelectedRoute;
	
}

//
//+(NSNumber*)heightForCellWithDataProvider:(RouteVO*)route{
//
//	int height=7;
//
//	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[route nameString] :[UIFont systemFontOfSize:18]   :255 :NSLineBreakByWordWrapping];
//	height+=5;
//	height+=[GlobalUtilities calculateHeightOfTextFromWidth:[NSString stringWithFormat:@"%li",(long)[route time]] :[UIFont systemFontOfSize:13] :270 :NSLineBreakByClipping];
//	height+=7;
//
//	return [NSNumber numberWithInt:height];
//}
//
//+(int)rowHeight{
//	return STANDARDCELLHEIGHT;
//}



@end
